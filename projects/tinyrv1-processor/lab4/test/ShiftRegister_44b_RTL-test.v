//========================================================================
// ShiftRegister_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/ShiftRegister_44b_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  logic clk;
  logic rst_utils;

  TestUtilsClkRst t
  (
    .clk (clk),
    .rst (rst_utils)
  );

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic        rst;
  logic        en;
  logic        sin;
  logic [43:0] pout;

  ShiftRegister_44b_RTL dut
  (
    .clk  (clk),
    .rst  (rst | rst_utils),
    .en   (en),
    .sin  (sin),
    .pout (pout)
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
    input logic        rst_,
    input logic        en_,
    input logic        sin_,
    input logic [43:0] pout_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      rst = rst_;
      en  = en_;
      sin = sin_;

      #8;

      if ( t.n != 0 ) begin
        if ( en )
          $display( "%3d: %b < %b", t.cycles, pout, sin );
        else
          $display( "%3d: %b", t.cycles, pout );
      end

      `ECE2300_CHECK_EQ( pout, pout_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     rst en sin pout
    check( 0,  0, 0,  44'b0000_0000 );
    check( 0,  1, 1,  44'b0000_0000 );
    check( 0,  0, 1,  44'b0000_0001 );
    check( 0,  1, 0,  44'b0000_0001 );
    check( 0,  1, 1,  44'b0000_0010 );
    check( 0,  1, 0,  44'b0000_0101 );
    check( 0,  1, 0,  44'b0000_1010 );
    check( 0,  1, 1,  44'b0001_0100 );
    check( 0,  1, 1,  44'b0010_1001 );
    check( 0,  0, 0,  44'b0101_0011 );

    t.test_case_end();
  endtask

//------------------------------------------------------------------------
// Directed Test Cases
//------------------------------------------------------------------------

task test_case_2_ones();
  t.test_case_begin( "test_case_2_ones" );

    //     resetting each cycle
    //     rst en sin pout
    check( 1,  0, 0,  44'b0000_0000 );
    check( 1,  1, 0,  44'b0000_0000 );
    check( 1,  0, 0,  44'b0000_0000 );
    check( 1,  1, 0,  44'b0000_0000 );
    check( 1,  1, 1,  44'b0000_0000 );

    //     en is high each cycle
    //     rst en sin pout
    check( 1,  1, 0,  44'b0000_0000 );
    check( 0,  1, 0,  44'b0000_0000 );
    check( 0,  1, 0,  44'b0000_0000 );
    check( 0,  1, 0,  44'b0000_0000 );
    check( 0,  1, 0,  44'b0000_0000 );

    //     sin is high each cycle
    //     rst en sin pout
    check( 1,  0, 1,  44'b0000_0000 );
    check( 0,  0, 1,  44'b0000_0000 );
    check( 0,  0, 1,  44'b0000_0000 );
    check( 0,  0, 1,  44'b0000_0000 );
    check( 0,  0, 1,  44'b0000_0000 );

    //     sin is high each cycle
    //     rst en sin pout
    check( 1,  1, 1,  44'b0000_0000 );
    check( 0,  1, 1,  44'b0000_0000 );
    check( 0,  1, 1,  44'b0000_0001 );
    check( 0,  1, 1,  44'b0000_0011 );
    check( 0,  1, 1,  44'b0000_0111 );

  t.test_case_end();
endtask

task test_case_3_mixed();
  t.test_case_begin( "test_case_3_mixed" );

    //     rst en sin pout
    check( 1,  1, 0,  44'b0        );
    check( 0,  1, 1,  44'b0        );
    check( 0,  1, 0,  44'b1        );
    check( 0,  1, 1,  44'b10       );
    check( 0,  1, 0,  44'b101      );
    check( 0,  1, 1,  44'b1010     );
    check( 0,  1, 1,  44'b10101    );
    check( 0,  1, 1,  44'b101011   );
    check( 0,  1, 1,  44'b1010111  );
    check( 0,  0, 1,  44'b10101111 );
    check( 0,  0, 1,  44'b10101111 );

  t.test_case_end();
endtask

task test_case_4_midseq();
  t.test_case_begin( "test_case_4_midseq" );
    
    //     rst en sin pout
    check( 1,  1, 0,  44'b0  );
    check( 0,  1, 1,  44'b0  );
    check( 0,  1, 1,  44'b1  );
    check( 0,  1, 1,  44'b11 );

    //     disable shifting
    //     rst en sin pout
    check( 0,  0, 1,  44'b111 );
    check( 0,  0, 0,  44'b111 );
    check( 0,  0, 1,  44'b111 );

    //     Re-enable shifting
    //     rst en sin pout
    check( 0,  1, 0,  44'b111   );
    check( 0,  1, 0,  44'b1110  );
    check( 0,  1, 1,  44'b11100 );

    //     Reset again
    //     rst en sin pout
    check( 1,  0, 0,  44'b111001 );
    check( 0,  1, 1,  44'b0      );
    check( 0,  1, 0,  44'b01     );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// Random Test Case
//------------------------------------------------------------------------

logic           initial_rst;
logic             random_en;
logic            random_sin;
logic [43:0]  expected_pout;

task test_case_5_random();

  t.test_case_begin( "test_case_5_random" );

    // initialize expected_pout
    expected_pout = 44'b0;
    
    // Run 50 random test cases
    for ( int i = 0; i < 50; i += 1) begin

      // Generate random values
      random_en  = 1'($urandom(t.seed));
      random_sin = 1'($urandom(t.seed));

      // setting first cycle reset to 1 and then stays 0 
      if (i == 0) begin
        initial_rst = 1'b1;
      end
      else begin
        initial_rst = 1'b0;
      end

      // Check if current expected output matches output from implementation 
      check( initial_rst, random_en, random_sin, expected_pout );

      // update for the next cycle
        if (initial_rst)
        expected_pout = 44'b0;
        else if (random_en)
        expected_pout = { expected_pout[42:0], random_sin };     
    end

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// Xprop Test Cases
//------------------------------------------------------------------------

task test_case_6_xprop();
  t.test_case_begin( "test_case_6_xprop" );
    
    //     rst  en  sin  pout
    check( 'x,  'x, 'x, 44'b0 );
    check(  0,  'x, 'x, 44'bx );
    check( 'x,   1,  0, 44'bx );
    check( 'x,   0,  1, 44'bx );
    check(  0,  'x,  1, 44'bx );
    check(  0,  'x,  0, 44'bx );
    check(  0,   1, 'x, 44'bx );
    check(  0,   1,  1, 44'bx );
    check(  0,   1, 'x, 44'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1 );

  t.test_case_end();
endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1))  test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2))   test_case_2_ones();
    if ((t.n <= 0) || (t.n == 3))  test_case_3_mixed();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_midseq();
    if ((t.n <= 0) || (t.n == 5)) test_case_5_random();
    if ((t.n <= 0) || (t.n == 6))  test_case_6_xprop();

    t.test_bench_end();
  end

endmodule
