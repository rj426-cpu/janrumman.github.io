//========================================================================
// calc-sim +in0-switches=00000 +in1-switches=00000 +button=0
//========================================================================
// Author : Christopher Batten (Cornell)
// Date   : September 7, 2024

`include "ece2300/SevenSegFL.v"
`include "lab1/DisplayOpt_GL.v"
`include "lab2/Calculator_GL.v"

module Top();

  //----------------------------------------------------------------------
  // Instantiate calculator and displays
  //----------------------------------------------------------------------

  logic  [4:0] in0;
  logic  [4:0] in1;
  logic        op;
  logic [15:0] result;

  Calculator_GL calc
  (
    .in0    ({11'b0,in0}),
    .in1    ({11'b0,in1}),
    .op     (op),
    .result (result)
  );

  logic [6:0] in0_seg_tens;
  logic [6:0] in0_seg_ones;

  DisplayOpt_GL display_in0
  (
    .in       (in0),
    .seg_tens (in0_seg_tens),
    .seg_ones (in0_seg_ones)
  );

  logic [6:0] in1_seg_tens;
  logic [6:0] in1_seg_ones;

  DisplayOpt_GL display_in1
  (
    .in       (in1),
    .seg_tens (in1_seg_tens),
    .seg_ones (in1_seg_ones)
  );

  logic [6:0] result_seg_tens;
  logic [6:0] result_seg_ones;

  DisplayOpt_GL display_result
  (
    .in       (result[4:0]),
    .seg_tens (result_seg_tens),
    .seg_ones (result_seg_ones)
  );

  //----------------------------------------------------------------------
  // Instantiate seven-segment FL models
  //----------------------------------------------------------------------

  SevenSegFL in0_seg_tens_fl
  (
    .in (in0_seg_tens)
  );

  SevenSegFL in0_seg_ones_fl
  (
    .in (in0_seg_ones)
  );

  SevenSegFL in1_seg_tens_fl
  (
    .in (in1_seg_tens)
  );

  SevenSegFL in1_seg_ones_fl
  (
    .in (in1_seg_ones)
  );

  SevenSegFL result_seg_tens_fl
  (
    .in (result_seg_tens)
  );

  SevenSegFL result_seg_ones_fl
  (
    .in (result_seg_ones)
  );

  //----------------------------------------------------------------------
  // Perform the simulation
  //----------------------------------------------------------------------

  initial begin

    // Process command line arguments

    if ( $test$plusargs( "help" ) ) begin
      $display("");
      $display(" calc-sim +in0-switches=00000 +in1-switches=00000 +button=0");
      $display("");
      $finish;
    end

    if ( !$value$plusargs( "in0-switches=%b", in0 ) )
      in0 = 5'b00000;

    if ( !$value$plusargs( "in1-switches=%b", in1 ) )
      in1 = 5'b00000;

    if ( !$value$plusargs( "button=%b", op ) )
      op = 1'b0;

    // Advance time

    #10;

    // Display output

    $write( "\n" );
    $display( "in0-switches = %b", in0 );
    $display( "in1-switches = %b", in1 );
    $display( "op           = %b", op );
    $display( "result       = %b", result );

    $write( "\n" );
    for ( int i = 0; i < 7; i++ ) begin

      $write( "  " );
      in0_seg_tens_fl.write_row( i );
      $write( "  " );
      in0_seg_ones_fl.write_row( i );

      $write( "    " );
      in1_seg_tens_fl.write_row( i );
      $write( "  " );
      in1_seg_ones_fl.write_row( i );

      $write( "    " );
      result_seg_tens_fl.write_row( i );
      $write( "  " );
      result_seg_ones_fl.write_row( i );

      $write( "\n" );
    end
    $write( "\n" );

    $finish;
  end

endmodule

