//========================================================================
// MusicPlayer_RTL
//========================================================================

`ifndef MUSIC_PLAYER_RTL_V
`define MUSIC_PLAYER_RTL_V

`include "ece2300/ece2300-misc.v"

`include "lab3/MusicPlayerCtrl_RTL.v"
`include "lab3/MusicPlayerDpath_RTL.v"

module MusicPlayer_RTL
(
  // Clock/Reset

  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Note Parameters

  (* keep=1 *) input  logic [15:0] note_duration,
  (* keep=1 *) input  logic  [7:0] note1_period,
  (* keep=1 *) input  logic  [7:0] note2_period,
  (* keep=1 *) input  logic  [7:0] note3_period,
  (* keep=1 *) input  logic  [7:0] note4_period,
  (* keep=1 *) input  logic  [7:0] note5_period,
  (* keep=1 *) input  logic  [7:0] note6_period,
  (* keep=1 *) input  logic  [7:0] note7_period,

  // Play Song Interface

  (* keep=1 *) input  logic        play_song_val,
  (* keep=1 *) output logic        play_song_rdy,
  (* keep=1 *) input  logic  [4:0] play_song_num,

  // Memory Interface

  (* keep=1 *) output logic        mem_val,
  (* keep=1 *) output logic [15:0] mem_addr,
  (* keep=1 *) input  logic [31:0] mem_rdata,

  // Note Interface

  (* keep=1 *) output logic  [2:0] note_sel,
  (* keep=1 *) output logic        note,

  // Testing Interface

  (* keep=1 *) output logic  [1:0] state
);
  logic play_note_val, play_note_rdy, end_song;
  logic addr_counter_en, addr_counter_load;
  logic [15:0] addr_counter_start;

  // Control Unit
  MusicPlayerCtrl_RTL control_unit
  (
    .clk                (clk),
    .rst                (rst),
    .play_song_val      (play_song_val),
    .play_song_rdy      (play_song_rdy),
    .play_song_num      (play_song_num),
    .mem_val            (mem_val),
    .addr_counter_en    (addr_counter_en),
    .addr_counter_load  (addr_counter_load),
    .addr_counter_start (addr_counter_start),
    .play_note_val      (play_note_val),
    .play_note_rdy      (play_note_rdy),
    .end_song           (end_song),
    .state              (state)
  );

  // Datapath
  MusicPlayerDpath_RTL datapath 
  (
    .clk                (clk),
    .rst                (rst),
    .note_duration      (note_duration),
    .note1_period       (note1_period),
    .note2_period       (note2_period),
    .note3_period       (note3_period),
    .note4_period       (note4_period),
    .note5_period       (note5_period),
    .note6_period       (note6_period),
    .note7_period       (note7_period),
    .mem_addr           (mem_addr),
    .mem_rdata          (mem_rdata),
    .note_sel           (note_sel),
    .note               (note),
    .addr_counter_en    (addr_counter_en),
    .addr_counter_load  (addr_counter_load),
    .addr_counter_start (addr_counter_start),
    .play_note_val      (play_note_val),
    .play_note_rdy      (play_note_rdy),
    .end_song           (end_song)
  );

endmodule

`endif /* MUSIC_PLAYER_RTL_V */
