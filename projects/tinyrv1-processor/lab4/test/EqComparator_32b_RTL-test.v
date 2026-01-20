//========================================================================
// EqComparator_32b_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/EqComparator_32b_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  CombinationalTestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic [31:0] in0;
  logic [31:0] in1;
  logic        eq;

  EqComparator_32b_RTL dut
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
    input logic [31:0] in0_,
    input logic [31:0] in1_,
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

    //     in0    in1    eq
    check( 32'd0, 32'd0, 1 );
    check( 32'd0, 32'd1, 0 );
    check( 32'd1, 32'd0, 0 );
    check( 32'd1, 32'd1, 1 );

    t.test_case_end();
  endtask


  //----------------------------------------------------------------------
  // Directed Cases
  //----------------------------------------------------------------------

  // Edge Cases: Comparing max and min values
  task test_case_2_edge();
    t.test_case_begin( "test_case_2_edge" );

    //     in0       in1        eq
    check( 32'hFFFF_FFFF, 32'hFFFF_FFFF,  1 ); // 4294967295 = 4294967295
    check( 32'hFFFF_FFFF, 32'h0000_0000,  0 ); // 4294967295 != 0
    check( 32'h0000_0000, 32'hFFFF_FFFF,  0 ); // 0 != 4294967295

    t.test_case_end();
  endtask  

  // Patterns: Opposite patterns for in0 and in1
  task test_case_3_patterns();
    t.test_case_begin( "test_case_3_patterns" );

    //         in0            in1        eq
    check( 32'hA0A0_A0A0, 32'h0A0A_0A0A,  0 );  // 2694881456  = 2694881456
    check( 32'h1234_4321, 32'h4321_1232,  0 );  // 305420097  != 1126243890
    check( 32'h4343_4343, 32'h3434_3434,  0 );  // 1128486723 != 875836212
    check( 32'h2468_2468, 32'h1357_1357,  0 );  // 610839656  != 324508759

    t.test_case_end();
  endtask  

  // Patterns: Same patterns
  task test_case_4_same_patterns();
    t.test_case_begin( "test_case_4_same_patterns" );

    //     in0       in1        eq
    check( 32'hA0A0_A0A0, 32'hA0A0_A0A0,  1 );  // 2694883248 = 2694883248
    check( 32'h1234_1234, 32'h1234_1234,  1 );  // 305419896  = 305419896
    check( 32'h4343_4343, 32'h4343_4343,  1 );  // 1128488003 = 1128488003
    check( 32'h2468_2468, 32'h2468_2468,  1 );  // 610851432  = 610851432

    t.test_case_end();
  endtask  

  //----------------------------------------------------------------------
  // test_case_5_random
  //----------------------------------------------------------------------

  //declaring variables for input and output
  logic [31:0]    random_in0;
  logic [31:0]    random_in1;
  logic               result;

  task test_case_5_random();
    t.test_case_begin( "test_case_5_random" );

    // Run 50 iterations / perform 50 randomized tests
    for ( int i = 0; i < 50; i = i+1 ) begin

      // Generate a 32-bit random value for in0 & in1
      random_in0 = 32'($urandom(t.seed));
      random_in1 = 32'($urandom(t.seed));

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
    check( 32'hxxxx, 32'hxxxx,  'x );
    check( 32'hxxxx, 32'h0000,  'x );
    check( 32'h0000, 32'hxxxx,  'x );

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

