//========================================================================
// Calculator_GL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab2/Calculator_GL.v"

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
  logic        op;
  logic [15:0] result;

  Calculator_GL dut
  (
    .in0    (in0),
    .in1    (in1),
    .op     (op),
    .result (result)
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
    input logic        op_,
    input logic [15:0] result_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in0 = in0_;
      in1 = in1_;
      op  = op_;

      #8;

      if ( t.n != 0 ) begin
        if ( op == 0 )
          $display( "%3d: %b + %b (%3d + %3d) > %b (%3d)", t.cycles,
                    in0, in1, in0, in1, result, result );
        else
          $display( "%3d: %b * %b (%3d * %3d) > %b (%3d)", t.cycles,
                    in0, in1, in0, in1, result, result );
      end

      `ECE2300_CHECK_EQ( result, result_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0 in1  op res
    check(   0,  0,  0,  0 );
    check(   1,  1,  0,  2 );
    check(   1,  1,  1,  1 );
    check(   1,  0,  1,  0 );
    check(   0,  0,  1,  0 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_directed
  //----------------------------------------------------------------------

  task test_case_2_corner_additions();
    t.test_case_begin( "test_case_2_corner_additions" );

    //      in0        in1      op        res
    check( 16'hFFFF,  16'hFFFF,  0,    16'hFFFE ); //65535 + 65535 = 131070 --> becomes 65534 in 16-bits
    check( 16'h0000,  16'hFFFF,  0,    16'hFFFF ); // 0 + 65535 = 65535
    check( 16'hFFFF,  16'h0000,  0,    16'hFFFF ); // 65535 + 0 = 65535
    check( 16'h0000,  16'h0000,  0,    16'h0000 ); // 0 + 0 = 0 
    check( 16'h0000,  16'h0001,  0,    16'h0001 ); // 0 + 1 = 1
    check( 16'hFF00,  16'h00FF,  0,    16'hFFFF ); // 65280 + 255 = 65535
    check( 16'h00FF,  16'h00FF,  0,    16'h01FE ); // 255 + 255 = 510
      

    t.test_case_end();
  endtask

  task test_case_3_mixed_additions();
    t.test_case_begin( "test_case_3_mixed_additions" );

    //              in0                        in1            op              res
    check( 16'b0000_0000_0000_1010,  16'b0000_0000_0100_1100,  0,    16'b0000_0000_0101_0110 ); // 10 + 76 = 86
    check( 16'b0000_0000_0000_1000,  16'b0000_0000_0000_0101,  0,    16'b0000_0000_0000_1101 ); // 8 + 5 = 13
    check( 16'b1010_1101_1001_1100,  16'b0010_1011_0110_0111,  0,    16'b1101_1001_0000_0011 ); // 44444 + 11111 = 55555
    check( 16'b1010_1010_1010_1010,  16'b0101_0101_0101_0101,  0,    16'b1111_1111_1111_1111 ); // 43690 + 21845  = 65535 
    check( 16'b0001_0010_0011_0100,  16'b0000_0000_0000_0001,  0,    16'b0001_0010_0011_0101 ); // 4660 + 1 = 4661

    t.test_case_end();
  endtask

  task test_case_4_overflow_additions();
    t.test_case_begin( "test_case_4_overflow_additions" );

    //               in0                       in1            op               res
    check( 16'b1111_1111_1111_1111,  16'b0000_0000_0000_0001,  0,    16'b0000_0000_0000_0000 ); // 65535 + 1 = 65536 --> becomes 0 in 16-bits
    check( 16'b1000_0000_0000_0000,  16'b1000_0000_0000_0000,  0,    16'b0000_0000_0000_0000 ); // 32768 + 32786 = 65536 --> becomes 0 in 16-bits
    check( 16'b1111_0000_0000_0000,  16'b1110_0000_0000_0000,  0,    16'b1101_0000_0000_0000 ); // 61440 + 57344 = 118784 --> becomes 53248 in 16-bits
    check( 16'b1110_1010_0110_0000,  16'b0010_0111_0001_0000,  0,    16'b0001_0001_0111_0000 ); // 60000 + 10000  = 70000 --> becomes 4464 in 16-bits

    t.test_case_end();
  endtask

  task test_case_5_corner_multiplications();
    t.test_case_begin( "test_case_5_corner_multiplications" );

    //       in0        in1      op       res
    check( 16'hFFFF,  16'h0001,  1,    16'hFFFF ); // 65535 x 1 = 65535 
    check( 16'hFFFF,  16'h0003,  1,    16'hFFFD ); // 65535 x 3 = 196605 --> becomes 65533 in 16-bit
    check( 16'hFFFF,  16'h0000,  1,    16'h0000 ); // 65535 x 0 = 0
    check( 16'hFFFF,  16'h0002,  1,    16'hFFFE ); // 65535 x 2 = 131070 --> becomes 65534 in 16-bits


    t.test_case_end();
  endtask

  task test_case_6_mixed_multiplications();
    t.test_case_begin( "test_case_6_mixed_multiplications" );

    //       in0         in1    op       res
    check( 16'h000A,    16'h0001,  1,    16'h000A ); // 10 x 1 = 10
    check( 16'h0008,    16'h0002,  1,    16'h0010 ); // 8 x 2 = 16
    check( 16'h01F4,    16'h0002,  1,    16'h03E8 ); // 500 x 2 = 1000
    check( 16'h0FA0,    16'h0003,  1,    16'h2EE0 ); // 4000 x 3  = 12000
    check( 16'h4E20,    16'h0002,  1,    16'h9C40 ); // 20000 x 2 = 40000
    check( 16'h5555,    16'h0003,  1,    16'hFFFF ); // 21845 x 3 = 65535

    t.test_case_end();
  endtask

  task test_case_7_overflow_multiplications();
    t.test_case_begin( "test_case_7_overflow_multiplications" );

    //        in0      in1    op       res
    check( 16'h8000,  16'h0002,  1,    16'h0000 ); // 32768 x 2 = 65536 --> becomes 0 in 16-bits
    check( 16'hC000,  16'h0002,  1,    16'h8000 ); // 49152 x 2 = 98304 --> becomes 32768 in 16-bits
    check( 16'h8000,  16'h0003,  1,    16'h8000 ); // 32768 x 3 = 98304 --> becomes 32768 in 16-bits
    check( 16'h6000,  16'h0003,  1,    16'h2000 ); // 24576 x 3 = 73728 --> becomes 8192 in 16-bits
    check( 16'h5556,  16'h0003,  1,    16'h0002 ); // 21846 x 3 = 65538 --> becomes 2 in 16-bits

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_8_random
  //----------------------------------------------------------------------

//declaring variables for input and output
logic [15:0]            random_in0;
logic [15:0]            random_in1;
logic                    random_op;
logic [15:0]    result_from_random;

task test_case_8_random();
  t.test_case_begin("test_case_8_random");

    // Run 50 iterations / perform 50 randomized tests
    for ( int i = 0; i < 50; i = i+1 ) begin

      // Generate a 16-bit random value for in0, in1, and
      random_in0 = 16'($urandom(t.seed));
      random_in1 = 16'($urandom(t.seed));
      random_op =   1'($urandom(t.seed));

      // conditions for addition and multiplication
      if (random_op == 1'b0) 
        result_from_random = random_in0 + random_in1;
      else
        result_from_random = random_in0 * random_in1[1:0];
        
      // Apply the random input values and check the output value
      check( random_in0, random_in1, random_op, result_from_random);

    end
    
  t.test_case_end();

endtask

  //------------------------------------------------------------------------
  // test_case_9_xprop
  //------------------------------------------------------------------------

task test_case_9_xprop();
  t.test_case_begin("test_case_9_xprop");

    //         in0      in1     op      res
    check( 16'bxxxx,  16'bxxxx,  1'b0,  16'bxxxx);
    check( 16'bxxxx,  16'b0000,  1'b0,  16'bxxxx);
    check( 16'b0000,  16'bxxxx,  1'b0,  16'bxxxx);
    check( 16'bxxxx,  16'h000x,  1'b1,  16'bxxxx);
    check( 16'bxxxx,  16'h0000,  1'b1,  16'b0000);
    check( 16'h0000,  16'h000x,  1'b1,  16'b0000);
    check( 16'hxxxx,  16'h00xx,  1'bx,  16'bxxxx);
    check( 16'hxxxx,  16'h000x,  1'bx,  16'bxxxx);
    check( 16'hxxxx,  16'h0001,  1'bx,  16'bxxxx);

      
  t.test_case_end();
endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1))                     test_case_1_basic();
  if ((t.n <= 0) || (t.n == 2))          test_case_2_corner_additions();
  if ((t.n <= 0) || (t.n == 3))           test_case_3_mixed_additions();
  if ((t.n <= 0) || (t.n == 4))        test_case_4_overflow_additions();
  if ((t.n <= 0) || (t.n == 5))    test_case_5_corner_multiplications();
  if ((t.n <= 0) || (t.n == 6))     test_case_6_mixed_multiplications();
  if ((t.n <= 0) || (t.n == 7))  test_case_7_overflow_multiplications();
  if ((t.n <= 0) || (t.n == 8))                    test_case_8_random();
  if ((t.n <= 0) || (t.n == 9))                     test_case_9_xprop();

    t.test_bench_end();
  end

endmodule

