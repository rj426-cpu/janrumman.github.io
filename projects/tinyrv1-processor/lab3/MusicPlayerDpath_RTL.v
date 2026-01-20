//========================================================================
// MusicPlayerDpath_RTL
//========================================================================

`ifndef MUSICPLAYERDPATH_RTL_V
`define MUSICPLAYERDPATH_RTL_V

`include "lab3/Counter_16b_RTL.v"
`include "lab3/MultiNotePlayer_RTL.v"
`include "lab3/EqComparator_16b_RTL.v"

module MusicPlayerDpath_RTL
(
  // Clock and Reset

  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Note Playback Parameters

  (* keep=1 *) input  logic [15:0] note_duration,
  (* keep=1 *) input  logic  [7:0] note1_period,
  (* keep=1 *) input  logic  [7:0] note2_period,
  (* keep=1 *) input  logic  [7:0] note3_period,
  (* keep=1 *) input  logic  [7:0] note4_period,
  (* keep=1 *) input  logic  [7:0] note5_period,
  (* keep=1 *) input  logic  [7:0] note6_period,
  (* keep=1 *) input  logic  [7:0] note7_period,

  // Memory Interface

  (* keep=1 *) output logic [15:0] mem_addr,
  (* keep=1 *) input  logic [31:0] mem_rdata,

  // Note Interface

  (* keep=1 *) output logic  [2:0] note_sel,
  (* keep=1 *) output logic        note,

  // Control Signals (ctrl -> dpath)

  (* keep=1 *) input  logic        addr_counter_en,
  (* keep=1 *) input  logic        addr_counter_load,
  (* keep=1 *) input  logic [15:0] addr_counter_start,
  (* keep=1 *) input  logic        play_note_val,

  // Status Signals (dpath -> ctrl)

  (* keep=1 *) output logic        play_note_rdy,
  (* keep=1 *) output logic        end_song
);

  // Address Counter
  logic        done;

  Counter_16b_RTL address_count
  (
    .clk    (clk),
    .rst    (rst),
    .en     (addr_counter_en),
    .load   (addr_counter_load),
    .start  (addr_counter_start),
    .incr   (16'd4),
    .finish (16'hFFFF),
    .count  (mem_addr),
    .done   (done)
  );

  // Equality Comparator
  EqComparator_16b_RTL eq_comparator 
  (
    .in0 (16'hFFFF),
    .in1 (mem_rdata[15:0]),
    .eq  (end_song)
  );

  // Multi-Note Player
  MultiNotePlayer_RTL multi_note_player
  (
    .clk            (clk),
    .rst            (rst),
    .note_duration  (note_duration),
    .note1_period   (note1_period),
    .note2_period   (note2_period),
    .note3_period   (note3_period),
    .note4_period   (note4_period),
    .note5_period   (note5_period),
    .note6_period   (note6_period),
    .note7_period   (note7_period),
    .play_note_val  (play_note_val),
    .play_note_rdy  (play_note_rdy),
    .play_note_num  (mem_rdata[2:0]),
    .note_sel       (note_sel),
    .note           (note)
  );

`ECE2300_UNUSED(done);
`ECE2300_UNUSED(mem_rdata[31:3]);

endmodule

`endif /* MUSICPLAYERDPATH_RTL_V */
