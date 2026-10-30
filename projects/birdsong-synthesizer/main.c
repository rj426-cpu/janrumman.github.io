/*
 * Keypad-controlled DDS tone generator with record/playback
 *
 * Overview
 * --------
 * A 50 kHz timer ISR runs a direct digital synthesis (DDS) oscillator and pushes
 * samples to an SPI DAC. The audible frequency is controlled by a potentiometer
 * read at 100 Hz. Frequency "gestures" (pot sweeps) can be recorded into one of
 * nine slots and played back later, and slots can be chained into a sequence.
 *
 * Keypad map
 * ----------
 *   0        toggle the tone on/off (gate)
 *   1..9     context dependent:
 *              - after '*'  -> start recording into slot (key-1)
 *              - in seq mode -> append slot to the sequence
 *              - otherwise  -> play back slot (key-1)
 *   *        arm record mode (next digit selects the slot)
 *   #        first press: start collecting a sequence
 *            second press: stop collecting and play the sequence back
 *
 * Threads:
 *   protothread_freq    - 100 Hz: reads pot, records/plays back, sets DDS frequency
 *   protothread_keypad  - ~33 Hz: scans + debounces keypad, sets flags
 * ISR:
 *   alarm_irq           - 50 kHz: DDS sample out to DAC
 */
#include "hardware/gpio.h"
#include "hardware/timer.h"
#include "hardware/irq.h"
#include "hardware/adc.h"
#include "hardware/spi.h"
#include "hardware/clocks.h"

#include "pico/stdlib.h"

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include <stdbool.h>
#include "pt_cornell_rp2040_v1_4.h"

// ==========================================
// === pins / hardware
// ==========================================
#define LED_PIN 25
#define ADC_PIN 26    // analog input
#define ADC_MUX 0     // ADC input 0

#define ALARM_NUM 0   // which hardware alarm drives the sample clock
#define ALARM_IRQ timer_hardware_alarm_get_irq_num(timer_hw, ALARM_NUM)

#define two32 4294967296.0   // 2^32, the full range of the phase accumulator
#define Fs 50000             // DDS sample rate (Hz), must match the alarm period
#define DELAY 20             // alarm reload in microseconds -> 1/20us = 50 kHz

// MCP4822-style DAC command words: config bits in the top nibble, 12-bit data below
#define DAC_config_chan_A 0b0011000000000000
#define DAC_config_chan_B 0b1011000000000000
#define DAC_CHANNEL DAC_config_chan_A

#define PIN_MISO 4
#define PIN_CS   5
#define PIN_SCK  6
#define PIN_MOSI 7
#define SPI_PORT spi0

#define ISR_GPIO 2   // toggled high for the duration of the ISR, for scoping ISR time

// Keypad occupies 7 consecutive GPIOs starting here:
//   BASE+0..BASE+3 are the four row drives (outputs)
//   BASE+4..BASE+6 are the three column senses (inputs, pulled up)
#define BASE_KEYPAD_PIN 9
#define KEYROWS         4
#define NUMKEYS         12

#define ASTERISK_KEY 10   // index into keycodes[] for '*'
#define POUND_KEY 11      // index into keycodes[] for '#'
// ==========================================
// === recording storage
// ==========================================
#define NUM_SLOTS   9      // one recording slot per digit key 1-9
#define MAX_SAMPLES 1000   // per slot; at 100 Hz this is 10 seconds
#define MAX_SEQUENCE 1000  // max slots chainable into one sequence

float rec_buf[NUM_SLOTS][MAX_SAMPLES];  // recorded frequency values, Hz
int   rec_len[NUM_SLOTS];               // how many samples each slot actually holds

int seq_buf[MAX_SEQUENCE];              // sequence of slot numbers (stored 1-based)

// ==========================================
// === shared state (written by keypad thread, read by freq thread)
// ==========================================
volatile bool toggle_frequency =  true;   // tone gate (key 0)
volatile bool record_mode      = false;   // armed by '*'
volatile bool recording        = false;   // actively capturing pot values into rec_buf
volatile bool playing          = false;   // actively replaying one slot
volatile bool sequence_mode    = false;   // collecting slot numbers into seq_buf
volatile bool seq_playing      = false;   // stepping through seq_buf


volatile int  rec_slot          =  0;   // slot currently being recorded into
volatile int  play_slot         =  0;   // slot currently being played back
volatile int  play_idx          =  0;   // read cursor into rec_buf[play_slot]
volatile int  seq_idx           = -1;  // position in seq_buf; -1 means "not started"
volatile int  seq_len           =  0;   // number of entries collected in seq_buf

// ==========================================
// === DDS
// ==========================================
volatile unsigned int phase_accum_main;  // 32-bit phase, wraps naturally at 2^32
volatile unsigned int phase_incr_main;   // per-sample phase step; sets output frequency

// Convert a frequency in Hz into the phase step the ISR adds each sample.
void set_frequency(float frequency) {
    phase_incr_main = (unsigned int)((frequency * two32) / Fs);
}

uint16_t DAC_data;   // one 16-bit SPI word: DAC config + sample

#define sine_table_size 256
volatile int sin_table[sine_table_size];   // one period of a sine, +/-2047

// ==========================================
// === keypad tables
// ==========================================
// keycodes[i] is the 7-bit (row drive | column sense) pattern seen when key i is
// down. Index order is 0,1,2,...,9,'*','#'.
unsigned int keycodes[NUMKEYS] = { 0x57, 0x6E, 0x5E, 0x3E, 0x6D,
                                   0x5D, 0x3D, 0x6B, 0x5B, 0x3B,
                                   0x67, 0x37 };
// One-low-at-a-time row drive patterns, walked during the scan.
unsigned int scancodes[KEYROWS] = { 0xE, 0xD, 0xB, 0x7 };
unsigned int button = 0x70;   // mask isolating the three column-sense bits

// ==================================================
// === frequency thread (100 Hz)
// ==================================================
// Single owner of set_frequency(). Reads pot, records or plays back,
// then writes exactly one frequency to the DDS.


// Kick off playback of a slot from the beginning.
void play_sound(int slot){
    play_slot = slot;
    playing = true;
    play_idx = 0;
}
static PT_THREAD (protothread_freq(struct pt *pt))
{
    PT_BEGIN(pt);

    // static so the values survive across PT_YIELD (protothreads have no stack)
    static float pot_freq;
    static float f;

    while(1) {
        gpio_put(LED_PIN, !gpio_get(LED_PIN));   // heartbeat: shows the thread is running

        // Map the 12-bit ADC reading onto 0..10 kHz
        pot_freq = ((float)adc_read() / 4095.0f) * 10000.0f;
        f = pot_freq;   // default: play the live pot value

        if (recording) {
            // Capture the live pot value; silently stop appending once the slot is full
            if (rec_len[rec_slot] < MAX_SAMPLES) {
                rec_buf[rec_slot][rec_len[rec_slot]] = pot_freq;
                rec_len[rec_slot]++;
            }
        }
        else if (seq_playing){
            // Advance to the next slot in the sequence, but only once the
            // previous slot has finished playing
            if (!playing){
                seq_idx++;
                if (seq_idx<seq_len){
                    play_slot = seq_buf[seq_idx]-1;   // seq_buf stores 1-based key numbers
                    play_sound(play_slot);
                } else{
                    // Ran off the end: reset and stop the sequence
                    seq_idx=-1;
                    seq_playing = false;
                }
            }
        }
        
        if (playing) {
            // Override the pot with the next recorded sample
            if (play_idx < rec_len[play_slot]) {
                f = rec_buf[play_slot][play_idx];
                play_idx++;
            }
            else {
                playing = false;   // slot exhausted; next pass falls back to the pot
            }
        }

        // Exactly one write to the DDS per pass. Gate closed -> DC (silence).
        set_frequency(toggle_frequency ? f : 0.0f);

        if (playing){
            PT_YIELD_usec(1000);   // 10 Hz
        }
        else{
            PT_YIELD_usec(10000);   // 100 Hz
        }
        
    }
    PT_END(pt);
}

// ==================================================
// === debounce
// ==================================================
// Four-state machine: a key must read the same on two consecutive scans
// (~30 ms apart) before a press or release is accepted.
typedef enum {NOT_PRESSED, MAYBE_PRESSED, PRESSED, MAYBE_NOT_PRESSED} ButtonState;

ButtonState currentState = NOT_PRESSED;
static int possible;   // candidate key index being confirmed

// Returns the key index on the press edge (MAYBE_PRESSED -> PRESSED), else -1.
int keypress_debounce(int i){
    switch(currentState){
        case NOT_PRESSED:
            // First sighting of any key: remember it and wait for confirmation
            if (i != -1){
                possible = i;
                currentState = MAYBE_PRESSED;
            }
            break;

        case MAYBE_PRESSED:
            // Same key twice in a row -> accept, and emit the edge exactly once
            if (i == possible){
                currentState = PRESSED;
                return i;
            }
            else {
                currentState = NOT_PRESSED;   // glitch or bounce; discard
            }
            break;

        case PRESSED:
            // Held down. Anything else (including -1) starts the release check.
            if (i != possible){
                currentState = MAYBE_NOT_PRESSED;
            }
            break;

        case MAYBE_NOT_PRESSED:
            if (i == possible){
                currentState = PRESSED;       // bounce during release; still held
            }
            else {
                currentState = NOT_PRESSED;   // release confirmed
            }
            break;
    }
    return -1;
}

// ==================================================
// === keypad thread (~33 Hz)
// ==================================================
static PT_THREAD (protothread_keypad(struct pt *pt))
{
    PT_BEGIN(pt);

    static int i;              // row index during scan, then key index
    static int k;              // debounced key index on a press edge, else -1
    static uint32_t keypad;    // raw 7-bit row|column reading

    while(1) {

        // Scan the keypad: drive one row low at a time and look for a column
        // sense that has been pulled low by a closed switch.
        for (i=0; i<KEYROWS; i++) {
            gpio_put_masked((0xF << BASE_KEYPAD_PIN),
                            (scancodes[i] << BASE_KEYPAD_PIN));
            sleep_us(1);   // let the line settle before sampling
            keypad = ((gpio_get_all() >> BASE_KEYPAD_PIN) & 0x7F);
            if ((~keypad) & button) break;   // some column is low -> key found in this row
        }
        if ((~keypad) & button) {
            // Look up the full row|column pattern in the key table
            for (i=0; i<NUMKEYS; i++) {
                if (keypad == keycodes[i]) break;
            }
            if (i==NUMKEYS) i = -1;   // unrecognised pattern (e.g. two keys down)
        }
        else i = -1;                  // nothing pressed

        // Debounce; k is the key index on a press edge, else -1
        k = keypress_debounce(i);

        if (k == ASTERISK_KEY) {
            // Arm recording; the next digit chooses the slot
            record_mode = true;
            printf("Record mode armed\n");
        }
        else if (k == POUND_KEY) {
            if (!sequence_mode) {
                sequence_mode = true;   // start collecting slot numbers
                seq_len = 0;
            } else {
                sequence_mode = false;  // done collecting -> play the sequence
                seq_idx = -1;
                seq_playing = true;
            }
        }
        else if (k == 0) {
            toggle_frequency = !toggle_frequency;   // mute / unmute
        }
        else if (k >= 1 && k <= 9) {
            if (record_mode) {
                // Select the slot, clear it, and start capturing
                rec_slot = k - 1;
                rec_len[rec_slot] = 0;
                recording = true;
            }
            else if(sequence_mode){
                seq_buf[seq_len++] = k;   // append to the sequence being built
            }
            else {
                play_sound(k-1);          // immediate playback of one slot
            }
        }

        // Recording runs for as long as the digit key is held; the confirmed
        // release (NOT_PRESSED) ends it.
        if (recording && currentState == NOT_PRESSED) {
            recording = false;
            record_mode = false;
            printf("Recorded %d samples\n", rec_len[rec_slot]);
        }

        PT_YIELD_usec(30000);   // ~33 Hz scan rate, also sets the debounce interval
    }
    PT_END(pt);
}

// ==================================================
// === Interrupt Service Routine (50 kHz DDS)
// ==================================================
static void alarm_irq(void) {
    gpio_put(ISR_GPIO, 1);   // raise timing pin: ISR entry

    hw_clear_bits(&timer_hw->intr, 1u << ALARM_NUM);          // acknowledge this alarm
    timer_hw->alarm[ALARM_NUM] = timer_hw->timerawl + DELAY;  // rearm for the next sample

    // DDS core: step the phase, use the top 8 bits as the table index
    phase_accum_main += phase_incr_main;
    int sine_value = sin_table[phase_accum_main >> 24];

    // Shift the signed sample into the DAC's unsigned 12-bit range and send it
    DAC_data = DAC_CHANNEL | ((sine_value + 2048) & 0xffff);
    spi_write16_blocking(SPI_PORT, &DAC_data, 1);

    gpio_put(ISR_GPIO, 0);   // drop timing pin: ISR exit
}

// ========================================
// === main
// ========================================
int main(){
    // Overclock FIRST, before any peripheral clocks are derived
    set_sys_clock_khz(150000, true);

    stdio_init_all();
    printf("\n\rProtothreads RP2040 v1.4\n\r");

    // ADC - potentiometer on ADC0
    adc_init();
    adc_gpio_init(ADC_PIN);
    adc_select_input(ADC_MUX);

    // LED
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);
    gpio_put(LED_PIN, true);

    // SPI / DAC - 16-bit frames, mode 0, fast enough to finish well inside 20 us
    spi_init(SPI_PORT, 20000000);
    spi_set_format(SPI_PORT, 16, 0, 0, 0);
    gpio_set_function(PIN_MISO, GPIO_FUNC_SPI);
    gpio_set_function(PIN_SCK,  GPIO_FUNC_SPI);
    gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);
    gpio_set_function(PIN_CS,   GPIO_FUNC_SPI);

    // ISR timing pin
    gpio_init(ISR_GPIO);
    gpio_set_dir(ISR_GPIO, GPIO_OUT);
    gpio_put(ISR_GPIO, 0);

    // Sine table - one full period scaled to the DAC's half-range
    for (int ii = 0; ii < sine_table_size; ii++) {
        sin_table[ii] = (int)(2047 * sin((float)ii * 6.283 / (float)sine_table_size));
    }

    // Keypad GPIO: rows are driven outputs (idle high), columns are pulled-up inputs
    gpio_init_mask((0x7F << BASE_KEYPAD_PIN));
    gpio_set_dir((BASE_KEYPAD_PIN+4), GPIO_IN);
    gpio_set_dir((BASE_KEYPAD_PIN+5), GPIO_IN);
    gpio_set_dir((BASE_KEYPAD_PIN+6), GPIO_IN);
    gpio_set_dir_out_masked((0xF << BASE_KEYPAD_PIN));
    gpio_put_masked((0xF << BASE_KEYPAD_PIN), (0xF << BASE_KEYPAD_PIN));
    gpio_pull_up((BASE_KEYPAD_PIN+4));
    gpio_pull_up((BASE_KEYPAD_PIN+5));
    gpio_pull_up((BASE_KEYPAD_PIN+6));

    // DDS timer interrupt (arm last so nothing fires before setup is done)
    hw_set_bits(&timer_hw->inte, 1u << ALARM_NUM);
    irq_set_exclusive_handler(ALARM_IRQ, alarm_irq);
    irq_set_enabled(ALARM_IRQ, true);
    timer_hw->alarm[ALARM_NUM] = timer_hw->timerawl + DELAY;

    // Threads
    pt_add_thread(protothread_freq);
    pt_add_thread(protothread_keypad);


    pt_schedule_start;
}