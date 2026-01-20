//========================================================================
// note-player-sim +switches=0000
//========================================================================
// Author : Christopher Batten (Cornell)
// Date   : September 7, 2024
//

// We use a timescale of 10s so that means the cycle time in Verilog
// timeunit is 20480/10 = 2048

`timescale 10ns/1ns
`define CYCLE_TIME 2048

`include "ece2300/ece2300-misc.v"
`include "ece2300/SevenSegFL.v"
`include "lab1/DisplayOpt_GL.v"
`include "lab3/MusicMem_RTL.v"
`include "lab3/MusicPlayer_RTL.v"

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

  logic        mem_val;
  logic [15:0] mem_addr;
  logic [31:0] mem_rdata;

  MusicMem_RTL mem
  (
    .mem_val   (mem_val),
    .mem_addr  (mem_addr),
    .mem_rdata (mem_rdata)
  );

  logic        play_song_val;
  logic        play_song_rdy;
  logic  [4:0] play_song_num;
  logic  [2:0] note_sel;
  logic        note;
  logic  [1:0] state;

  MusicPlayer_RTL player
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

    .play_song_val (play_song_val),
    .play_song_rdy (play_song_rdy),
    .play_song_num (play_song_num),

    .mem_val       (mem_val),
    .mem_addr      (mem_addr),
    .mem_rdata     (mem_rdata),

    .note_sel      (note_sel),
    .note          (note),

    .state         (state)
  );

  `ECE2300_UNUSED( play_song_rdy );
  `ECE2300_UNUSED( note );
  `ECE2300_UNUSED( state );

  // Play Song Display

  logic [6:0] play_song_seg_tens;
  logic [6:0] play_song_seg_ones;

  DisplayOpt_GL play_song_display
  (
    .in       (play_song_num),
    .seg_tens (play_song_seg_tens),
    .seg_ones (play_song_seg_ones)
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

  SevenSegFL play_song_seg_tens_fl
  (
    .in (play_song_seg_tens)
  );

  SevenSegFL play_song_seg_ones_fl
  (
    .in (play_song_seg_ones)
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

    $dumpfile("music-player-sim.vcd");
    $dumpvars();

    // Process command line arguments

    if ( $test$plusargs( "help" ) ) begin
      $display("");
      $display(" music-player-sim +switches=000");
      $display("");
      $finish;
    end

    if ( !$value$plusargs( "switches=%b", play_song_num ) )
      play_song_num = 0;

    if ( play_song_num > 1 )
      play_song_num = 0;

    #100;

    // Reset sequence

    rst = 1;
    #(3*`CYCLE_TIME);
    rst = 0;
    #`CYCLE_TIME;

    // Load note

    play_song_val = 1;
    #`CYCLE_TIME;
    play_song_val = 0;

    // Display selected note

    $write( "\n" );
    for ( int i = 0; i < 7; i++ ) begin

      $write( "    " );
      play_song_seg_tens_fl.write_row( i );
      $write( "  " );
      play_song_seg_ones_fl.write_row( i );

      $write( "    " );
      note_sel_seg_tens_fl.write_row( i );
      $write( "  " );
      note_sel_seg_ones_fl.write_row( i );

      $write( "\n" );
    end
    $write( "\n" );

   // Simulate 64,000 cycles

    #(`CYCLE_TIME*64*1000)

    // Finish

    $display( "" );
    $display( "Open music-player-sim.vcd to see note waveform!" );
    $display( "" );
    $finish;

  end

endmodule

