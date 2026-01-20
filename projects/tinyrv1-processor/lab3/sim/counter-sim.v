//========================================================================
// counter-sim +switches=00000
//========================================================================
// Author : Christopher Batten (Cornell)
// Date   : September 7, 2024

`include "ece2300/ece2300-misc.v"
`include "ece2300/SevenSegFL.v"
`include "lab1/DisplayOpt_GL.v"
`include "lab3/Counter_16b_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Clock/Reset
  //----------------------------------------------------------------------

  // verilator lint_off BLKSEQ
  logic clk;
  initial clk = 1'b1;
  always #5 clk = ~clk;
  // verilator lint_on BLKSEQ

  logic rst;

  //----------------------------------------------------------------------
  // Instantiate counter and displays
  //----------------------------------------------------------------------

  logic        counter_load;
  logic  [4:0] counter_start;
  logic  [4:0] counter_finish;
  logic [15:0] counter_count;
  logic        counter_done;

  Counter_16b_RTL counter
  (
    .clk    (clk),
    .rst    (rst),
    .en     (1'b1),
    .load   (counter_load),
    .start  ({11'b0,counter_start}),
    .incr   (16'd1),
    .finish ({11'b0,counter_finish}),
    .count  (counter_count),
    .done   (counter_done)
  );

  `ECE2300_UNUSED( counter_count[15:5] );

  logic [6:0] counter_start_seg_tens;
  logic [6:0] counter_start_seg_ones;

  DisplayOpt_GL counter_start_display
  (
    .in       (counter_start),
    .seg_tens (counter_start_seg_tens),
    .seg_ones (counter_start_seg_ones)
  );

  logic [6:0] counter_finish_seg_tens;
  logic [6:0] counter_finish_seg_ones;

  DisplayOpt_GL counter_finish_display
  (
    .in       (counter_finish),
    .seg_tens (counter_finish_seg_tens),
    .seg_ones (counter_finish_seg_ones)
  );

  logic [6:0] counter_count_seg_tens;
  logic [6:0] counter_count_seg_ones;

  DisplayOpt_GL counter_count_display
  (
    .in       (counter_count[4:0]),
    .seg_tens (counter_count_seg_tens),
    .seg_ones (counter_count_seg_ones)
  );

  //----------------------------------------------------------------------
  // Instantiate seven-segment FL models
  //----------------------------------------------------------------------

  SevenSegFL counter_start_seg_tens_fl
  (
    .in (counter_start_seg_tens)
  );

  SevenSegFL counter_start_seg_ones_fl
  (
    .in (counter_start_seg_ones)
  );

  SevenSegFL counter_finish_seg_tens_fl
  (
    .in (counter_finish_seg_tens)
  );

  SevenSegFL counter_finish_seg_ones_fl
  (
    .in (counter_finish_seg_ones)
  );

  SevenSegFL counter_count_seg_tens_fl
  (
    .in (counter_count_seg_tens)
  );

  SevenSegFL counter_count_seg_ones_fl
  (
    .in (counter_count_seg_ones)
  );

  //----------------------------------------------------------------------
  // Perform the simulation
  //----------------------------------------------------------------------

  integer c;

  initial begin

    // Process command line arguments

    if ( $test$plusargs( "help" ) ) begin
      $display("");
      $display(" counter-sim +start-switches=00000 +finish-switches=00000");
      $display("");
      $finish;
    end

    if ( !$value$plusargs( "start-switches=%b", counter_start ) )
      counter_start = 0;

    if ( !$value$plusargs( "finish-switches=%b", counter_finish ) )
      counter_finish = 0;

    #1;

    // Reset sequence

    rst = 1;
    #10;
    rst = 0;

    // Load counter input

    counter_load = 1;
    #10;
    counter_load = 0;

    // Simulate up to 100 cycles

    for ( int cycles = 0; cycles < 100; cycles = cycles+1 ) begin

      // Display output

      $write( "\n" );
      for ( int i = 0; i < 7; i++ ) begin

        $write( "    " );
        counter_start_seg_tens_fl.write_row( i );
        $write( "  " );
        counter_start_seg_ones_fl.write_row( i );

        $write( "    " );
        counter_finish_seg_tens_fl.write_row( i );
        $write( "  " );
        counter_finish_seg_ones_fl.write_row( i );

        $write( "    " );
        counter_count_seg_tens_fl.write_row( i );
        $write( "  " );
        counter_count_seg_ones_fl.write_row( i );

        if ( i == 0 ) begin
          if ( counter_done )
            $write( "    LED: ON " );
          else
            $write( "    LED: OFF" );
        end

        $write( "\n" );
      end
      $write( "\n" );

      // Simulation is finished

      if ( counter_done )
        $finish;

      // Advance time

      #10;

      // Wait for key press

      $display( "Press enter for toggle the clock." );
      $display( "Enter q then press enter to quit." );

      c = $fgetc( 'h8000_0000 );
      if ( c == "q" )
        $finish;

      // Redraw the console

      for ( int i = 0; i < 12; i++ ) begin
        $write("\x1b[A");
      end

    end

    $finish;
  end

endmodule

