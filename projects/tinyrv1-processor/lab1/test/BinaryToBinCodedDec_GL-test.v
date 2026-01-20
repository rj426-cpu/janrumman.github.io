//========================================================================
// BinaryToBinCodedDec_GL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab1/BinaryToBinCodedDec_GL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  CombinationalTestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic [4:0] in;
  logic [3:0] tens;
  logic [3:0] ones;

  BinaryToBinCodedDec_GL dut
  (
    .in   (in),
    .tens (tens),
    .ones (ones)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // We set the inputs, wait 8 tau, check the outputs, wait 2 tau. Each
  // check will take a total of 10 tau.

  task check
  (
    input logic [4:0] in_,
    input logic [3:0] tens_,
    input logic [3:0] ones_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in = in_;

      #8;

      if ( t.n != 0 ) begin
        if ( tens != 0 )
          $display( "%3d: %b (%d) > %b %b (%0d%0d)", t.cycles,
                    in, in, tens, ones, tens, ones );
        else
          $display( "%3d: %b (%d) > %b %b ( %0d)", t.cycles,
                    in, in, tens, ones, ones );
      end

      `ECE2300_CHECK_EQ( tens, tens_ );
      `ECE2300_CHECK_EQ( ones, ones_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    check( 5'b00000, 4'b0000, 4'b0000 );
    check( 5'b00001, 4'b0000, 4'b0001 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_2_exhaustive
  //----------------------------------------------------------------------

  task test_case_2_exhaustive();
    t.test_case_begin( "test_case_2_exhaustive" );
    // 0 to 9
    //     in        tens     ones
    check( 5'b00000, 4'b0000, 4'b0000 );  // 0
    check( 5'b00001, 4'b0000, 4'b0001 );  // 1
    check( 5'b00010, 4'b0000, 4'b0010 );  // 2
    check( 5'b00011, 4'b0000, 4'b0011 );
    check( 5'b00100, 4'b0000, 4'b0100 );
    check( 5'b00101, 4'b0000, 4'b0101 );  
    check( 5'b00110, 4'b0000, 4'b0110 );  
    check( 5'b00111, 4'b0000, 4'b0111 );
    check( 5'b01000, 4'b0000, 4'b1000 );
    check( 5'b01001, 4'b0000, 4'b1001 );  // 9

    // 10 to 19
    //     in        tens     ones
    check( 5'b01010, 4'b0001, 4'b0000 );  // 10
    check( 5'b01011, 4'b0001, 4'b0001 );  // 11
    check( 5'b01100, 4'b0001, 4'b0010 );  // 12
    check( 5'b01101, 4'b0001, 4'b0011 );
    check( 5'b01110, 4'b0001, 4'b0100 );
    check( 5'b01111, 4'b0001, 4'b0101 );    
    check( 5'b10000, 4'b0001, 4'b0110 );
    check( 5'b10001, 4'b0001, 4'b0111 );
    check( 5'b10010, 4'b0001, 4'b1000 );    
    check( 5'b10011, 4'b0001, 4'b1001 );  // 19

    // 20 to 29
    //     in        tens     ones
    check( 5'b10100, 4'b0010, 4'b0000 );  // 20
    check( 5'b10101, 4'b0010, 4'b0001 );  // 21
    check( 5'b10110, 4'b0010, 4'b0010 );  // 22
    check( 5'b10111, 4'b0010, 4'b0011 );
    check( 5'b11000, 4'b0010, 4'b0100 );    
    check( 5'b11001, 4'b0010, 4'b0101 );
    check( 5'b11010, 4'b0010, 4'b0110 );  // 26
    check( 5'b11011, 4'b0010, 4'b0111 );    
    check( 5'b11100, 4'b0010, 4'b1000 );
    check( 5'b11101, 4'b0010, 4'b1001 );  // 29

    // 30 to 31
    //     in        tens     ones
    check( 5'b11110, 4'b0011, 4'b0000 );  // 30
    check( 5'b11111, 4'b0011, 4'b0001 );  // 31

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_xprop
  //----------------------------------------------------------------------

  task test_case_3_xprop();
    t.test_case_begin( "test_case_3_xprop" );

    // The top two bits of the tens output should be forced to be zero
    // even if the inputs are X.

    check( 5'bxxxxx, 4'b00xx, 4'bxxxx );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_exhaustive();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_xprop();

    t.test_bench_end();
  end

endmodule

