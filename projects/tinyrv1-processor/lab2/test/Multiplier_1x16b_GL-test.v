//========================================================================
// Multiplier_1x16b_GL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab2/Multiplier_1x16b_GL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  CombinationalTestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic [15:0] in0;
  logic        in1;
  logic [15:0] prod;

  Multiplier_1x16b_GL dut
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
    input logic [15:0] in0_,
    input logic        in1_,
    input logic [15:0] prod_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in0 = in0_;
      in1 = in1_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b * %b (%3d * %b) > %b (%3d)", t.cycles,
                  in0, in1, in0, in1, prod, prod );

      `ECE2300_CHECK_EQ( prod, prod_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0 in1 prod
    check(   0,  0,   0 );
    check(   0,  1,   0 );

    t.test_case_end();
  endtask
  //----------------------------------------------------------------------
  // test_case_directed
  //----------------------------------------------------------------------

  task test_case_2_ones_cases();
    t.test_case_begin( "test_case_2_ones_cases" );

    //                in0            in1           prod
    check(                         1,  1,                       1 ); // 1x1 = 1 
    check(                         1,  0,                       0 ); // 1x0 = 0
    check(   16'b1111_1111_1111_1111,  0,                       0 ); //65535 x 0 = 0
    check(   16'b1111_1111_1111_1111,  1, 16'b1111_1111_1111_1111 ); //65535 x 1 = 65535

    t.test_case_end();
  endtask

  task test_case_3_mixed_cases();
    t.test_case_begin( "test_case_3_mixed_cases" );

    //                in0            in1           prod
    check(   16'b1010_1010_1010_1010,  1,   16'b1010_1010_1010_1010 ); // 43690 x 1 = 43690 
    check(   16'b1000_1000_1000_1000,  1,   16'b1000_1000_1000_1000 ); // 34952 x 1 = 34952 
    check(   16'b0101_0101_0101_0101,  0,                         0 ); // 21845 x 0 = 0
    check(   16'b1111_1111_1111_1110,  0,                         0 ); // 65534 x 0 = 0

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_4_random
  //----------------------------------------------------------------------

  //declaring variables for input and output
  logic [15:0]      random_in0;
  logic             random_in1;
  logic [15:0]         product;

  //count the number of 1s
  int   random_in0_num_ones;

  task test_case_4_random();
    t.test_case_begin("test_case_4_random");

      // Run 50 iterations / perform 50 randomized tests
      for ( int i = 0; i < 50; i = i+1 ) begin

        // Generate a 16-bit random value for in0 and in1

        random_in0 = 16'($urandom(t.seed));
        random_in1 =  1'($urandom(t.seed));

        // Calculate the number of ones in random value in0

        random_in0_num_ones = 0;
        for ( int j = 0; j < 15; j = j+1 ) begin
          if ( random_in0[j] )
            random_in0_num_ones = random_in0_num_ones + 1;
        end

        // conditions for the multiplier
        if (random_in1 == 1'b0) begin
          product  = 0;
        end else begin
          product = random_in0;
        end
          
        // Apply the random input values and check the output value
        check( random_in0, random_in1, product);

      end
      
    t.test_case_end();

  endtask

  //------------------------------------------------------------------------
  // test_case_5_xprop
  //------------------------------------------------------------------------

  task test_case_5_xprop();
    t.test_case_begin("test_case_5_xprop");

      //                   in0           in1            prod
      check(   16'bxxxx_xxxx_xxxx_xxxx,   0,                        0 );
      check(   16'bxxxx_xxxx_xxxx_xxxx,   1,  16'bxxxx_xxxx_xxxx_xxxx );
      check(   16'bxxxx_xxxx_xxxx_xxxx,  'x,  16'bxxxx_xxxx_xxxx_xxxx );
      check(   16'b1111_1111_1111_1111,  'x,  16'bxxxx_xxxx_xxxx_xxxx );
      check(   16'b0000_0000_0000_0000,  'x,                        0 );
      check(   16'bxxxx_1xxx_10xx_xxxx,   1,  16'bxxxx_1xxx_10xx_xxxx );
      check(   16'bxxxx_1xxx_10xx_xxxx,   0,                        0 );
        
    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1))           test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2))      test_case_2_ones_cases();
    if ((t.n <= 0) || (t.n == 3))     test_case_3_mixed_cases();
    if ((t.n <= 0) || (t.n == 4))          test_case_4_random();
    if ((t.n <= 0) || (t.n == 5))           test_case_5_xprop();

    t.test_bench_end();
  end

endmodule

