//========================================================================
// Adder_16b-test-cases
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
  input logic [15:0] in1_,
  input logic        cin_,
  input logic        cout_,
  input logic [15:0] sum_
);
  if ( !t.failed ) begin
    t.num_checks += 1;

    in0 = in0_;
    in1 = in1_;
    cin = cin_;

    #8;

    if ( t.n != 0 )
      $display( "%3d: %b + %b + %b (%5d + %5d + %b) > %b %b (%5d)", t.cycles,
                in0, in1, cin, in0, in1, cin, cout, sum, sum );

    `ECE2300_CHECK_EQ( cout, cout_ );
    `ECE2300_CHECK_EQ( sum,  sum_  );

    #2;

  end
endtask

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin("test_case_1_basic");

  //       in0    in1 cin cout sum
  check(     0,     0, 0, 0,       0 ); 
  check( 16'd1, 16'd1, 0, 0,   16'd2 );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// Directed Tests
//------------------------------------------------------------------------
// Hexadecimals are used for the test cases to minimize line length.

task test_case_2_carry_propagation();
  t.test_case_begin("test_case_2_overflow");

  // Note: we spoke to a TA with regards to the col number below being 
  // over 72, but she said grading usually prioritizes clear comments
  // over character count.

  //          in0       in1  cin cout        sum
  check( 16'hFFFF, 16'h0001,   0,   1,  16'h0000 ); // 65535 + 1 + 0 = 65536 -> cout=1, sum=0
  check( 16'hFFFF, 16'hFFFF,   0,   1,  16'hFFFE ); // 65535 + 65535 + 0 = 131070 -> cout=1, sum=65534
  check( 16'hFFFF, 16'h0001,   1,   1,  16'h0001 ); // 65535 + 1 + 1 = 65537 -> cout=1, sum=1

  t.test_case_end();

endtask

task test_case_3_single_bit_carry();
  t.test_case_begin("test_case_3_single_bit_carry");

  //          in0       in1  cin cout        sum
  check( 16'h00FF, 16'h0100,   0,   0,  16'h01FF ); // 255 -> 256 -> 0 = 511 -> cout=0, sum=511
  check( 16'h8000, 16'h8000,   0,   1,  16'h0000 ); // 32768 + 32768 + 0 = 65536 -> cout=1, sum=0 
  check( 16'h0000, 16'hFFFF,   1,   1,  16'h0000 ); // 0 +65535+ 1 = 65536 -> cout=1, sum=0

  t.test_case_end();
endtask

task test_case_4_carry_ins();
  t.test_case_begin("test_case_4_carry_ins");

  //          in0       in1  cin cout        sum
  check( 16'h0000, 16'h0000,   1,   0,  16'h0001 ); // 0 + 0 + 1 = 1 -> cout=0, sum=1
  check( 16'hFFF0, 16'h0000,   1,   0,  16'hFFF1 ); // 65520 + 0 + 1 = 65521 -> cout=0, sum=65521
  check( 16'h8000, 16'h8000,   1,   1,  16'h0001 ); // 32768 + 32768 + 1 = 65537 -> cout=1, sum=1

  t.test_case_end();
endtask

task test_case_5_patterns();
  t.test_case_begin("test_case_5_patterns");

  //          in0       in1  cin cout        sum
  check( 16'hAAAA, 16'h5555,   0,   0,  16'hFFFF ); // 43690 + 21845 + 0 = 65535 -> cout=0, sum=65535
  check( 16'hF0F0, 16'h0F0F,   0,   0,  16'hFFFF ); // 61680 + 3855  + 0 = 65535 -> cout=0, sum=65535
  check( 16'h1234, 16'h4321,   0,   0,  16'h5555 ); // 4660  + 17185 + 0 = 21845 -> cout=0, sum=21845

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_6_random
//------------------------------------------------------------------------

//declaring variables for input and output
logic [15:0]    random_in0;
logic [15:0]    random_in1;
logic           random_cin;
logic [15:0]  expected_sum;
logic        expected_cout;
logic [16:0]        result;

//count the number of 1s
int   random_in0_num_ones;
int   random_in1_num_ones;

task test_case_6_random();
  t.test_case_begin("test_case_6_random");

    // Run 50 iterations / perform 50 randomized tests
    for ( int i = 0; i < 50; i = i+1 ) begin

      // Generate a 16-bit random value for in0, in1, and 1-bit for cin

      random_in0 = 16'($urandom(t.seed));
      random_in1 = 16'($urandom(t.seed));
      random_cin = 1'($urandom(t.seed));

      // Calculate the number of ones in random value in0

      random_in0_num_ones = 0;
      for ( int j = 0; j < 15; j = j+1 ) begin
        if ( random_in0[j] )
          random_in0_num_ones = random_in0_num_ones + 1;
      end

      // Calculate the number of ones in random value in1

      random_in1_num_ones = 0;
      for ( int j = 0; j < 15; j = j+1 ) begin
        if ( random_in1[j] )
          random_in1_num_ones = random_in1_num_ones + 1;
      end

      // Calculate the correct output value
      result = random_in0 + random_in1 + 17'(random_cin);
      expected_cout = result[16];
      expected_sum = result[15:0];

      // Apply the random input values and check the output value
      check( random_in0, random_in1, random_cin, expected_cout, expected_sum );

    end
  t.test_case_end();

endtask

//------------------------------------------------------------------------
// test_case_7_xprop
//------------------------------------------------------------------------

task test_case_7_xprop();
  t.test_case_begin("test_case_7_xprop");

  //          in0       in1   cin  cout        sum
  check( 16'hxxxx, 16'hxxxx, 1'bx,   'x,  16'bxxxx_xxxx_xxxx_xxxx ); 

  
  // White-box test cases were originally implemented to cater to the
  // 16-bit ripple carry adder and the carry select adder. However,
  // since this test case file is used for the RTL adder as well, only
  // the black-box test case is included as it is the only one 
  // that would pass for all implementations. 
  
  t.test_case_end();


endtask

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

initial begin
  t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
  if ((t.n <= 0) || (t.n == 2)) test_case_2_carry_propagation();
  if ((t.n <= 0) || (t.n == 3)) test_case_3_single_bit_carry();
  if ((t.n <= 0) || (t.n == 4)) test_case_4_carry_ins();
  if ((t.n <= 0) || (t.n == 5)) test_case_5_patterns();
  if ((t.n <= 0) || (t.n == 6)) test_case_6_random();
  if ((t.n <= 0) || (t.n == 7)) test_case_7_xprop();
  
  t.test_bench_end();
end

