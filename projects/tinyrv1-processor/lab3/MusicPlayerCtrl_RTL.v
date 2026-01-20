//========================================================================
// MusicPlayerCtrl_RTL
//========================================================================

`ifndef MUSIC_PLAYER_CTRL_RTL_V
`define MUSIC_PLAYER_CTRL_RTL_V

`include "lab3/Register_16b_RTL.v"

module MusicPlayerCtrl_RTL
(
  // Clock and Reset

  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Play Song Interface

  (* keep=1 *) input  logic        play_song_val,
  (* keep=1 *) output logic        play_song_rdy,
  (* keep=1 *) input  logic  [4:0] play_song_num,

  // Memory Interface

  (* keep=1 *) output logic        mem_val,

  // Control Signals (ctrl -> dpath)

  (* keep=1 *) output logic        addr_counter_en,
  (* keep=1 *) output logic        addr_counter_load,
  (* keep=1 *) output logic [15:0] addr_counter_start,
  (* keep=1 *) output logic        play_note_val,

  // Status Signals (dpath -> ctrl)

  (* keep=1 *) input  logic        play_note_rdy,
  (* keep=1 *) input  logic        end_song,

  // Testing Interface

  (* keep=1 *) output logic  [1:0] state
);

  // verilator lint_off UNUSEDPARAM
  localparam STATE_RESET     = 2'b00;
  localparam STATE_IDLE      = 2'b01;
  localparam STATE_PLAY_NOTE = 2'b10;
  localparam STATE_WAIT_NOTE = 2'b11;
  // verilator lint_on UNUSEDPARAM

  // Signals for Register
   logic [1:0 ] next_state;
   logic [15:0]      reg_q;
   logic [15:0]      reg_d;
   assign state = reg_q[1:0];
   assign reg_d = {14'b0, next_state};

  // Instantiate a Register to store State 
  Register_16b_RTL reg0
  (
    .clk (clk),
    .rst (rst),
    .en  (1'b1),
    .d(reg_d),
    .q(reg_q)
  );

  // Next-state combinational logic
  always_comb begin
    case(state)
    STATE_RESET: next_state = STATE_IDLE; 
    STATE_IDLE: next_state = (!play_song_val) ? STATE_IDLE : STATE_PLAY_NOTE;
    STATE_PLAY_NOTE: next_state = (!end_song) ? STATE_WAIT_NOTE : STATE_IDLE;
    STATE_WAIT_NOTE: next_state = (!play_note_rdy) ? STATE_WAIT_NOTE : STATE_PLAY_NOTE; 
    default: next_state = 'x;
    endcase
  end

  // Output combinational logic
  always_comb begin
    case(state)
    STATE_RESET: begin 
      play_song_rdy = 1'b0;
      mem_val = 1'b0;
      addr_counter_en = 1'b0;
      addr_counter_load = 1'b0;
      addr_counter_start = 16'b0;
      play_note_val = 1'b0;

    end
    STATE_IDLE: begin 
      play_song_rdy = 1'b1;
      mem_val = 1'b0;
      addr_counter_en = 1'b0;
      addr_counter_load = 1'b1; 
      addr_counter_start = { 2'b0, play_song_num, 9'b0 };
      play_note_val = 1'b0; 
      end

    STATE_PLAY_NOTE: begin  
      play_song_rdy = 1'b0;
      mem_val = 1'b1;
      addr_counter_en = 1'b1;
      addr_counter_load = 1'b0; 
      addr_counter_start = { 2'b0, play_song_num, 9'b0 };
      play_note_val = (!end_song) ? 1'b1 : 1'b0;
      end
      
    STATE_WAIT_NOTE: begin 
      play_song_rdy = 1'b0;
      mem_val = 1'b0;
      addr_counter_en = 1'b0;
      addr_counter_load = 1'b0; 
      addr_counter_start = { 2'b0, play_song_num, 9'b0 };
      play_note_val = 1'b0; 
      end
    endcase
  end

  `ECE2300_UNUSED(reg_q[15:2]);



endmodule

`endif /* MUSIC_PLAYER_CTRL_RTL_V */
