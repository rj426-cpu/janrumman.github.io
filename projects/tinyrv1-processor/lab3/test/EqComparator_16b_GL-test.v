//========================================================================
// EqComparator_16b_GL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab3/EqComparator_16b_GL.v"

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

  EqComparator_16b_GL dut
  (
    .in0 (in0),
    .in1 (in1),
    .eq  (eq)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // The ECE 2300 test framework adds a 1 tau delay with respect to the
  // rising clock edge at the very beginning of the test bench. So if we
  // immediately set the inputs this will take effect 1 tau after the clock
  // edge. Then we wait 8 tau, check the outputs, and wait 2 tau which
  // means the next check will again start 1 tau after the rising clock
  // edge.

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

  //----------------------------------------------------------------------
  // Directed Cases
  //----------------------------------------------------------------------

  // Edge Cases: Comparing max and min values
  task test_case_2_edge();
    t.test_case_begin( "test_case_2_edge" );

    //     in0       in1        eq
    check( 16'hFFFF, 16'hFFFF,  1 ); // 65535  = 65535
    check( 16'hFFFF, 16'h0000,  0 ); // 65535 != 0
    check( 16'h0000, 16'hFFFF,  0 ); // 0     != 65535

    t.test_case_end();
  endtask  

  // Patterns: Opposite patterns for in0 and in1
  task test_case_3_patterns();
    t.test_case_begin( "test_case_3_patterns" );

    //     in0       in1        eq
    check( 16'hA0A0, 16'h0A0A,  0 );  // 41120 != 2570
    check( 16'h1234, 16'h4321,  0 );  // 4660  != 17185
    check( 16'h4343, 16'h3434,  0 );  // 17219 != 13364
    check( 16'h2468, 16'h1357,  0 );  // 9320  != 4951

    t.test_case_end();
  endtask  

  // Patterns: Same patterns
  task test_case_4_same_patterns();
    t.test_case_begin( "test_case_4_same_patterns" );

    //     in0       in1        eq
    check( 16'hA0A0, 16'hA0A0,  1 );  // 41120 = 41120
    check( 16'h1234, 16'h1234,  1 );  // 4660  = 4660
    check( 16'h4343, 16'h4343,  1 );  // 17219 = 17219
    check( 16'h2468, 16'h2468,  1 );  // 9320  = 9320

    t.test_case_end();
  endtask  

  //----------------------------------------------------------------------
  // test_case_5_random
  //----------------------------------------------------------------------

  //declaring variables for input and output
  logic [15:0]    random_in0;
  logic [15:0]    random_in1;
  logic               result;

  task test_case_5_random();
    t.test_case_begin( "test_case_5_random" );

    // Run 50 iterations / perform 50 randomized tests
    for ( int i = 0; i < 50; i = i+1 ) begin

      // Generate a 16-bit random value for in0 & in1
      random_in0 = 16'($urandom(t.seed));
      random_in1 = 16'($urandom(t.seed));

      // Calculate the correct output value
      if (random_in0 == random_in1)
        result = 1;
      else
        result = 0;

      // Apply the random input values and check the output value
      check( random_in0, random_in1, result );

    end
  t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_6_xprop
  //----------------------------------------------------------------------

  task test_case_6_xprop();
    t.test_case_begin( "test_case_6_xprop" );

    //     in0       in1        eq
    check( 16'hxxxx, 16'hxxxx,  'x );
    check( 16'hxxxx, 16'h0000,  'x );
    check( 16'h0000, 16'hxxxx,  'x );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1))          test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2))           test_case_2_edge();
    if ((t.n <= 0) || (t.n == 3))       test_case_3_patterns();
    if ((t.n <= 0) || (t.n == 4))  test_case_4_same_patterns();
    if ((t.n <= 0) || (t.n == 5))         test_case_5_random();
    if ((t.n <= 0) || (t.n == 6))          test_case_6_xprop();

    t.test_bench_end();
  end

endmodule
