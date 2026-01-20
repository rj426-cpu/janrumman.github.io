//========================================================================
// Multiplier_32x32b_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/Multiplier_32x32b_RTL.v"

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
  logic [31:0] prod;

  Multiplier_32x32b_RTL dut
  (
    .in0  (in0),
    .in1  (in1),
    .prod (prod)
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
    input logic [31:0] prod_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in0 = in0_;
      in1 = in1_;

      #8;

      if ( t.n != 0 ) begin
        $display( "%3d: %h * %h (%10d * %10d) > %h (%10d)", t.cycles,
                  in0, in1, in0, in1, prod, prod );
      end

      `ECE2300_CHECK_EQ( prod, prod_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0    in1    prod
    check( 32'd0, 32'd0, 32'd0 ); // 0 * 0 = 0
    check( 32'd1, 32'd0, 32'd0 ); // 1 * 0 = 0
    check( 32'd1, 32'd1, 32'd1 ); // 1 * 1 = 1
    check( 32'd1, 32'd2, 32'd2 ); // 1 * 2 = 2
    check( 32'd1, 32'd3, 32'd3 ); // 1 * 3 = 3

    t.test_case_end();
  endtask
//------------------------------------------------------------------------
// Directed Test Cases
//------------------------------------------------------------------------

task test_case_2_zeros();
  t.test_case_begin( "test_case_2_zeros" );

    //     in0            in1            prod
    check( 32'hFFFF_FFFF, 32'b0,         32'b0 ); // when in1 = 0, prod = 0
    check( 32'h1234_1234, 32'b0,         32'b0 ); // when in1 = 0, prod = 0
    check( 32'b0,         32'h1234_1234, 32'b0 ); // when in0 = 0, prod = 0
    check( 32'b0,         32'h1234_1234, 32'b0 ); // when in0 = 0, prod = 0
    
    // in0 = 0 was tested in test 1

  t.test_case_end();
endtask

task test_case_3_ones();
  t.test_case_begin( "test_case_3_ones" );

    //     in0             in1    prod
    check( 32'd45,         32'd1, 32'd45          ); // 45 * 1 = 45
    check( 32'd4294967295, 32'd1, 32'd4294967295  ); // 4294967295 * 1 = 4294967295
    check( 32'd0,          32'd1, 32'd0           ); // 4294967295 * 1 = 4294967295
    check( 32'd1,          32'd1, 32'd1           ); // 1 * 1 = 1

  t.test_case_end();
endtask

task test_case_4_overflow();
  t.test_case_begin( "test_case_4_overflow" );
    
    //     in0            in1    prod
    check( 32'hFFFF_FFFF, 32'd2, 32'hFFFF_FFFE ); // 4294967295 * 2 = 4294967294 (wrap)
    check( 32'hFFFF_FFFF, 32'd3, 32'hFFFF_FFFD ); // 4294967295 * 3 = 4294967293 (wrap)
    check( 32'h8000_0000, 32'd2, 32'h0000_0000 ); // 2147483648 * 2 = 4294967296 becomes 0 (wrap)
    check( 32'h5555_5555, 32'd3, 32'hFFFF_FFFF ); // 1431655765 * 3 = 4294967295 (wrap)

  t.test_case_end();
endtask

task test_case_5_powers_of_two();
  t.test_case_begin( "test_case_5_powers_of_two" );
    
    //     in0       in1       prod
    check( 32'd2,    32'd2,    32'd4       ); // 2 * 2 = 4
    check( 32'd8,    32'd8,    32'd64      ); // 8 * 8 = 64
    check( 32'd16,   32'd16,   32'd256     ); // 16 * 16 = 256
    check( 32'd32,   32'd32,   32'd1024    ); // 32 * 32 = 1024
    check( 32'd1024, 32'd1024, 32'd1048576 ); // 1024 * 1024 = 1048576

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// Random Test Case
//------------------------------------------------------------------------

logic [31:0]     random_in0;
logic [31:0]     random_in1;
logic [31:0]  expected_prod;

task test_case_6_random();

  t.test_case_begin( "test_case_6_random" );
    
    // Run 50 random test cases
    for ( int i = 0; i < 50; i += 1) begin

      // Generate random values
      random_in0 = 32'($urandom(t.seed));
      random_in1 = 32'($urandom(t.seed));

      // Calculate the correct output value 
      expected_prod = 32'(random_in0 * random_in1);

      // Check if expected output matches output from implementation 
      check( random_in0, random_in1, expected_prod );

    end

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// Xprop Test Cases
//------------------------------------------------------------------------

task test_case_7_xprop();
  t.test_case_begin( "test_case_7_xprop" );
    
    //     in0            in1            prod
    check( 32'hxxxx_xxxx, 32'hxxxx_xxxx, 32'hxxxx_xxxx ); // Only Blackbox test

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

initial begin
  t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1))         test_case_1_basic();
  if ((t.n <= 0) || (t.n == 2))         test_case_2_zeros();
  if ((t.n <= 0) || (t.n == 3))          test_case_3_ones();
  if ((t.n <= 0) || (t.n == 4))      test_case_4_overflow();
  if ((t.n <= 0) || (t.n == 5)) test_case_5_powers_of_two();
  if ((t.n <= 0) || (t.n == 6))        test_case_6_random();
  if ((t.n <= 0) || (t.n == 7))         test_case_7_xprop();

  t.test_bench_end();
  end

endmodule

