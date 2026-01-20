//========================================================================
// BinaryToSevenSeg-test-cases
//========================================================================
// This file is meant to be included in a test bench.

//------------------------------------------------------------------------
// check
//------------------------------------------------------------------------
// We set the inputs, wait 8 tau, check the outputs, wait 2 tau. Each
// check will take a total of 10 tau.

task check
(
  input logic [3:0] in_,
  input logic [6:0] seg_
);
  if ( !t.failed ) begin
    t.num_checks += 1;

    in = in_;

    #8;

    if ( t.n != 0 )
      $display( "%3d: %b (%d) > %b", t.cycles, in, in, seg );

    `ECE2300_CHECK_EQ( seg, seg_ );

    #2;

  end
endtask

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  check( 4'b0000, 7'b100_0000 );
  check( 4'b0001, 7'b111_1001 );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_2_exhaustive
//------------------------------------------------------------------------

task test_case_2_exhaustive();
  t.test_case_begin( "test_case_2_exhaustive" );

  //       in         out
    check( 4'b0000, 7'b100_0000 ); // 0
    check( 4'b0001, 7'b111_1001 ); // 1
    check( 4'b0010, 7'b010_0100 ); // 2
    check( 4'b0011, 7'b011_0000 ); // 3
    check( 4'b0100, 7'b001_1001 ); // 4
    check( 4'b0101, 7'b001_0010 ); // 5
    check( 4'b0110, 7'b000_0010 ); // 6
    check( 4'b0111, 7'b111_1000 ); // 7
    check( 4'b1000, 7'b000_0000 ); // 8
    check( 4'b1001, 7'b001_1000 ); // 9
    check( 4'b1010, 7'b000_0000 ); // 10
    check( 4'b1011, 7'b000_0000 ); // 11
    check( 4'b1100, 7'b000_0000 ); // 12
    check( 4'b1101, 7'b000_0000 ); // 13
    check( 4'b1110, 7'b000_0000 ); // 14
    check( 4'b1111, 7'b000_0000 ); // 15
    
  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_3_xprop
//------------------------------------------------------------------------

task test_case_3_xprop();
  t.test_case_begin( "test_case_3_xprop" );

  check( 4'bxxxx, 7'bxxx_xxxx );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

initial begin
  t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
  if ((t.n <= 0) || (t.n == 2)) test_case_2_exhaustive();
  if ((t.n <= 0) || (t.n == 3)) test_case_3_xprop();

  t.test_bench_end();
end

