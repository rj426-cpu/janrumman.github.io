//========================================================================
// EqComparator_16b_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab3/EqComparator_16b_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  CombinationalTestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic [15:0] in0;
  logic [15:0] in1;
  logic        eq;

  EqComparator_16b_RTL dut
  (
    .in0 (in0),
    .in1 (in1),
    .eq  (eq)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // We set the inputs, wait 8 tau, check the outputs, wait 2 tau. Each
  // check will take a total of 10 tau.

  task check
  (
    input logic [15:0] in0_,
    input logic [15:0] in1_,
    input logic        eq_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in0 = in0_;
      in1 = in1_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %h == %h (%10d == %10d) > %b", t.cycles,
                  in0, in1, in0, in1, eq );

      `ECE2300_CHECK_EQ( eq, eq_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0       in1        eq
    check( 16'd0,    16'd0,     1 );
    check( 16'd0,    16'd1,     0 );
    check( 16'd1,    16'd0,     0 );
    check( 16'd1,    16'd1,     1 );

    t.test_case_end();
  endtask

  //''' LAB ASSIGNMENT '''''''''''''''''''''''''''''''''''''''''''''''''''
  // Add directed, random, xprop test cases
  //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();

    //''' LAB ASSIGNMENT '''''''''''''''''''''''''''''''''''''''''''''''''
    // Add calls to new test cases here
    //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

    t.test_bench_end();
  end

endmodule
