//========================================================================
// display-sim +switches=00000
//========================================================================
// Author : Christopher Batten (Cornell)
// Date   : September 7, 2024

`include "ece2300/SevenSegFL.v"
`include "lab1/DisplayUnopt_GL.v"

module Top();

  //----------------------------------------------------------------------
  // Instantiate display and connect to seven segment FL models
  //----------------------------------------------------------------------

  logic [4:0] in;
  logic [6:0] seg_tens;
  logic [6:0] seg_ones;

  DisplayUnopt_GL dut
  (
    .in       (in),
    .seg_tens (seg_tens),
    .seg_ones (seg_ones)
  );

  SevenSegFL seg_tens_fl
  (
    .in (seg_tens)
  );

  SevenSegFL seg_ones_fl
  (
    .in (seg_ones)
  );

  //----------------------------------------------------------------------
  // Perform the simulation
  //----------------------------------------------------------------------

  initial begin

    // Process command line arguments

    if ( $test$plusargs( "help" ) ) begin
      $display("");
      $display(" display-sim +switches=00000");
      $display("");
      $finish;
    end

    if ( !$value$plusargs( "switches=%b", in ) )
      in = 5'b00000;

    // Advance time

    #10;

    // Display output

    $write( "\n" );
    $display( "switches = %b", in );
    $display( "seg_tens = %b", seg_tens );
    $display( "seg_ones = %b", seg_ones );

    $write( "\n" );
    for ( int i = 0; i < 7; i++ ) begin
      $write( "  " );
      seg_tens_fl.write_row( i );
      $write( "  " );
      seg_ones_fl.write_row( i );
      $write( "\n" );
    end
    $write( "\n" );

    $finish;
  end

endmodule

