//========================================================================
// Adder_32b_GL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/Adder_32b_GL.v"

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
  logic [31:0] sum;

  Adder_32b_GL dut
  (
    .in0 (in0),
    .in1 (in1),
    .sum (sum)
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
    input logic [31:0] sum_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in0 = in0_;
      in1 = in1_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %h + %h (%10d + %10d) > %h (%10d)", t.cycles,
                  in0, in1, in0, in1, sum, sum );

      `ECE2300_CHECK_EQ( sum, sum_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0    in1    sum
    check( 32'd0, 32'd0, 32'd0 );
    check( 32'd0, 32'd1, 32'd1 );
    check( 32'd1, 32'd0, 32'd1 );
    check( 32'd1, 32'd1, 32'd2 );

    t.test_case_end();
  endtask

//------------------------------------------------------------------------
// Directed Tests
//------------------------------------------------------------------------
task test_case_2_carry_propagation();
  t.test_case_begin("test_case_2_carry_propagation");
  //     in0             in1              sum
  check( 32'hFFFF_FFFF,  32'h0000_0001,   32'h0000_0000 ); 
  check( 32'hFFFF_FFFF,  32'hFFFF_FFFF,   32'hFFFF_FFFE ); 

  t.test_case_end();

endtask

task test_case_3_single_bit_carry();
  t.test_case_begin("test_case_3_single_bit_carry");

  //     in0            in1             sum
  check( 32'h0000_00FF, 32'h0000_0100,  32'h0000_01FF ); 
  check( 32'h0000_0001, 32'h0000_0010,  32'h0000_0011 ); 
  check( 32'h0000_FFFF, 32'h0000_0001,  32'h0001_0000 ); 

  t.test_case_end();
endtask

task test_case_4_patterns();
  t.test_case_begin("test_case_4_patterns");

  //     in0            in1             sum
  check( 32'hAAAA_AAAA, 32'h5555_5555,  32'hFFFF_FFFF ); 
  check( 32'hF0F0_F0F0, 32'h0F0F_0F0F,  32'hFFFF_FFFF ); 
  check( 32'h1234_5678, 32'h9876_5432,  32'hAAAA_AAAA ); 

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_5_random
//------------------------------------------------------------------------

//declaring variables for input and output
logic [31:0]    random_in0;
logic [31:0]    random_in1;
logic [31:0]  expected_sum;
logic [31:0]        result;

task test_case_5_random();
  t.test_case_begin("test_case_5_random");

    // Run 50 iterations / perform 50 randomized tests
    for ( int i = 0; i < 50; i = i+1 ) begin

      // Generate a 16-bit random value for in0, in1, and 1-bit for cin

      random_in0 = 32'($urandom(t.seed));
      random_in1 = 32'($urandom(t.seed));

      // Calculate the correct output value
      result = random_in0 + random_in1;
      expected_sum = result[31:0];

      // Apply the random input values and check the output value
      check( random_in0, random_in1, expected_sum );

    end
  t.test_case_end();

endtask

//------------------------------------------------------------------------
// test_case_6_xprop
//------------------------------------------------------------------------

task test_case_6_xprop();
  t.test_case_begin("test_case_6_xprop");

  //     in0            in1            sum
  check( 32'hxxxx_xxxx, 32'hxxxx_xxxx, 32'hxxxx_xxxx ); 
  
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
  if ((t.n <= 0) || (t.n == 4)) test_case_4_patterns();
  if ((t.n <= 0) || (t.n == 5)) test_case_5_random();
  if ((t.n <= 0) || (t.n == 6)) test_case_6_xprop();
  
  t.test_bench_end();
end

endmodule 

