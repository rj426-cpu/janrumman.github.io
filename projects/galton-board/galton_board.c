/**
 * Hunter Adams (vha3@cornell.edu)
 *
 * Galton board with peg collisions and a landing histogram.
 * Through a serial interface, the user can change the ball color.
 *
 * HARDWARE CONNECTIONS
    - GPIO 14 ---> Rotary encoder B
    - GPIO 15 ---> Rotary encoder A
    - GPIO 16 ---> VGA Hsync
    - GPIO 17 ---> VGA Vsync
    - GPIO 18 ---> VGA Green lo-bit --> 470 ohm resistor --> VGA_Green
    - GPIO 19 ---> VGA Green hi_bit --> 330 ohm resistor --> VGA_Green
    - GPIO 20 ---> 330 ohm resistor ---> VGA-Blue
    - GPIO 21 ---> 330 ohm resistor ---> VGA-Red
    - GPIO 22 ---> PULL UP ---> Pin 1 of rotory encoder
    - GPIO 26 ---> GPIO 22 ---> Detects pull low


    - RP2040 GND ---> VGA-GND
    - RP2040 GND ---> Rotary encoder COM
 *
 * RESOURCES USED
 *  - PIO state machines 0, 1, and 2 on PIO instance 0
 *  - DMA channels (2, by claim mechanism)
 *  - 153.6 kBytes of RAM (for pixel color data)
 *
 */

// Include the VGA grahics library
#include "VGA/vga16_graphics_v3.h"
// Include standard libraries
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdbool.h>
// Include Pico libraries
#include "pico/stdlib.h"
#include "pico/divider.h"
#include "pico/multicore.h"
#include "pico/sync.h"
#include "pico/util/queue.h"
// Include hardware libraries
#include "hardware/pio.h"
#include "hardware/spi.h"
#include "hardware/dma.h"
#include "hardware/clocks.h"
#include "hardware/pll.h"
#include "hardware/sync.h"
// Include protothreads
#include "pt_cornell_rp2040_v1_4.h"

#include "hardware/vreg.h"

// fix15 stores values scaled by 32768 (15 fractional bits)
typedef signed int fix15;

#define multfix15(a,b) \
    ((fix15)((((signed long long)(a)) * ((signed long long)(b))) >> 15))

#define float2fix15(a) ((fix15)((a) * 32768.0))
#define fix2float15(a) ((float)(a) / 32768.0f)
#define absfix15(a)    (abs((a)))

#define int2fix15(a) \
    ((fix15)(((signed long long)(a)) * 32768LL))

#define fix2int15(a) ((int)((a) >> 15))
#define char2fix15(a) int2fix15(a)

// The caller must ensure b != 0
#define divfix(a,b) \
    ((fix15)div_s64s64(((signed long long)(a)) * 32768LL, \
                      ((signed long long)(b))))

// Board settings. Keep these dimensions consistent with the VGA driver.
#define SCREEN_WIDTH 640
#define SCREEN_HEIGHT 480
#define SIDE_MARGIN 20
#define LEFT_WALL SIDE_MARGIN
#define RIGHT_WALL (SCREEN_WIDTH - SIDE_MARGIN)
#define TOP_WALL 0
#define BOARD_CENTER_X ((LEFT_WALL + RIGHT_WALL) / 2)
#define FIRST_PEG_Y 45
#define peg_radius 6
#define ball_radius 2
#define COLLISION_CLEARANCE 1
#define COLLISION_RADIUS (peg_radius + ball_radius)
#define vertical_seperation 19
#define horizonal_seperation 38
#define SPAWN_MAX_VX 0.5f
// Set to 0 to compare with single-core physics.
#define USE_SECOND_CORE 1
// Ball capacity is independent of peg/bin storage.
#define max_array 22200
#define MAX_PEG_ROWS 16
#define MAX_PEGS (MAX_PEG_ROWS * (MAX_PEG_ROWS + 1) / 2)
#define MAX_BINS (MAX_PEG_ROWS + 1)
#define HIST_BOTTOM_MARGIN 10
#define HIST_MIN_HEIGHT (2 * vertical_seperation)
#define TEXT_MARGIN 20
#define TEXT_LINE_SPACING 12
#define MAX_COLOR 15

// Wall coordinates are physical edges; keep the entire ball inside them.
#define hitBottom(b) ((b) >= int2fix15(board_bottom_y))
#define hitTop(b) ((b) < int2fix15(TOP_WALL + ball_radius))
#define hitLeft(a) ((a) < int2fix15(LEFT_WALL + ball_radius))
#define hitRight(a) ((a) > int2fix15(RIGHT_WALL - ball_radius))

// Scope probes: use only if GPIO 2 and 3 are free on your board.
// GPIO 2 high: all frame work. GPIO 3 high: combined physics and ball drawing.
#define FRAME_PROBE 2
#define PHYSICS_PROBE 3

// In VGA/vga16_graphics_v3.c select DOUBLE_BUFFER_60 on RP2350.
// The standard V3 driver supports double buffering only on RP2350.
// Frame pacing below follows the driver's buffer-swap signal.
#define SYSTEM_CLOCK_KHZ 380000
#define BUTTON_POLL_US 10000

// rotary encoder
#define A_GPIO 15
#define B_GPIO 14

#define PULL_UP_GPIO 22
#define DETECT_PULL_UP 26


// DAC
#define DAC_CS_GPIO   5
#define DAC_SCK_GPIO  6
#define DAC_MOSI_GPIO 7
#define DAC_SPI       spi0

#define AUDIO_SAMPLE_RATE 22050
#define SOUND_DURATION_MS 100
#define SOUND_SAMPLES (AUDIO_SAMPLE_RATE * SOUND_DURATION_MS / 1000)
#define TONE_FREQUENCY_HZ 400.0f
#define TONE_AMPLITUDE 1500.0f
#define DAC_BITS 12
#define DAC_MIDPOINT (1u << (DAC_BITS - 1))
#define DAC_SAMPLE_MASK ((1u << DAC_BITS) - 1u)
#define DAC_SPI_BAUD 20000000
#define DAC_CONFIG_A      0x3000     // DAC control bits selecting A, 1x gain, active output

// 60fps in microseconds
#define FRAME_RATE_US (1000000/60)

// The LED is connected to GPIO 25
#define LED_PIN 25

static uint16_t sound_data[SOUND_SAMPLES]; // sequence of 16-bit words DMA will send to DAC

// DMA
static int data_chan;
static int ctrl_chan;

// control channel copies this pointer into the data channel
static uint16_t *address_pointer = sound_data;

// Storage capacity is separate from the number of active bins.
fix15 bin_edges[MAX_BINS + 1];
uint32_t bins[MAX_BINS] = {0};
// Independent of histogram rescaling: the exact landings since its last reset.
uint64_t balls_fallen = 0;
int num_bins = 0;
int board_bottom_y;
int histogram_top_y;
int histogram_height;

// The serial thread changes the color used by both drawing threads
// the color of the boid
char color = PINK ;

// Velocities and collision normals use signed Q8.8 (16 bits total).
// Positions retain Q15 so the full 640 x 480 screen fits.
#define Q8_ONE 256
#define float2q8(value) ((int16_t)((value) * 256.0f))
#define q8ToPosition(value) ((fix15)(value) * 128)

// Widen products to avoid overflow, then return to Q8.8.
static inline int16_t multQ8(int16_t a, int16_t b)
{
    int32_t result = ((int32_t)a * b) / Q8_ONE;
    if (result > INT16_MAX) result = INT16_MAX;
    if (result < INT16_MIN) result = INT16_MIN;
    return (int16_t)result;
}

// Boid on core 0
fix15 boid0_x ;
fix15 boid0_y ;
fix15 boid0_vx ;
fix15 boid0_vy ;

int16_t gravity = float2q8(0.37f);
int16_t bounciness = float2q8(0.65f);

// boid 1
fix15 boid1_x ;
fix15 boid1_y ;
fix15 boid1_vx ;
fix15 boid1_vy ;

// multiple pegs

struct Peg{
    fix15 x;
    fix15 y;
};

struct Peg pegs[MAX_PEGS];

int num_peg_rows=16;
int total_peg = 0;

struct Ball {
    fix15 x;
    fix15 y;
    int16_t vx;
    int16_t vy;
};

// multiple balls;
int num_balls = 0;
struct Ball balls[max_array];

// Encoder count and previous channel readings.
int rotary_encoder_num;
static volatile int encoder_delta = 0;
bool prevA;
bool prevB;
bool A;
bool B;

int detect;
int prev_detect=1;
int rainbow=0;

int parameter_selected=0;

// Core 0 changes parameters/counts only between physics jobs.
// Each worker owns a disjoint range of balls for the whole job.
struct PhysicsJob { int first; int end; };
static queue_t physics_jobs;
static queue_t physics_done;
// Serialize ordinary rand() calls from the two physics cores.
// Initialize once in main, before spawning balls or launching core 1.
static mutex_t spawn_random_mutex;
// Each core owns its landing counters during a job.
static uint32_t frame_landings[2][MAX_BINS];
// Each core writes its own slot; core 0 reads only after the join.
static bool collision_sound_requested[2];

static inline int16_t randomSpawnVelocity(void)
{
    // 257 Q8.8 choices from -0.5 through +0.5 pixels/frame.
    return (int16_t)(rand() % 257 - 128);
}

static inline fix15 randomSpawnOffset(void)
{
    // A half-pixel variation to either side breaks repeated trajectories.
    return float2fix15((rand() % 10001 - 5000) / 10000.0f);
}

// New balls and respawns use the same height and a +/-0.5 pixel x offset.
void resetBall(struct Ball *ball)
{
    int spawn_gap = vertical_seperation;
    if (spawn_gap < COLLISION_RADIUS + COLLISION_CLEARANCE)
        spawn_gap = COLLISION_RADIUS + COLLISION_CLEARANCE;
    fix15 spawn_y = pegs[0].y - int2fix15(spawn_gap);
    if (spawn_y < int2fix15(TOP_WALL + ball_radius))
        spawn_y = int2fix15(TOP_WALL + ball_radius);

    *ball = (struct Ball){
        .x = pegs[0].x + randomSpawnOffset(),
        .y = spawn_y,
        .vx = randomSpawnVelocity(),
        .vy = 0
    };
}

void spawnBoid(void)
{
    if (num_balls >= max_array || total_peg == 0) return;
    resetBall(&balls[num_balls++]);
}

void resetHistogram(void)
{
    // Called on core 0 only, between jobs, while the physics worker is idle.
    memset(bins, 0, sizeof(bins));
    memset(frame_landings, 0, sizeof(frame_landings));
    balls_fallen = 0;
}

// A changed encoder count clears the histogram while preserving surviving balls.
void syncBallCount(void)
{
    if (rotary_encoder_num < 0) rotary_encoder_num = 0;
    if (rotary_encoder_num > max_array) rotary_encoder_num = max_array;
    int target = rotary_encoder_num;

    if (total_peg == 0) {
        num_balls = 0;
        return;
    }
    if (num_balls == target) return;

    // Clear only the histogram; surviving balls keep their position/velocity.
    resetHistogram();
    if (num_balls > target) num_balls = target;
    while (num_balls < target) spawnBoid();
}

// Bottom-row peg centers divide the board into num_peg_rows + 1 bins.
void init_bins(void) {
    int bottom_row_start = total_peg - num_peg_rows;
    num_bins = num_peg_rows + 1;
    resetHistogram();
    bin_edges[0] = int2fix15(LEFT_WALL);

    for (int i = 0; i < num_peg_rows; i++) {
        bin_edges[i + 1] = pegs[bottom_row_start + i].x;
    }

    bin_edges[num_bins] = int2fix15(RIGHT_WALL);

    // Count once the whole ball clears the bottom row, then respawn it.
    board_bottom_y = fix2int15(pegs[bottom_row_start].y)
                   + COLLISION_RADIUS + COLLISION_CLEARANCE;
    histogram_top_y = board_bottom_y+50;
    histogram_height = SCREEN_HEIGHT - HIST_BOTTOM_MARGIN
                     - histogram_top_y - 1;
}

void recordLanding(fix15 x)
{
    // Interior boundaries belong to the bin on their right. Clamp the two
    // outer edges as well, so even x == RIGHT_WALL has a valid bin.
    int low = 0;
    int high = num_bins - 1;
    while (low < high) {
        int mid = low + (high - low) / 2;
        if (x < bin_edges[mid + 1]) high = mid;
        else low = mid + 1;
    }

    // Only this core writes its own row; at most max_array landings per frame.
    frame_landings[get_core_num()][low]++;
}

static void mergeFrameLandings(void)
{
    // Core 0 calls this after joining core 1. Use wide sums so a whole
    // frame of landings cannot wrap an almost-full histogram counter.
    uint64_t updated_bins[MAX_BINS];
    uint32_t landed = 0;
    bool rescale = false;
    for (int i = 0; i < num_bins; i++) {
        uint32_t added = frame_landings[0][i] + frame_landings[1][i];
        landed += added;
        updated_bins[i] = (uint64_t)bins[i] + added;
        if (updated_bins[i] > UINT32_MAX) rescale = true;
        frame_landings[0][i] = 0;
        frame_landings[1][i] = 0;
    }
    // A batch contains at most max_array new landings, so one halving suffices.
    // Apply the same scale to every bin; the exact lifetime total is separate.
    for (int i = 0; i < num_bins; i++) {
        bins[i] = (uint32_t)(rescale ? updated_bins[i] / 2 : updated_bins[i]);
    }
    balls_fallen += landed;
}

static void encoder_callback(uint gpio, uint32_t events)
{
    if (gpio != A_GPIO && gpio != B_GPIO) return;
    (void)events;
    uint32_t pins = gpio_get_all();
    A = (pins & (1u << A_GPIO)) == 0;
    B = (pins & (1u << B_GPIO)) == 0;
    int delta = (A ^ prevB) - (prevA ^ B);
    prevA = A;
    prevB = B;
    // Bound the backlog so parameter arithmetic cannot overflow.
    if ((delta > 0 && encoder_delta < max_array) ||
        (delta < 0 && encoder_delta > -max_array)) {
        encoder_delta += delta;
    }
}

// Core 0 calls this before starting either core's physics work.
static void applyEncoderChanges(void)
{
    if (encoder_delta == 0) return;

    uint32_t irq_state = save_and_disable_interrupts();
    int delta = encoder_delta;
    encoder_delta = 0;
    restore_interrupts(irq_state);

    if (parameter_selected==0){
        rotary_encoder_num += delta;
        if (rotary_encoder_num < 0) rotary_encoder_num = 0;
        if (rotary_encoder_num > max_array) rotary_encoder_num = max_array;
    }
    if (delta!=0) resetHistogram();
    if (parameter_selected == 1 || parameter_selected == 2) {
        int16_t *parameter = parameter_selected == 1 ? &bounciness : &gravity;
        // Clamp before multiplying a potentially large encoder backlog.
        if (delta > Q8_ONE) delta = Q8_ONE;
        if (delta < -Q8_ONE) delta = -Q8_ONE;
        int16_t updated = (int16_t)(*parameter + delta * float2q8(0.01f));
        if (updated < 0) updated = 0;
        if (updated > Q8_ONE) updated = Q8_ONE;
        *parameter = updated;
    }
}

// Poll only the debounced button.
static PT_THREAD (poll_encoder_button(struct pt *pt))
{
    PT_BEGIN(pt);
    static int button_candidate = 1;
    static int button_samples = 0;
    while (1) {
        detect = gpio_get(DETECT_PULL_UP);

        // Require three consecutive matching readings.
        if (detect != button_candidate) {
            button_candidate = detect;
            button_samples = 1;
        } else if (button_samples < 3) {
            button_samples++;
        }

        if (button_samples == 3 && button_candidate != prev_detect) {
            prev_detect = button_candidate;

            // Change selection only on a debounced press.
            if (prev_detect == 0) {
                parameter_selected = (parameter_selected + 1) % 3;
            }
        }
        PT_YIELD_usec(BUTTON_POLL_US);
    }
    PT_END(pt);
}


void playCollisionSound(void)
{
    // Start control channel -> reset buffer address ->
    // trigger data channel -> send sound -> stop

    // let an existing sound finish
    if (dma_channel_is_busy(ctrl_chan) ||
        dma_channel_is_busy(data_chan) ||
        spi_is_busy(DAC_SPI)) {
        return;
    }

    // Prepare both transfer counts without starting either channel.
    dma_channel_set_trans_count(data_chan, SOUND_SAMPLES, false);
    dma_channel_set_trans_count(ctrl_chan, 1, false);

    // Rewind the sample pointer, then start playback through chaining.
    dma_start_channel_mask(1u << ctrl_chan);
}


// Approximate distance, using the requested alpha-max plus beta-min method.
static fix15 alphaMaxBetaMin(fix15 dx, fix15 dy)
{
    fix15 ax = absfix15(dx);
    fix15 ay = absfix15(dy);

    fix15 maximum = ax > ay ? ax : ay;
    fix15 minimum = ax > ay ? ay : ax;

    return maximum + (minimum >> 1);
}

void updateBallPosition(struct Ball *ball,
                        struct Peg *peg)
{
    // calculate displacement from peg to ball
    fix15 dx = ball->x - peg->x;
    fix15 dy = ball->y - peg->y;

    // pythagorean theorem
    if (absfix15(dx) < int2fix15(COLLISION_RADIUS) && absfix15(dy) < int2fix15(COLLISION_RADIUS)) {
        fix15 distance_squared = multfix15(dx, dx) + multfix15(dy, dy);
        const fix15 radius = int2fix15(COLLISION_RADIUS);
        if (distance_squared < multfix15(radius, radius)) {
            fix15 distance = alphaMaxBetaMin(dx, dy);
            // calculate collision's normla direction
            int16_t normal_x;
            int16_t normal_y;
            if (distance > 0) {
                // Q15 displacement divided into a Q8.8 normal.
                normal_x = (int16_t)(((int32_t)dx * Q8_ONE) / distance);
                normal_y = (int16_t)(((int32_t)dy * Q8_ONE) / distance);
            } else { // center coincide, choose upward as direction
                normal_x = 0;
                normal_y = -Q8_ONE;
            }

            // motion along normal direction
            int16_t dot_product = (int16_t)(multQ8(normal_x, ball->vx)
                              + multQ8(normal_y, ball->vy));

            // Separate the surfaces using the same radii as drawing.
            ball->x = peg->x + q8ToPosition(normal_x) * (COLLISION_RADIUS + COLLISION_CLEARANCE);
            ball->y = peg->y + q8ToPosition(normal_y) * (COLLISION_RADIUS + COLLISION_CLEARANCE);

            // if ball is approaching
            if (dot_product < 0) {
                int16_t impulse = (int16_t)(-2 * dot_product);

                // reflect velocity
                ball->vx += multQ8(normal_x, impulse);
                ball->vy += multQ8(normal_y, impulse);

                // half both components by bounciness
                ball->vx = multQ8(ball->vx, bounciness);
                ball->vy = multQ8(ball->vy, bounciness);

                collision_sound_requested[get_core_num()] = true;
            }
        }
    }
}

void drawHist(void)
{
    if (num_bins == 0) return;
    // Bars grow upward from the bottom of the histogram region. Scaling
    // keeps their tops at or below histogram_top_y, beneath the last pegs.
    int label_rows = 1;

    uint32_t peak = 0;
    for (int i = 0; i < num_bins; i++) {
        if (bins[i] > peak) peak = bins[i];
        char count_text[11]; // Up to 10 digits for a uint32_t, plus terminator.
        snprintf(count_text, sizeof(count_text), "%" PRIu32, bins[i]);
        int width = fix2int15(bin_edges[i + 1]) - fix2int15(bin_edges[i]);
        int chars_per_row = (width - 1) / 6;
        if (chars_per_row < 1) chars_per_row = 1;
        int rows = ((int)strlen(count_text) + chars_per_row - 1) / chars_per_row;
        if (rows > label_rows) label_rows = rows;
    }
    // The size-1 font uses 6x8 pixels. Reserve room for exact counts;
    // long counts wrap within their bin instead of overlapping neighbors.
    int bar_height = histogram_height - label_rows * 8 - 2;
    if (bar_height <= 0) return;
    int baseline_y = histogram_top_y + bar_height;
    setTextColor(WHITE);
    setTextSize(1);

    for (int i = 0; i < num_bins; i++) {
        int x = fix2int15(bin_edges[i]);
        int width = fix2int15(bin_edges[i + 1]) - x;
        // Leave one pixel between bars so neighboring bins stay visible.
        if (width > 1) width--;
        if (width <= 0) continue;

        // Normalize the tallest bar to fill all available histogram space.
        if (peak > 0 && bins[i] > 0) {
            uint64_t height = (uint64_t)bins[i] * bar_height / peak;
            if (height == 0) height = 1;
            drawRect(x, baseline_y - (int)height, width, (int)height,  WHITE);
        }

        char count_text[11];
        snprintf(count_text, sizeof(count_text), "%" PRIu32, bins[i]);
        int chars_per_row = width / 6;
        if (chars_per_row < 1) chars_per_row = 1;
        int length = (int)strlen(count_text);
        for (int offset = 0, row = 0; offset < length; row++) {
            int chars = length - offset;
            if (chars > chars_per_row) chars = chars_per_row;
            char line[11];
            memcpy(line, count_text + offset, chars);
            line[chars] = '\0';
            drawTextGLCD(x + (width - chars * 6) / 2,
                         baseline_y + 2 + row * 8, line,  WHITE, BLACK);
            offset += chars;
        }
    }
}


void generate_pegs(void)
{
    // Only allow complete rows that fit in both the screen and the array.
    int max_rows_width = (RIGHT_WALL - LEFT_WALL
                       - 2 * (COLLISION_RADIUS + COLLISION_CLEARANCE))
                       / horizonal_seperation + 1;
    int max_rows_height = (SCREEN_HEIGHT - HIST_BOTTOM_MARGIN - 1
                        - HIST_MIN_HEIGHT - FIRST_PEG_Y
                        - COLLISION_RADIUS - COLLISION_CLEARANCE)
                        / vertical_seperation + 1;
    int max_rows = max_rows_width;
    if (max_rows_height < max_rows) max_rows = max_rows_height;
    if (max_rows > MAX_PEG_ROWS) max_rows = MAX_PEG_ROWS;
    while (max_rows > 0 && (long long)max_rows * (max_rows + 1) / 2 > MAX_PEGS)
        max_rows--;

    // Invalid base settings cannot produce even one complete row.
    if (max_rows < 1) {
        total_peg = 0;
        num_bins = 0;
        return;
    }
    if (num_peg_rows < 1) num_peg_rows = 1;
    if (num_peg_rows > max_rows) num_peg_rows = max_rows;

    total_peg = 0;
    for (int row = 1; row <= num_peg_rows; row++) {
        // Center each row independently, including odd peg spacings.
        fix15 starting_x = int2fix15(BOARD_CENTER_X)
                        - int2fix15((row - 1) * horizonal_seperation) / 2;
        fix15 y = int2fix15(FIRST_PEG_Y + (row - 1) * vertical_seperation);
        for (int col = 0; col < row; col++) {
            struct Peg newPeg = {
                starting_x + int2fix15(horizonal_seperation * col), y
            };
            pegs[total_peg++] = newPeg;
        }
    }
    init_bins();
}

void checkNearbyPeg(struct Ball *ball)
{
    if (total_peg == 0) return;

    const fix15 row_spacing = int2fix15(vertical_seperation);
    const fix15 col_spacing = int2fix15(horizonal_seperation);
    const fix15 radius = int2fix15(COLLISION_RADIUS);

    // Find the nearest row using the ball's fixed-point y coordinate.
    int row = (ball->y - pegs[0].y + row_spacing / 2)
            / row_spacing;

    if (row < 0 || row >= num_peg_rows) return;

    // Rows contain 1, 2, 3, ... pegs.
    // Their starting indices are 0, 1, 3, 6, 10, ...
    int first = row * (row + 1) / 2;

    // Reject balls too far above or below this row.
    if (absfix15(ball->y - pegs[first].y) >= radius) return;

    // Find the nearest column relative to this row's first peg.
    int col = (ball->x - pegs[first].x + col_spacing / 2)
            / col_spacing;

    // Zero-based row r contains r + 1 pegs.
    if (col < 0 || col > row) return;

    struct Peg *peg = &pegs[first + col];

    if (absfix15(ball->x - peg->x) >= radius) return;

    // Keep your existing exact distance check, bounce, and sound.
    updateBallPosition(ball, peg);
}

void updateOneBall(struct Ball *ball)
{
    // Existing movement and collision calculations.
    ball->x += q8ToPosition(ball->vx);
    ball->y += q8ToPosition(ball->vy);

    checkNearbyPeg(ball);

    if (hitTop(ball->y)) {
        if (ball->vy < 0)
            ball->vy = -ball->vy;
        ball->y = int2fix15(TOP_WALL + ball_radius);
    }

    if (hitRight(ball->x)) {
        if (ball->vx > 0)
            ball->vx = -ball->vx;
        ball->x = int2fix15(RIGHT_WALL - ball_radius);
    }

    if (hitLeft(ball->x)) {
        if (ball->vx < 0)
            ball->vx = -ball->vx;
        ball->x = int2fix15(LEFT_WALL + ball_radius);
    }

    if (hitBottom(ball->y)) {
        recordLanding(ball->x);

        // Respawn the ball directly.
        resetBall(ball);
        return;
    }

    ball->vy += gravity;

    // Keep dot products and doubled collision impulses within Q8.8 range.
    const int16_t speed_limit = 24 * Q8_ONE;
    if (ball->vx > speed_limit) ball->vx = speed_limit;
    if (ball->vx < -speed_limit) ball->vx = -speed_limit;
    if (ball->vy > speed_limit) ball->vy = speed_limit;
    if (ball->vy < -speed_limit) ball->vy = -speed_limit;

}

// Core 1 runs only physics. No VGA, protothreads, serial, or audio DMA here.
static void core1_entry(void)
{
    while (true) {
        struct PhysicsJob job;
        queue_remove_blocking(&physics_jobs, &job);
        for (int i = job.first; i < job.end; ++i) {
            updateOneBall(&balls[i]);
        }
        // Queue synchronization publishes ball/counter/sound writes to core 0.
        uint32_t done = 1;
        queue_add_blocking(&physics_done, &done);
    }
}

// ==================================================
// === users serial input thread
// ==================================================
static PT_THREAD (protothread_serial(struct pt *pt))
{
    PT_BEGIN(pt);

    // stores user input
    static int user_input ;

    // wait for 1 sec
    PT_YIELD_usec(1000000) ;

    // announce the threader version
    sprintf(pt_serial_out_buffer, "Protothreads RP2040 v1.4\n\r");

    // non-blocking write
    serial_write ;

    while(1) {
        // print prompt
        sprintf(pt_serial_out_buffer, "input a number in the range 1-%d: ", MAX_COLOR);

        // non-blocking write
        serial_write ;

        // spawn a thread to do the non-blocking serial read
        serial_read ;

        // convert input string to number
        if (sscanf(pt_serial_in_buffer, "%d", &user_input) != 1) continue;

        // update boid color
        if ((user_input > 0) && (user_input <= MAX_COLOR)) {
            color = (char)user_input ;
        }
    } // END WHILE(1)

    PT_END(pt);
} // timer thread


void draw_pegs(){
    for (int i = 0; i < total_peg; i++){
        drawCircle(
            fix2int15(pegs[i].x),
            fix2int15(pegs[i].y),
            peg_radius,
            WHITE
        );
    }
}

static uint32_t last_frame_us, last_update_draw_us, missed_frames;

void drawStats(void)
{
    char stats_text[48];
    int x = LEFT_WALL + TEXT_MARGIN;
    int y = TOP_WALL + TEXT_MARGIN;
    int normal_color = WHITE;
    uint64_t boot_seconds = time_us_64() / 1000000u;

    setTextSize(1);
    setTextColor(normal_color);

    snprintf(stats_text, sizeof(stats_text),
             "Total particles dropped: %" PRIu64, balls_fallen);
    drawTextGLCD(x, y, stats_text, normal_color, BLACK);

    // 0 = particles, 1 = bounciness, 2 = gravity.
    for (int field = 0; field < 3; field++) {
        int field_y = y + (field + 1) * TEXT_LINE_SPACING;
        bool selected = parameter_selected == field;

        if (selected) {
            fillRect(x - 2, field_y - 2, 180, TEXT_LINE_SPACING, WHITE);
            setTextColor(0);
        } else {
            setTextColor(WHITE);
        }

        if (field == 0) {
            snprintf(stats_text, sizeof(stats_text), "Active Particles: %d", num_balls);
        } else if (field == 1) {
            snprintf(stats_text, sizeof(stats_text), "Bounciness: %.2f", ((float)bounciness / Q8_ONE));
        } else {
            snprintf(stats_text, sizeof(stats_text), "Gravity: %.2f", ((float)gravity / Q8_ONE));
        }

        drawTextGLCD(x, field_y, stats_text, selected ? BLACK : normal_color, selected ? (WHITE) : BLACK);
    }

    setTextColor(normal_color);
    snprintf(stats_text, sizeof(stats_text),
            "Time elapsed: %" PRIu64 " seconds", boot_seconds);
    drawTextGLCD(x, y + 4 * TEXT_LINE_SPACING, stats_text, normal_color, BLACK);

}

// The Cornell V3 driver exports this draw-buffer pointer.
extern char *current_draw_buffer;

// White pegs on black need only one bit per pixel in the saved background.
// Background and framebuffer now share the same 1-bit format.
static uint8_t peg_background[SCREEN_WIDTH * SCREEN_HEIGHT / 8];
static int cached_peg_count = -1;

static void restorePegBackground(void)
{
    uint8_t *buffer = (uint8_t *)current_draw_buffer;

    if (cached_peg_count != total_peg) {
        clearLowFrame(0, BLACK);
        draw_pegs();

        // Save the already-packed monochrome pixels.
        memcpy(peg_background, buffer, sizeof(peg_background));

        cached_peg_count = total_peg;
    } else {
        // Restore black background and pegs in one copy.
        memcpy(buffer, peg_background, sizeof(peg_background));
    }
}

// static uint8_t ball_half_width[ball_radius + 1];

// static void initBallShape(void)
// {
//     // Match V3 fillCircle's shape exactly; the radius is still configurable.
//     for (int dy = 0; dy <= ball_radius; ++dy) {
//         ball_half_width[dy] = (uint8_t)sqrtf(
//             (float)(ball_radius * ball_radius + ball_radius - dy * dy));
//     }
// }

// static void drawBallFast(uint8_t *buffer, int x, int y, uint8_t color)
// {
//     if (x - ball_radius < 0 || x + ball_radius >= SCREEN_WIDTH ||
//         y - ball_radius < 0 || y + ball_radius >= SCREEN_HEIGHT) {
//         fillCircle(x, y, ball_radius, color);
//         return;
//     }
//     uint8_t pair = color | (color << 4);
//     for (int dy = -ball_radius; dy <= ball_radius; ++dy) {
//         int half = ball_half_width[dy < 0 ? -dy : dy];
//         int left = x - half;
//         int width = 2 * half; // Same pixel span as V3 fillCircle.
//         uint8_t *p = buffer + (y + dy) * (SCREEN_WIDTH / 2) + (left >> 1);
//         if ((left & 1) && width) {
//             *p = (*p & 0x0f) | (color << 4);
//             ++p;
//             --width;
//         }
//         while (width >= 2) {
//             *p++ = pair;
//             width -= 2;
//         }
//         if (width) *p = (*p & 0xf0) | color;
//     }
// }

static void drawBall2x2(int x, int y, uint8_t color)
{
    fillRect( x -1, y -1, 2, 2, color);
}

static void drawBallRange(uint8_t *buffer,
                        int first, int end,
                        uint8_t color)
{
    for (int i = first; i < end; ++i) {
        drawBall2x2(
                    fix2int15(balls[i].x),
                    fix2int15(balls[i].y),
                    color);
    }
}

void updateAndDrawBalls(uint8_t *buffer, uint8_t ball_color)
{
    if (total_peg == 0 || num_bins == 0 || num_balls == 0)
        return;

    collision_sound_requested[0] = false;
    collision_sound_requested[1] = false;

#if USE_SECOND_CORE
    int split = num_balls * 3 / 10;
    struct PhysicsJob job = { split, num_balls };

    // Core 1 starts updating the second half.
    queue_add_blocking(&physics_jobs, &job);

    // Core 0 updates the first half.
    for (int i = 0; i < split; ++i) {
        updateOneBall(&balls[i]);
    }

    // Draw only our completed half.
    // Core 1 may still be calculating its half.
    drawBallRange(buffer, 0, split, ball_color);

    // Wait before reading any balls belonging to core 1.
    uint32_t done;
    queue_remove_blocking(&physics_done, &done);

    // Core 1's updates are now complete and visible.
    drawBallRange(buffer, split, num_balls, ball_color);
#else
    // Preserve the single-core comparison mode.
    for (int i = 0; i < num_balls; ++i) {
        updateOneBall(&balls[i]);
    }

    drawBallRange(buffer, 0, num_balls, ball_color);
#endif

    // Both workers have finished before shared results are read.
    mergeFrameLandings();

    if (collision_sound_requested[0] ||
        collision_sound_requested[1]) {
        playCollisionSound();
    }
}


// Animation on core 0
static PT_THREAD (protothread_anim(struct pt *pt))
{
    // Mark beginning of thread
    PT_BEGIN(pt);

    while(1) {
        // Only core 0 consumes this signal. Waiting is not measured.
        PT_YIELD_UNTIL(pt, draw_start_signal());
        gpio_put(FRAME_PROBE, 1);

        // Start Time
        uint64_t start_time = time_us_64();

        // Restore black background and cached pegs into this frame.
        restorePegBackground();

        // Apply captured rotation before either core starts physics.
        applyEncoderChanges();
        syncBallCount();

        uint8_t *frame_buffer = (uint8_t *)current_draw_buffer;
        uint8_t ball_color = WHITE;

        // This now measures physics AND ball drawing together.
        gpio_put(PHYSICS_PROBE, 1);
        uint64_t update_draw_start = time_us_64();

        updateAndDrawBalls(frame_buffer, ball_color);

        last_update_draw_us =
            (uint32_t)(time_us_64() - update_draw_start);
        gpio_put(PHYSICS_PROBE, 0);

        drawHist();

        // Current ball count, total landings since reset, and time since boot.
        drawStats();

        // End Time
        uint64_t end_time = time_us_64();

        // Elapsed time
        uint64_t elapsed_time = end_time - start_time;
        last_frame_us = (uint32_t)elapsed_time;
        if (elapsed_time > FRAME_RATE_US) ++missed_frames;

        // calculate missed frame rate
        if (elapsed_time > FRAME_RATE_US) {
            // Set high
            gpio_put(LED_PIN, 1);  
        }       
        else {
            // Set low
            gpio_put(LED_PIN, 0);  
        }       
        // Falling edge marks completion of all work for this frame.
        gpio_put(FRAME_PROBE, 0);

        // NEVER exit while
    } // END WHILE(1)

    PT_END(pt);
} // animation thread


// All VGA drawing stays on core 0; only completed ball ranges are drawn.

// short tone that fades out
void buildCollisionSound(void)
{
    for (int i = 0; i < SOUND_SAMPLES; i++) {
        float time = (float)i / AUDIO_SAMPLE_RATE; // playback time

        // decreases from 1 to 0 creating fading sound
        float envelope = 1.0f - (float)i / (SOUND_SAMPLES - 1);

        float wave = sinf(2.0f * 3.14159265f * TONE_FREQUENCY_HZ * time);
        int sample = (int)DAC_MIDPOINT + (int)(TONE_AMPLITUDE * envelope * wave);

        sound_data[i] = DAC_CONFIG_A | (sample & DAC_SAMPLE_MASK);
    }
}


// initialize DMA
void initAudioDMA(void)
{
    // Claim unused channels because VGA also uses DMA
    data_chan = dma_claim_unused_channel(true);
    ctrl_chan = dma_claim_unused_channel(true);

    // CONTROL CHANNEL: rewind the data channel's read address,
    // then trigger the data channel
    dma_channel_config c = dma_channel_get_default_config(ctrl_chan);

    channel_config_set_transfer_data_size(&c, DMA_SIZE_32);
    channel_config_set_read_increment(&c, false);
    channel_config_set_write_increment(&c, false);
    channel_config_set_chain_to(&c, data_chan);

    dma_channel_configure(
        ctrl_chan,
        &c,
        &dma_hw->ch[data_chan].read_addr, // Destination
        &address_pointer,               // Source: stored buffer pointer
        1,                              // Copy one 32-bit address
        false                           // Don't start yet
    );

    // DATA CHANNEL: send 16-bit samples from the buffer to SPI
    dma_channel_config c2 = dma_channel_get_default_config(data_chan);

    channel_config_set_transfer_data_size(&c2, DMA_SIZE_16);
    channel_config_set_read_increment(&c2, true);
    channel_config_set_write_increment(&c2, false);

    // Derive DMA pacing from the actual clock and requested sample rate.
    int audio_timer = dma_claim_unused_timer(true);
    uint32_t clock_hz = clock_get_hz(clk_sys);
    uint32_t numerator = (uint64_t)AUDIO_SAMPLE_RATE * UINT16_MAX / clock_hz;
    if (numerator == 0) numerator = 1;
    uint32_t denominator = ((uint64_t)clock_hz * numerator
                          + AUDIO_SAMPLE_RATE / 2) / AUDIO_SAMPLE_RATE;
    hard_assert(numerator <= UINT16_MAX && denominator > 0
                && denominator <= UINT16_MAX);
    dma_timer_set_fraction(audio_timer, numerator, denominator);
    channel_config_set_dreq(&c2, dma_get_timer_dreq(audio_timer));

    // do not trigger the control channel afterward
    channel_config_set_chain_to(&c2, data_chan);

    dma_channel_configure(
        data_chan,
        &c2,
        &spi_get_hw(DAC_SPI)->dr, // Destination: SPI data register.
        sound_data,              // Source: sound buffer.
        SOUND_SAMPLES,           // Number of 16-bit transfers.
        false                    // Don't start yet.
    );
}


// ========================================
// === main
// ========================================
int main(){
    // set core voltage before raising processor clock
    vreg_set_voltage(VREG_VOLTAGE_1_65);
    sleep_ms(10);
    set_sys_clock_khz(SYSTEM_CLOCK_KHZ, true) ;

    // initialize stio
    stdio_init_all() ;

    mutex_init(&spawn_random_mutex);
    // Seed once. Boot timing is not guaranteed to differ on every restart.
    srand((unsigned int)time_us_64());

    // Initialize scope outputs before starting the scheduler.
    gpio_init(FRAME_PROBE);
    gpio_set_dir(FRAME_PROBE, GPIO_OUT);
    gpio_put(FRAME_PROBE, 0);
    gpio_init(PHYSICS_PROBE);
    gpio_set_dir(PHYSICS_PROBE, GPIO_OUT);
    gpio_put(PHYSICS_PROBE, 0);

    // initialize VGA
    initVGA() ;

    gpio_init(A_GPIO);
    gpio_init(B_GPIO);
    gpio_init(PULL_UP_GPIO);
    gpio_init(DETECT_PULL_UP);

    // Both rotation channels must be inputs.
    gpio_set_dir(A_GPIO, GPIO_IN);
    gpio_set_dir(B_GPIO, GPIO_IN);
    gpio_pull_up(A_GPIO);
    gpio_pull_up(B_GPIO);

    // Keep your existing GPIO 22 ↔ GPIO 26 button wiring.
    // Use input pull-ups; the switch pulls the connected pins to ground.
    gpio_set_dir(PULL_UP_GPIO, GPIO_IN);
    gpio_set_dir(DETECT_PULL_UP, GPIO_IN);
    gpio_pull_up(PULL_UP_GPIO);
    gpio_pull_up(DETECT_PULL_UP);

    prevA = gpio_get(A_GPIO) == 0;
    prevB = gpio_get(B_GPIO) == 0;
    prev_detect = gpio_get(DETECT_PULL_UP);
    gpio_set_irq_enabled_with_callback(A_GPIO,
        GPIO_IRQ_EDGE_RISE | GPIO_IRQ_EDGE_FALL, true, encoder_callback);
    gpio_set_irq_enabled(B_GPIO,
        GPIO_IRQ_EDGE_RISE | GPIO_IRQ_EDGE_FALL, true);

    // Initialize the LED pin
    gpio_init(LED_PIN);
    // Configure the LED pin as an output
    gpio_set_dir(LED_PIN, GPIO_OUT);
    rotary_encoder_num = max_array;
    // add threads
    pt_add_thread(protothread_serial);
    pt_add_thread(protothread_anim);
    pt_add_thread(poll_encoder_button);

    spi_init(DAC_SPI, DAC_SPI_BAUD);
    spi_set_format(DAC_SPI, 16, 0, 0, SPI_MSB_FIRST);
    gpio_set_function(DAC_CS_GPIO, GPIO_FUNC_SPI);
    gpio_set_function(DAC_SCK_GPIO, GPIO_FUNC_SPI);
    gpio_set_function(DAC_MOSI_GPIO, GPIO_FUNC_SPI);

    // prepare sound in memory
    buildCollisionSound();
    // initBallShape();

    // Generate pegs and derive histogram geometry before spawning any balls.
    generate_pegs();

    initAudioDMA();

    // Spawn the configured initial population before the first timed frame.
    syncBallCount();
#if USE_SECOND_CORE
    queue_init(&physics_jobs, sizeof(struct PhysicsJob), 1);
    queue_init(&physics_done, sizeof(uint32_t), 1);
    // Launch only after geometry, VGA, audio, and synchronization are ready.
    multicore_launch_core1(core1_entry);
#endif

    // start scheduler
    pt_schedule_start ;
}