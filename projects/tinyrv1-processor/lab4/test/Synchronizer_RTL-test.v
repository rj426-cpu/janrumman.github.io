//========================================================================
// Synchronizer_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/Synchronizer_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  logic clk;
  logic rst;

  TestUtilsClkRst t
  (
    .clk (clk),
    .rst (rst)
  );

  `ECE2300_UNUSED( rst );

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic d;
  logic q;

  Synchronizer_RTL dut
  (
    .clk (clk),
    .d   (d),
    .q   (q)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // The ECE 2300 test framework adds a 1 tau delay with respect to the
  // rising clock edge at the very beginning of the test bench. So if we
  // immediately set the inputs this will take effect 1 tau after the
  // clock edge. Then we wait 8 tau, check the outputs, and wait 2 tau
  // which means the next check will again start 1 tau after the rising
  // clock edge.

  task check
  (
    input logic d_,
    input logic q_,
    input logic outputs_undefined = 0
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      d = d_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b > > %b", t.cycles, d, q );

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

    //     d  q
    check( 0, 'x, t.outputs_undefined );
    check( 0, 'x, t.outputs_undefined );
    check( 0, 0 );
    check( 0, 0 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // Directed Tests
  //----------------------------------------------------------------------

  task test_case_2_low();
    t.test_case_begin( "test_case_2_low" );

    //     d  q
    check( 0, 'x, t.outputs_undefined );
    check( 0, 'x, t.outputs_undefined );
    check( 0, 0 );
    check( 0, 0 );
    check( 0, 0 );

    t.test_case_end();
  endtask

  task test_case_3_high();
    t.test_case_begin( "test_case_3_high" );

    //     d  q
    check( 1, 'x, t.outputs_undefined );
    check( 1, 'x, t.outputs_undefined );
    check( 1, 1 );
    check( 1, 1 );

    t.test_case_end();
  endtask

  task test_case_4_toggle();  
    t.test_case_begin( "test_case_4_toggle" );

    //     d  q
    check( 1, 'x, t.outputs_undefined );
    check( 1, 'x, t.outputs_undefined );
    check( 0, 1 );
    check( 0, 1 );
    check( 1, 0 );
    check( 0, 0 );
    check( 0, 1 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_5_random
  //----------------------------------------------------------------------

  logic [49:0] d_seq;
  logic [49:0] expected;

  task test_case_5_random();
    t.test_case_begin( "test_case_5_random" );

    // Generate 50 random bits for d
    for (int i = 0; i < 50; i++) begin
      d_seq[i] = 1'($urandom(t.seed));
    end

    // Compute expected q values with 2-cycle delay
    for (int i = 0; i < 50; i++) begin
      if (i < 2)
        expected[i] = 'x; // output undefined for first two cycles
      else
        expected[i] = d_seq[i-2];
    end

    // Apply inputs and check outputs
    for (int i = 0; i < 50; i++) begin
      check( d_seq[i], expected[i], (i < 2) );
    end

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_6_xprop
  //----------------------------------------------------------------------

  task test_case_6_xprop();  // only one rising edge
    t.test_case_begin( "test_case_6_xprop" );

    //      d  pos_edge
    check(  0, 'x, t.outputs_undefined );
    check( 'x, 'x, t.outputs_undefined );
    check(  1,  0, t.outputs_undefined );
    check(  1, 'x, t.outputs_undefined );
    check(  1,  1 );
    
    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_low();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_high();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_toggle();
    if ((t.n <= 0) || (t.n == 5)) test_case_5_random();
    if ((t.n <= 0) || (t.n == 6)) test_case_6_xprop();

    t.test_bench_end();
  end

endmodule
