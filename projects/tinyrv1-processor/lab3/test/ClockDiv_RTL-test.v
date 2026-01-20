//========================================================================
// ClockDiv_RTL-test
//========================================================================
// Testing the clock divider without a reset signal is tricky. Simulation
// initially marks the output of the coutner register with X's, which we
// cannot fix unless we can change the internal signals of the clock
// divider. We do this with the following syntax:
//
// dut.<signal> = <value>;
//
// This allows us to set the value for the counter register and
// appropriately check the following cycles.

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab3/ClockDiv_RTL.v"

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

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic       clk_out;
  logic [3:0] divide_sel;

  ClockDiv_RTL dut
  (
    .clk_in     (clk),
    .divide_sel (divide_sel),
    .clk_out    (clk_out)
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
    input logic [3:0] divide_sel_,
    input logic clk_out_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      divide_sel = divide_sel_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b > %b", t.cycles, rst, clk_out );

      `ECE2300_CHECK_EQ( clk_out, clk_out_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_divide2
  //----------------------------------------------------------------------

  task test_case_1_divide2();
    t.test_case_begin( "test_case_1_divide2" );

    dut.counter_reg.q = '0;

    //     div clk_out
    check( 0, 0 );
    check( 0, 1 );
    check( 0, 0 );
    check( 0, 1 );
    check( 0, 0 );
    check( 0, 1 );

    t.test_case_end();
  endtask

  //''' LAB ASSIGNMENT '''''''''''''''''''''''''''''''''''''''''''''''''''
  // Add directed test cases (no random, no xprop)
  //>'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  //----------------------------------------------------------------------
  // test_case_2_divide4
  //----------------------------------------------------------------------

  task test_case_2_divide4();
    t.test_case_begin( "test_case_2_divide4" );

    dut.counter_reg.q = '0;

    //     div clk_out
    check( 1, 0 );
    check( 1, 0 );
    check( 1, 1 );
    check( 1, 1 );
    check( 1, 0 );
    check( 1, 0 );
    check( 1, 1 );
    check( 1, 1 );
    check( 1, 0 );
    check( 1, 0 );
    check( 1, 1 );
    check( 1, 1 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_divide8
  //----------------------------------------------------------------------

  task test_case_3_divide8();
    t.test_case_begin( "test_case_3_divide8" );

    dut.counter_reg.q = '0;

    //     div clk_out
    for ( int i = 0; i < 3; i = i + 1 ) begin

      for ( int i = 0; i < 4; i = i + 1 )
        check( 2, 0 );

      for ( int i = 0; i < 4; i = i + 1 )
        check( 2, 1 );
    end

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_4_divide1024
  //----------------------------------------------------------------------

  task test_case_4_divide1024();
    t.test_case_begin( "test_case_4_divide1024" );

    dut.counter_reg.q = '0;

    //     div clk_out
    for ( int i = 0; i < 3; i = i + 1 ) begin

      for ( int i = 0; i < 512; i = i + 1 )
        check( 9, 0 );

      for ( int i = 0; i < 512; i = i + 1 )
        check( 9, 1 );
    end

    t.test_case_end();
  endtask

  //<'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_divide2();

    //''' LAB ASSIGNMENT '''''''''''''''''''''''''''''''''''''''''''''''''
    // Add calls to new test cases here
    //>'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

    if ((t.n <= 0) || (t.n == 2)) test_case_2_divide4();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_divide8();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_divide1024();

    //<'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

    t.test_bench_end();
  end

endmodule
