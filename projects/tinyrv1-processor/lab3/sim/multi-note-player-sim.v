//========================================================================
// note-player-sim +switches=000
//========================================================================
// Author : Christopher Batten (Cornell)
// Date   : September 7, 2024
//
// Here is the mapping from switch inputs to notes:
//
//              period period    freq
// sw  hex  dec (cycs)   (ms)    (Hz) note
// 000                                rest
// 001 0x7b 123    250   5.12  195.31 G3
// 010 0x6d 109    222   4.55  219.95 A3
// 011 0x61  97    198   4.06  246.61 B3
// 100 0x5b  91    186   3.81  262.52 C4
// 101 0x51  81    166   3.40  294.15 D4
// 110 0x48  72    148   3.03  329.92 E4
// 111 0x44  68    140   2.87  348.77 F4
//

// We use a timescale of 10s so that means the cycle time in Verilog
// timeunit is 20480/10 = 2048

`timescale 10ns/1ns
`define CYCLE_TIME 2048

`include "ece2300/ece2300-misc.v"
`include "ece2300/SevenSegFL.v"
`include "lab1/DisplayOpt_GL.v"
`include "lab3/MultiNotePlayer_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Clock/Reset
  //----------------------------------------------------------------------

  // verilator lint_off BLKSEQ
  logic clk;
  initial clk = 1'b1;
  always #(`CYCLE_TIME/2) clk = ~clk;
  // verilator lint_on BLKSEQ

  logic rst;

  //----------------------------------------------------------------------
  // Instantiate modules
  //----------------------------------------------------------------------

  logic       play_note_val;
  logic       play_note_rdy;
  logic [2:0] play_note_num;
  logic [2:0] note_sel;
  logic       note;

  MultiNotePlayer_RTL player
  (
    .clk           (clk),
    .rst           (rst),

    .note_duration (16'd1000),
    .note1_period  (8'h7B),
    .note2_period  (8'h6D),
    .note3_period  (8'h61),
    .note4_period  (8'h5B),
    .note5_period  (8'h51),
    .note6_period  (8'h48),
    .note7_period  (8'h44),

    .play_note_val (play_note_val),
    .play_note_rdy (play_note_rdy),
    .play_note_num (play_note_num),

    .note_sel      (note_sel),
    .note          (note)
  );

  `ECE2300_UNUSED( play_note_rdy );
  `ECE2300_UNUSED( note );

  // Play Note Display

  logic [6:0] play_note_seg_tens;
  logic [6:0] play_note_seg_ones;

  DisplayOpt_GL play_note_display
  (
    .in       ({2'b0,play_note_num}),
    .seg_tens (play_note_seg_tens),
    .seg_ones (play_note_seg_ones)
  );

  // Note Sel Display

  logic [6:0] note_sel_seg_tens;
  logic [6:0] note_sel_seg_ones;

  DisplayOpt_GL note_sel_display
  (
    .in       ({2'b0,note_sel}),
    .seg_tens (note_sel_seg_tens),
    .seg_ones (note_sel_seg_ones)
  );

  //----------------------------------------------------------------------
  // Instantiate seven-segment display FL models
  //----------------------------------------------------------------------

  SevenSegFL play_note_seg_tens_fl
  (
    .in (play_note_seg_tens)
  );

  SevenSegFL play_note_seg_ones_fl
  (
    .in (play_note_seg_ones)
  );

  SevenSegFL note_sel_seg_tens_fl
  (
    .in (note_sel_seg_tens)
  );

  SevenSegFL note_sel_seg_ones_fl
  (
    .in (note_sel_seg_ones)
  );

  //----------------------------------------------------------------------
  // Perform the simulation
  //----------------------------------------------------------------------

  initial begin

    $dumpfile("multi-note-player-sim.vcd");
    $dumpvars();

    // Process command line arguments

    if ( $test$plusargs( "help" ) ) begin
      $display("");
      $display(" multi-note-player-sim +switches=000");
      $display("");
      $finish;
    end

    if ( !$value$plusargs( "switches=%b", play_note_num ) )
      play_note_num = 0;

    #100;

    // Make sure valid signal is not X

    play_note_val = 0;

    // Reset sequence

    rst = 1;
    #(3*`CYCLE_TIME);
    rst = 0;
    #`CYCLE_TIME;

    // Load note

    play_note_val = 1;
    #`CYCLE_TIME;
    play_note_val = 0;

    // Display selected note

    $write( "\n" );
    for ( int i = 0; i < 7; i++ ) begin

      $write( "    " );
      play_note_seg_tens_fl.write_row( i );
      $write( "  " );
      play_note_seg_ones_fl.write_row( i );

      $write( "    " );
      note_sel_seg_tens_fl.write_row( i );
      $write( "  " );
      note_sel_seg_ones_fl.write_row( i );

      $write( "\n" );
    end
    $write( "\n" );

    // Simulate 1000 cycles

    #(`CYCLE_TIME*1000)

    // Finish

    $display( "" );
    $display( "Open multi-note-player-sim.vcd to see note waveform!" );
    $display( "" );
    $finish;

  end

endmodule

