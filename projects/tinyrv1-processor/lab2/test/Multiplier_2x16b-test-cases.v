//========================================================================
// Multiplier_2x16b-test-cases
//========================================================================
// This file is meant to be included in a test bench.

//------------------------------------------------------------------------
// check
//------------------------------------------------------------------------
// We set the inputs, wait 8 tau, check the outputs, wait 2 tau. Each
// check will take a total of 10 tau.

task check
(
  input logic [15:0] in0_,
  input logic  [1:0] in1_,
  input logic [15:0] prod_
);
  if ( !t.failed ) begin
      t.num_checks += 1;

    in0 = in0_;
    in1 = in1_;

    #8;

    if ( t.n != 0 )
      $display( "%3d: %b * %b (%5d * %d) > %b (%5d)", t.cycles,
                in0, in1, in0, in1, prod, prod );

    `ECE2300_CHECK_EQ( prod, prod_ );

    #2;

  end
endtask

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

    //     in0 in1 prod
    check(   0,  0,   0 );
    check(   0,  1,   0 );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// Directed Test Cases
//------------------------------------------------------------------------

task test_case_2_zeros();
  t.test_case_begin( "test_case_2_zeros" );

    //          in0   in1  prod
    check( 16'hFFFF,    0,    0 ); // when in1 = 0, in0 = max
    check( 16'h1234,    0,    0 ); // when in1 = 0, in0 is random
    
    // in0 = 0 was tested in test 1

  t.test_case_end();
endtask

task test_case_3_ones();
  t.test_case_begin( "test_case_3_ones" );

    //          in0  in1      prod
    check( 16'hFFFF,   1, 16'hFFFF ); // when in1 = 1, prod = in0
    check( 16'h1234,   1, 16'h1234 ); 
    check(        1,   1,        1 ); // when in0 = in1 = 1, prod = 1

  t.test_case_end();
endtask

task test_case_4_overflow();
  t.test_case_begin( "test_case_4_overflow" );
    
    //          in0    in1      prod
    check( 16'hFFFF, 2'b10, 16'hFFFE ); // 16-bit overflow from max * 2 -> max - 1
    check( 16'hFFFF, 2'b11, 16'hFFFD ); // 16-bit overflow from max * 3 -> max - 2
    check( 16'h8000, 2'b10,        0 ); // first overflow
    check( 16'h5555, 2'b11, 16'hFFFF ); // 21845 * 3 = 65535 (the max value)

  t.test_case_end();
endtask

task test_case_5_powers_of_two();
  t.test_case_begin( "test_case_5_powers_of_two" );
    
    //          in0    in1      prod
    check( 16'h0001, 2'b10, 16'h0002 ); // 1   * 2 = 2
    check( 16'h0002, 2'b10, 16'h0004 ); // 2   * 2 = 4
    check( 16'h0004, 2'b10, 16'h0008 ); // 4   * 2 = 8
    check( 16'h0008, 2'b11, 16'h0018 ); // 8   * 3 = 24
    check( 16'h0100, 2'b11, 16'h0300 ); // 256 * 3 = 768

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// Random Test Case
//------------------------------------------------------------------------

logic [15:0]    random_in0;
logic [1:0]     random_in1;
logic [15:0] expected_prod;

task test_case_6_random();

  t.test_case_begin( "test_case_6_random" );
    
    // Run 50 random test cases
    for ( int i = 0; i < 50; i += 1) begin

      // Generate random values
      random_in0 = 16'($urandom(t.seed));
      random_in1 =  2'($urandom(t.seed));

      // Calculate the correct output value 
      expected_prod = 16'(random_in0 * random_in1);

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
    
    //          in0    in1      prod
    check( 16'hxxxx, 2'bxx, 16'hxxxx ); // Only Blackbox test

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
