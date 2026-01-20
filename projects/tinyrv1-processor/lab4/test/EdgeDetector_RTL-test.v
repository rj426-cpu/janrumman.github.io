//========================================================================
// EdgeDetector_RTL-test
//========================================================================

`include "ece2300/ece2300-misc.v"
`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/EdgeDetector_RTL.v"

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
  logic pos_edge;

  EdgeDetector_RTL dut
  (
    .clk      (clk),
    .d        (d),
    .pos_edge (pos_edge)
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
    input logic pos_edge_,
    input logic outputs_undefined = 0
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      d = d_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b %b | %b", t.cycles, rst, d, pos_edge );

      if ( !outputs_undefined )
        `ECE2300_CHECK_EQ( pos_edge, pos_edge_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     d  pos_edge
    check( 0, 'x, t.outputs_undefined );
    check( 0, 0 );
    check( 0, 0 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // Directed Tests
  //----------------------------------------------------------------------

  task test_case_2_none();
    t.test_case_begin( "test_case_2_none" );

    //     d  pos_edge
    check( 1, 'x, t.outputs_undefined );
    check( 1, 0 );
    check( 1, 0 );
    check( 1, 0 );
    check( 0, 0 );
    check( 0, 0 );
    check( 0, 0 );

    t.test_case_end();
  endtask

  task test_case_3_alternate();
    t.test_case_begin( "test_case_3_alternate" );

    //     d  pos_edge
    check( 0, 'x, t.outputs_undefined );
    check( 1, 1 );
    check( 0, 0 );
    check( 1, 1 );
    check( 0, 0 );
    check( 1, 1 );
    check( 0, 0 );

    t.test_case_end();
  endtask

  task test_case_4_single();  // only one rising edge
    t.test_case_begin( "test_case_4_single" );

    //     d  pos_edge
    check( 0, 'x, t.outputs_undefined );
    check( 0, 0 );
    check( 1, 1 ); // rising edge
    check( 1, 0 ); 
    check( 1, 0 );  
    
    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_5_random
  //----------------------------------------------------------------------

  // Declaring variables
  logic prev_d;
  logic curr_d;
  logic expected;

  task test_case_5_random();
    t.test_case_begin( "test_case_5_random" );

    // initialize
    prev_d = 0;
    d = 0;
    check( d, 'x, t.outputs_undefined );

    // Generate 50 cases
    for ( int i = 0; i <= 50; i++ ) begin
      // One bit of random 
      curr_d = 1'($urandom(t.seed));

      // Compute expected pos_edge
      expected = (prev_d == 0) && (curr_d == 1);

      check( curr_d, expected ); 

      prev_d = curr_d;
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
    check(  1,  1 );
    check( 'x,  0 );
    check( 'x, 'x );
    check( 'x, 'x );
    
    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_none();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_alternate();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_single();
    if ((t.n <= 0) || (t.n == 5)) test_case_5_random();
    if ((t.n <= 0) || (t.n == 6)) test_case_6_xprop();

    t.test_bench_end();
  end

endmodule
