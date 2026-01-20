//========================================================================
// Mux8_1b_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab3/Mux8_1b_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  CombinationalTestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic       in0;
  logic       in1;
  logic       in2;
  logic       in3;
  logic       in4;
  logic       in5;
  logic       in6;
  logic       in7;
  logic [2:0] sel;
  logic       out;

  Mux8_1b_RTL dut
  (
    .in0 (in0),
    .in1 (in1),
    .in2 (in2),
    .in3 (in3),
    .in4 (in4),
    .in5 (in5),
    .in6 (in6),
    .in7 (in7),
    .sel (sel),
    .out (out)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // We set the inputs, wait 8 tau, check the outputs, wait 2 tau. Each
  // check will take a total of 10 tau.

  task check
  (
    input logic       in0_,
    input logic       in1_,
    input logic       in2_,
    input logic       in3_,
    input logic       in4_,
    input logic       in5_,
    input logic       in6_,
    input logic       in7_,
    input logic [2:0] sel_,
    input logic       out_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in0 = in0_;
      in1 = in1_;
      in2 = in2_;
      in3 = in3_;
      in4 = in4_;
      in5 = in5_;
      in6 = in6_;
      in7 = in7_;
      sel = sel_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b %b %b %b %b %b %b %b %b > %b", t.cycles,
                  in0, in1, in2, in3, in4, in5, in6, in7, sel, out );

      `ECE2300_CHECK_EQ( out, out_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0 in1 in2 in3 in4 in5 in6 in7 sel out
    check( 0,  0,  0,  0,  0,  0,  0,  0,  0,  0 );
    check( 0,  0,  0,  0,  0,  0,  0,  0,  1,  0 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_2_directed
  //----------------------------------------------------------------------

  task test_case_2_directed();
    t.test_case_begin( "test_case_2_directed" );

    //     in0 in1 in2 in3 in4 in5 in6 in7 sel out
    check( 1,  0,  0,  0,  0,  0,  0,  0,  0,  1 );
    check( 0,  1,  0,  0,  0,  0,  0,  0,  1,  1 );
    check( 0,  0,  1,  0,  0,  0,  0,  0,  2,  1 );
    check( 0,  0,  0,  1,  0,  0,  0,  0,  3,  1 );
    check( 0,  0,  0,  0,  1,  0,  0,  0,  4,  1 );
    check( 0,  0,  0,  0,  0,  1,  0,  0,  5,  1 );
    check( 0,  0,  0,  0,  0,  0,  1,  0,  6,  1 );
    check( 0,  0,  0,  0,  0,  0,  0,  1,  7,  1 );

    check( 1,  1,  1,  1,  1,  1,  1,  0,  7,  0 );
    check( 1,  1,  1,  1,  1,  1,  0,  1,  6,  0 );
    check( 1,  1,  1,  1,  1,  0,  1,  1,  5,  0 );
    check( 1,  1,  1,  1,  0,  1,  1,  1,  4,  0 );
    check( 1,  1,  1,  0,  1,  1,  1,  1,  3,  0 );
    check( 1,  1,  0,  1,  1,  1,  1,  1,  2,  0 );
    check( 1,  0,  1,  1,  1,  1,  1,  1,  1,  0 );
    check( 0,  1,  1,  1,  1,  1,  1,  1,  0,  0 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_random
  //----------------------------------------------------------------------

  logic       rand_in0;
  logic       rand_in1;
  logic       rand_in2;
  logic       rand_in3;
  logic       rand_in4;
  logic       rand_in5;
  logic       rand_in6;
  logic       rand_in7;
  logic [2:0] rand_sel;
  logic       rand_out;

  task test_case_3_random();
    t.test_case_begin( "test_case_3_random" );

    for ( int i = 0; i < 50; i = i+1 ) begin

      // Generate random values for in0, in1, sel

      rand_in0 = 1'($urandom(t.seed));
      rand_in1 = 1'($urandom(t.seed));
      rand_in2 = 1'($urandom(t.seed));
      rand_in3 = 1'($urandom(t.seed));
      rand_in4 = 1'($urandom(t.seed));
      rand_in5 = 1'($urandom(t.seed));
      rand_in6 = 1'($urandom(t.seed));
      rand_in7 = 1'($urandom(t.seed));
      rand_sel = 3'($urandom(t.seed));

      // Determine correct answer

      if ( rand_sel == 0 )
        rand_out = rand_in0;
      else if ( rand_sel == 1 )
        rand_out = rand_in1;
      else if ( rand_sel == 2 )
        rand_out = rand_in2;
      else if ( rand_sel == 3 )
        rand_out = rand_in3;
      else if ( rand_sel == 4 )
        rand_out = rand_in4;
      else if ( rand_sel == 5 )
        rand_out = rand_in5;
      else if ( rand_sel == 6 )
        rand_out = rand_in6;
      else
        rand_out = rand_in7;

      // Check DUT output matches correct answer

      check( rand_in0, rand_in1, rand_in2, rand_in3,
             rand_in4, rand_in5, rand_in6, rand_in7,
             rand_sel, rand_out );

    end

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_4_xprop
  //----------------------------------------------------------------------

  task test_case_4_xprop();
    t.test_case_begin( "test_case_4_xprop" );

    //     in0 in1 in2 in3 in4 in5 in6 in7 sel out
    check( 'x, 'x, 'x, 'x, 'x, 'x, 'x, 'x, 'x, 'x );

    check(  0,  0,  0,  0,  0,  0,  0,  0, 'x, 'x );
    check(  0,  1,  0,  1,  0,  1,  0,  1, 'x, 'x );
    check(  1,  0,  1,  0,  1,  0,  1,  0, 'x, 'x );
    check(  1,  1,  1,  1,  1,  1,  1,  1, 'x, 'x );

    check(  0,  'x, 0,  0,  0,  0,  0,  0,  0,  0 );
    check(  1,  'x, 0,  1,  0,  1,  0,  1,  1, 'x );
    check(  1,  'x, 1,  0,  1,  0,  1,  0,  0,  1 );
    check(  0,  'x, 1,  1,  1,  1,  1,  1,  1, 'x );

    t.test_case_end();
  endtask

  //<'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();

    //''' LAB ASSIGNMENT '''''''''''''''''''''''''''''''''''''''''''''''''
    // Add calls to new test cases here
    //>'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

    if ((t.n <= 0) || (t.n == 2)) test_case_2_directed();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_random();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_xprop();

    //<'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

    t.test_bench_end();
  end

endmodule
