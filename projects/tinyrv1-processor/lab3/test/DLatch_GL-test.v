//========================================================================
// DLatch_GL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab3/DLatch_GL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  CombinationalTestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic clk;
  logic d;
  logic q;

  DLatch_GL dlatch
  (
    .clk (clk),
    .d   (d),
    .q   (q)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // We set the inputs, wait 8 tau, check the outputs, wait 2 tau. Each
  // check will take a total of 10 tau. The optional final argument
  // enables ignoring the output checks when they are undefined.

  task check
  (
    input logic clk_,
    input logic d_,
    input logic q_,
    input logic outputs_undefined = 0
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      clk = clk_;
      d   = d_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b %b > %b", t.cycles, clk, d, q );

      if ( !outputs_undefined )
        `ECE2300_CHECK_EQ( q, q_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //    clk d  q
    check( 0, 0, 'x, t.outputs_undefined );
    check( 1, 0, 0 );
    check( 0, 0, 0 );
    check( 1, 0, 0 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_2_exhaustive
  //----------------------------------------------------------------------

  task test_case_2_exhaustive();
    t.test_case_begin( "test_case_2_exhaustive" );

    //''' ACTIVITY '''''''''''''''''''''''''''''''''''''''''''''''''''''''
    // Add checks for exhaustive testing
    //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    // Check all possible inputs and states. Exhaustive testing for
    // sequential logic is more complicated than for combinational logic.
    // We need to treat the clock as another input, so we need four
    // checks to try all possible values of d when clk is high (i.e.,
    // latch is transparent) and when clk is low (i.e., latch is opaque).
    // We also need to do our checks when the D latch is opaque twice,
    // first when the D latch is storing a one and again when the D
    // latch is storing a zero. Then we need to do one final check to
    // make sure we can return to the original state.
    //
    // The following template will exhaustively test the D latch. You
    // just need to replace every 'x with what the expected output is for
    // that check.

    //    clk d  q
    check( 0, 0, 'x, t.outputs_undefined );
    check( 1, 0,  0 ); // d=0, latch is transparent
    check( 1, 1,  1 ); // d=1, latch is transparent
    check( 0, 0,  1 ); // d=0, latch is opaque
    check( 0, 1,  1 ); // d=1, latch is opaque
    check( 1, 0,  0 ); // d=0, latch is transparent
    check( 1, 0,  0 ); // d=0, latch is transparent
    check( 0, 0,  0 ); // d=0, latch is opaque
    check( 0, 1,  0 ); // d=1, latch is opaque
    check( 1, 0,  0 ); // return to original state

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_xprop
  //----------------------------------------------------------------------
  // Sequential xprop testing can assume clock is never X.

  task test_case_3_xprop();
    t.test_case_begin( "test_case_3_xprop" );

    //     clk  d   q
    check( 0, 'x, 'x, t.outputs_undefined );
    check( 1, 'x, 'x );
    check( 0, 'x, 'x );
    check( 1, 'x, 'x );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_exhaustive();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_xprop();

    t.test_bench_end();
  end

endmodule

