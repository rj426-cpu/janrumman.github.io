//========================================================================
// Mux2_16b_GL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab2/Mux2_16b_GL.v"

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
  logic        sel;
  logic [15:0] out;

  Mux2_16b_GL dut
  (
    .in0 (in0),
    .in1 (in1),
    .sel (sel),
    .out (out)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // We set the inputs, wait 8 tau, check the outputs, wait 2 tau. Each
  // check will take a total of 10 tau.

  task check
  (
    input logic [15:0] in0_,
    input logic [15:0] in1_,
    input logic        sel_,
    input logic [15:0] out_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in0 = in0_;
      in1 = in1_;
      sel = sel_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b %b %b > %b", t.cycles, in0, in1, sel, out );

      `ECE2300_CHECK_EQ( out, out_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0                      in1                      sel   out
    check( 16'b0000_0000_0000_0000, 16'b0000_0000_0000_0000, 1'b0, 16'b0000_0000_0000_0000 ); // 0, 0, sel = 0, out = 0
    check( 16'b0000_0000_0000_0000, 16'b0000_0000_0000_0000, 1'b1, 16'b0000_0000_0000_0000 ); // 0, 0, sel = 1, out = 0

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_directed
  //----------------------------------------------------------------------

  task test_case_2_ones_cases();
    t.test_case_begin( "test_case_2_ones_cases" );

    //     in0                      in1                      sel   out
    check( 16'b1111_1111_1111_1111, 16'b1111_1111_1111_1111, 1'b0, 16'b1111_1111_1111_1111 ); // 65535, 65535, sel = 0, out = 65535
    check( 16'b1111_1111_1111_1111, 16'b1111_1111_1111_1111, 1'b1, 16'b1111_1111_1111_1111 ); // 65535, 65535, sel = 1, out = 65535

    t.test_case_end();
  endtask

  task test_case_3_alternate_cases();
    t.test_case_begin( "test_case_3_alternate_cases" );

    //     in0                      in1                      sel   out
    check( 16'b1111_1111_1111_1111, 16'b0000_0000_0000_0000, 1'b0, 16'b1111_1111_1111_1111 ); // 65535, 0, sel = 0, out = 65535
    check( 16'b1111_1111_1111_1111, 16'b0000_0000_0000_0000, 1'b1, 16'b0000_0000_0000_0000 ); // 65535, 0, sel = 1, out = 0
    check( 16'b0000_0000_0000_0000, 16'b1111_1111_1111_1111, 1'b0, 16'b0000_0000_0000_0000 ); // 0, 65535, sel = 0, out = 0
    check( 16'b0000_0000_0000_0000, 16'b1111_1111_1111_1111, 1'b1, 16'b1111_1111_1111_1111 ); // 0, 65535, sel = 1, out = 65535

    t.test_case_end();
  endtask

  task test_case_4_mixed_bit_cases();
    t.test_case_begin( "test_case_4_mixed_bit_cases" );

    //     in0                      in1                      sel   out
    check( 16'b1010_1010_1010_1010, 16'b0101_0101_0101_0101, 1'b0, 16'b1010_1010_1010_1010 ); // 43690, 21845, sel = 0, out = 43690
    check( 16'b0101_0101_0101_0101, 16'b1010_1010_1010_1010, 1'b1, 16'b1010_1010_1010_1010 ); // 21845, 43690, sel = 1, out = 43690
    check( 16'b0000_0000_0000_0001, 16'b1111_1111_1111_1110, 1'b0, 16'b0000_0000_0000_0001 ); // 1, 65534, sel = 0, out = 1
    check( 16'b1000_1000_1000_1000, 16'b0111_0111_0111_0111, 1'b1, 16'b0111_0111_0111_0111 ); // 34952, 30583 , sel = 1, out = 30583

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_5_random
  //----------------------------------------------------------------------

  //declaring variables for input and output
  logic [15:0]      random_in0;
  logic [15:0]      random_in1;
  logic             random_sel;
  logic [15:0]    expected_out;

  //count the number of 1s
  int   random_in0_num_ones;
  int   random_in1_num_ones;

  task test_case_5_random();
    t.test_case_begin("test_case_5_random");

      // Run 50 iterations / perform 50 randomized tests
      for ( int i = 0; i < 50; i = i+1 ) begin

        // Generate a 16-bit random value for in0, in1, and 1-bit for cin

        random_in0 = 16'($urandom(t.seed));
        random_in1 = 16'($urandom(t.seed));
        random_sel = 1'($urandom(t.seed));

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
          
        if (random_sel == 1'b0) begin
          expected_out = random_in0;
        end else begin
          expected_out = random_in1;
        end
          
        // Apply the random input values and check the output value
        check( random_in0, random_in1, random_sel, expected_out);

      end
      
    t.test_case_end();

  endtask

  //------------------------------------------------------------------------
  // test_case_6_xprop
  //------------------------------------------------------------------------

  task test_case_6_xprop();
    t.test_case_begin("test_case_6_xprop");

      //     in0                      in1                      sel   out
      check( 16'bxxxx_xxxx_xxxx_xxxx, 16'bxxxx_xxxx_xxxx_xxxx, 1'bx, 16'bxxxx_xxxx_xxxx_xxxx );
      check( 16'bxxxx_xxxx_xxxx_xxxx, 16'bxxxx_xxxx_xxxx_xxxx, 1'b0, 16'bxxxx_xxxx_xxxx_xxxx );
      check( 16'bxxxx_xxxx_xxxx_xxxx, 16'bxxxx_xxxx_xxxx_xxxx, 1'b1, 16'bxxxx_xxxx_xxxx_xxxx );
      check( 16'bxxxx_xxxx_xxxx_1111, 16'bxxxx_xxxx_xxxx_xxxx, 1'b0, 16'bxxxx_xxxx_xxxx_1111 );
      check( 16'bxxxx_xxxx_xxxx_xxxx, 16'bxxxx_1010_xxxx_xxxx, 1'b1, 16'bxxxx_1010_xxxx_xxxx );
      check( 16'b1111_0000_1111_0000, 16'b0000_1111_0000_1111, 1'bx, 16'bxxxx_xxxx_xxxx_xxxx );
      check( 16'b0000_0000_0000_0000, 16'b0000_0000_0000_0000, 1'bx, 16'b0000_0000_0000_0000 );
        
    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1))           test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2))      test_case_2_ones_cases();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_alternate_cases();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_mixed_bit_cases();
    if ((t.n <= 0) || (t.n == 5))          test_case_5_random();
    if ((t.n <= 0) || (t.n == 6))           test_case_6_xprop();

    t.test_bench_end();
  end

endmodule

