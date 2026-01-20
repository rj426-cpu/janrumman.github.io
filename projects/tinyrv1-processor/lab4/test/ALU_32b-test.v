//========================================================================
// ALU_32b-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/ALU_32b.v"

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
  logic        op;
  logic [31:0] out;

  ALU_32b dut
  (
    .in0 (in0),
    .in1 (in1),
    .op  (op),
    .out (out)
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
    input logic        op_,
    input logic [31:0] out_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in0 = in0_;
      in1 = in1_;
      op  = op_;

      #8;

      if ( t.n != 0 ) begin
        if ( op == 0 )
          $display( "%3d: %h +  %h (%10d +  %10d) > %h (%10d)", t.cycles,
                    in0, in1, in0, in1, out, out );
        else
          $display( "%3d: %h == %h (%10d == %10d) > %h (%10d)", t.cycles,
                    in0, in1, in0, in1, out, out );
      end

      `ECE2300_CHECK_EQ( out, out_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0    in1    op out
    check( 32'd0, 32'd0, 0, 32'd0 );
    check( 32'd0, 32'd1, 0, 32'd1 );
    check( 32'd1, 32'd0, 0, 32'd1 );
    check( 32'd1, 32'd1, 0, 32'd2 );

    check( 32'd0, 32'd0, 1, 32'd1 );
    check( 32'd0, 32'd1, 1, 32'd0 );
    check( 32'd1, 32'd0, 1, 32'd0 );
    check( 32'd1, 32'd1, 1, 32'd1 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // Directed Test Cases
  //----------------------------------------------------------------------
  task test_case_2_add();
    t.test_case_begin( "test_case_2_add" );

    //     in0            in1            op  out
    check( 32'h1111_0000, 32'h0000_1111, 0,  32'h1111_1111 );
    check( 32'h1234_0000, 32'h0000_1234, 0,  32'h1234_1234 );
    check( 32'h9090_9090, 32'h0909_0909, 0,  32'h9999_9999 );
    check( 32'h1111_1111, 32'h1111_1111, 0,  32'h2222_2222 );

    t.test_case_end();
  endtask

  task test_case_3_eq();
    t.test_case_begin( "test_case_3_eq" );

    //     in0            in1            op  out
    check( 32'h1111_0000, 32'h1111_0000, 1,  32'd1 );
    check( 32'h1234_0000, 32'h1234_0000, 1,  32'd1 );
    check( 32'h9090_9090, 32'h9090_9090, 1,  32'd1 );
    check( 32'h1111_1111, 32'h1111_1111, 1,  32'd1 );

    check( 32'h1111_0000, 32'h0000_1111, 1,  32'd0 );
    check( 32'h1234_0000, 32'h0000_1234, 1,  32'd0 );
    check( 32'h9090_9090, 32'h0909_0909, 1,  32'd0 );
    check( 32'h1111_1111, 32'h0101_0101, 1,  32'd0 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_4_random
  //----------------------------------------------------------------------

  //declaring variables for input and output
  logic [31:0]    random_in0;
  logic [31:0]    random_in1;
  logic [31:0]      expected;

  task test_case_4_random();
    t.test_case_begin("test_case_4_random");

      // Run 50 iterations / perform 50 randomized tests
      for ( int i = 0; i < 50; i = i+1 ) begin

        // Generate a 32-bit random value for in0, in1, and 1-bit for op

        random_in0 = 32'($urandom(t.seed));
        random_in1 = 32'($urandom(t.seed));
        op = 1'($urandom(t.seed));

        // Calculate the correct output value
        if ( op ) begin 
          expected[0] = ( random_in0 == random_in1 );
          expected[31:1] = 31'b0;
        end 
        else if ( op == 0 )
          expected = ( random_in0 + random_in1 );

        // Apply the random input values and check the output value
        check( random_in0, random_in1, op, expected );
      end
    t.test_case_end();

  endtask

  //----------------------------------------------------------------------
  // test_case_5_xprop
  //----------------------------------------------------------------------

  task test_case_5_xprop();
    t.test_case_begin( "test_case_5_xprop" );

    //     in0            in1            op   out
    check( 32'hxxxx_xxxx, 32'hxxxx_xxxx,  1,  32'b0000_0000_0000_0000_0000_0000_0000_000x );
    check( 32'hxxxx_xxxx, 32'hxxxx_xxxx,  0,  32'hxxxx_xxxx );
    check( 32'hxxxx_xxxx, 32'hxxxx_xxxx, 'x,  32'hxxxx_xxxx );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1))  test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2))    test_case_2_add();
    if ((t.n <= 0) || (t.n == 3))     test_case_3_eq();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_random();
    if ((t.n <= 0) || (t.n == 5))  test_case_5_xprop();

    t.test_bench_end();
  end

endmodule

