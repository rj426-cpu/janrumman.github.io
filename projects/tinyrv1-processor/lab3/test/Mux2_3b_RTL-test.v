//========================================================================
// Mux2_3b_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab3/Mux2_3b_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  CombinationalTestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic [2:0] in0;
  logic [2:0] in1;
  logic        sel;
  logic [2:0] out;

  Mux2_3b_RTL dut
  (
    .in0 (in0),
    .in1 (in1),
    .sel (sel),
    .out (out)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------

  task check
  (
    input logic [2:0] in0_,
    input logic [2:0] in1_,
    input logic       sel_,
    input logic [2:0] out_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in0 = in0_;
      in1 = in1_;
      sel = sel_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b %b %b > %b", t.cycles, in0, in1, sel, out );

      `ECE2300_CHECK_EQ( out, out_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0     in1     sel   out
    check( 3'b000, 3'b000, 1'b0, 3'b000 );
    check( 3'b000, 3'b000, 1'b1, 3'b000 );

    t.test_case_end();
  endtask

  //''' LAB ASSIGNMENT '''''''''''''''''''''''''''''''''''''''''''''''''''
  // Add directed, random, xprop test cases
  //>'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  //----------------------------------------------------------------------
  // test_case_2_directed
  //----------------------------------------------------------------------

  task test_case_2_directed();
    t.test_case_begin( "test_case_2_directed" );

    //     in0     in1     sel   out
    check( 3'b000, 3'b000, 1'b0, 3'b000 );
    check( 3'b111, 3'b000, 1'b0, 3'b111 );
    check( 3'b010, 3'b101, 1'b0, 3'b010 );
    check( 3'b101, 3'b010, 1'b0, 3'b101 );

    check( 3'b000, 3'b000, 1'b1, 3'b000 );
    check( 3'b111, 3'b000, 1'b1, 3'b000 );
    check( 3'b010, 3'b101, 1'b1, 3'b101 );
    check( 3'b101, 3'b010, 1'b1, 3'b010 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_random
  //----------------------------------------------------------------------

  logic [2:0] rand_in0;
  logic [2:0] rand_in1;
  logic       rand_sel;
  logic [2:0] rand_out;

  task test_case_3_random();
    t.test_case_begin( "test_case_3_random" );

    for ( int i = 0; i < 50; i = i+1 ) begin

      // Generate random values for in0, in1, sel

      rand_in0 = 3'($urandom(t.seed));
      rand_in1 = 3'($urandom(t.seed));
      rand_sel = 1'($urandom(t.seed));

      // Determine correct answer

      if ( rand_sel == 0 )
        rand_out = rand_in0;
      else
        rand_out = rand_in1;

      // Check DUT output matches correct answer

      check( rand_in0, rand_in1, rand_sel, rand_out );

    end

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_4_xprop
  //----------------------------------------------------------------------

  task test_case_4_xprop();
    t.test_case_begin( "test_case_4_prop" );

    //     in0 in1 sel out
    check( 'x, 'x, 'x, 'x );

    check(  0,  0, 'x, 'x );
    check(  0,  1, 'x, 'x );
    check(  1,  0, 'x, 'x );
    check(  1,  1, 'x, 'x );

    check(  0, 'x,  0,  0 );
    check(  0, 'x,  1, 'x );
    check(  1, 'x,  0,  1 );
    check(  1, 'x,  1, 'x );

    check( 'x,  0,  0, 'x );
    check( 'x,  0,  1,  0 );
    check( 'x,  1,  0, 'x );
    check( 'x,  1,  1,  1 );

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

