//========================================================================
// Register_16b-test-cases
//========================================================================
// This file is meant to be included in a test bench.

//------------------------------------------------------------------------
// check
//------------------------------------------------------------------------
// The ECE 2300 test framework adds a 1 tau delay with respect to the
// rising clock edge at the very beginning of the test bench. So if we
// immediately set the inputs this will take effect 1 tau after the clock
// edge. Then we wait 8 tau, check the outputs, and wait 2 tau which
// means the next check will again start 1 tau after the rising clock
// edge.

task check
(
  input logic        rst_,
  input logic        en_,
  input logic [15:0] d_,
  input logic [15:0] q_
);
  if ( !t.failed ) begin
    t.num_checks += 1;

    rst = rst_;
    en  = en_;
    d   = d_;

    #8;

    if ( t.n != 0 )
      $display( "%3d: %b %b %h > %h", t.cycles, rst, en, d, q );

    `ECE2300_CHECK_EQ( q, q_ );

    #2;

  end
endtask

//----------------------------------------------------------------------
// test_case_1_basic
//----------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  //    rst en d                        q
  check( 0, 1, 16'b0000_0000_0000_0000, 16'b0000_0000_0000_0000 );
  check( 0, 1, 16'b0000_0000_0000_0001, 16'b0000_0000_0000_0000 );
  check( 0, 1, 16'b0000_0000_0000_0000, 16'b0000_0000_0000_0001 );
  check( 0, 1, 16'b0000_0000_0000_0010, 16'b0000_0000_0000_0000 );
  check( 0, 1, 16'b0000_0000_0000_0000, 16'b0000_0000_0000_0010 );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_2_directed_ones
//------------------------------------------------------------------------
// Test registering different values with a single one

task test_case_2_directed_ones();
  t.test_case_begin( "test_case_2_directed_ones" );

  //''' LAB ASSIGNMENT '''''''''''''''''''''''''''''''''''''''''''''''''''
  // Add checks for different values with a single one
  //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // We provide you the following template, simply replace 'x with the
  // correct value for q for every check. Note that we are no longer
  // explicitly toggling the clock. This is analogous to the
  // implicit-clock simulation tables discussed in lecture. The ECE 2300
  // testing framework will (1) reset the DUT in test_case_begin and (2)
  // toggle the clock once for every check. Every check waits 1 tau, sets
  // the inputs, waits 8 tau, and then checks the outputs.

  //    rst en d                        q
  check( 0, 1, 16'b0000_0000_0000_0000, 16'b0000_0000_0000_0000 );
  check( 0, 1, 16'b0000_0000_0000_0001, 16'b0000_0000_0000_0000 );
  check( 0, 1, 16'b0000_0000_0000_0010, 16'b0000_0000_0000_0001 );
  check( 0, 1, 16'b0000_0000_0000_0100, 16'b0000_0000_0000_0010 );
  check( 0, 1, 16'b0000_0000_0000_1000, 16'b0000_0000_0000_0100 );
  check( 0, 1, 16'b0000_0000_0001_0000, 16'b0000_0000_0000_1000 );
  check( 0, 1, 16'b0000_0000_0010_0000, 16'b0000_0000_0001_0000 );
  check( 0, 1, 16'b0000_0000_0100_0000, 16'b0000_0000_0010_0000 );
  check( 0, 1, 16'b0000_0000_1000_0000, 16'b0000_0000_0100_0000 );
  check( 0, 1, 16'b0000_0001_0000_0000, 16'b0000_0000_1000_0000 );
  check( 0, 1, 16'b0000_0010_0000_0000, 16'b0000_0001_0000_0000 );
  check( 0, 1, 16'b0000_0100_0000_0000, 16'b0000_0010_0000_0000 );
  check( 0, 1, 16'b0000_1000_0000_0000, 16'b0000_0100_0000_0000 );
  check( 0, 1, 16'b0001_0000_0000_0000, 16'b0000_1000_0000_0000 );
  check( 0, 1, 16'b0010_0000_0000_0000, 16'b0001_0000_0000_0000 );
  check( 0, 1, 16'b0100_0000_0000_0000, 16'b0010_0000_0000_0000 );
  check( 0, 1, 16'b1000_0000_0000_0000, 16'b0100_0000_0000_0000 );
  check( 0, 1, 16'b0000_0000_0000_0000, 16'b1000_0000_0000_0000 );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_3_directed_values
//------------------------------------------------------------------------
// Test registering different multi-bit values

task test_case_3_directed_values();
  t.test_case_begin( "test_case_3_directed_values" );

  // We provide you the following template, simply replace 'x with
  // the correct value for q for every check

  //    rst en d                        q
  check( 0, 1, 16'b0000_0000_0000_0000, 16'b0000_0000_0000_0000 );
  check( 0, 1, 16'b0011_0011_0011_0011, 16'b0000_0000_0000_0000 );
  check( 0, 1, 16'b1100_1100_1100_1100, 16'b0011_0011_0011_0011 );
  check( 0, 1, 16'b0000_1111_0000_1111, 16'b1100_1100_1100_1100 );
  check( 0, 1, 16'b1111_0000_1111_0000, 16'b0000_1111_0000_1111 );
  check( 0, 1, 16'b0000_0000_0000_0000, 16'b1111_0000_1111_0000 );
  check( 0, 1, 16'b1111_1111_1111_1111, 16'b0000_0000_0000_0000 );
  check( 0, 1, 16'b0000_0000_0000_0000, 16'b1111_1111_1111_1111 );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_4_directed_enable
//------------------------------------------------------------------------
// Test enable input

task test_case_4_directed_enable();
  t.test_case_begin( "test_case_4_directed_enable" );

  //''' LAB ASSIGNMENT '''''''''''''''''''''''''''''''''''''''''''''''''''
  // Add checks for enable
  //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // We provide you the following template, simply replace 'x with
  // the correct value for q for every check

  //    rst en d                        q
  check( 0, 1, 16'b0000_0000_0000_0000, 16'b0000_0000_0000_0000 ); // en=1
  check( 0, 1, 16'b0011_0011_0011_0011, 16'b0000_0000_0000_0000 );
  check( 0, 1, 16'b1100_1100_1100_1100, 16'b0011_0011_0011_0011 );

  check( 0, 0, 16'b1111_1111_1111_1111, 16'b1100_1100_1100_1100 ); // en=0
  check( 0, 0, 16'b1111_0000_1111_0000, 16'b1100_1100_1100_1100 );
  check( 0, 0, 16'b0000_1111_0000_1111, 16'b1100_1100_1100_1100 );

  check( 0, 1, 16'b1111_1111_1111_1111, 16'b1100_1100_1100_1100 ); // en=1
  check( 0, 1, 16'b1111_0000_1111_0000, 16'b1111_1111_1111_1111 );
  check( 0, 1, 16'b0000_0000_0000_0000, 16'b1111_0000_1111_0000 );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_5_directed_reset
//------------------------------------------------------------------------
// Test various reset conditions

task test_case_5_directed_reset();
  t.test_case_begin( "test_case_5_directed_reset" );

  // We provide you the following template, simply replace 'x with
  // the correct value for q for every check

  //    rst en d                        q
  check( 0, 1, 16'b0000_0000_0000_0000, 16'b0000_0000_0000_0000 );
  check( 0, 1, 16'b0011_0011_0011_0011, 16'b0000_0000_0000_0000 );
  check( 0, 1, 16'b1100_1100_1100_1100, 16'b0011_0011_0011_0011 );

  check( 1, 1, 16'b1111_1111_1111_1111, 16'b1100_1100_1100_1100 ); // rst=1, en=1
  check( 1, 1, 16'b0000_1111_0000_1111, 16'b0000_0000_0000_0000 );
  check( 1, 1, 16'b1111_1111_1111_1111, 16'b0000_0000_0000_0000 );

  check( 0, 1, 16'b1111_0000_1111_0000, 16'b0000_0000_0000_0000 );
  check( 0, 1, 16'b0011_0011_0011_0011, 16'b1111_0000_1111_0000 );
  check( 0, 1, 16'b1100_1100_1100_1100, 16'b0011_0011_0011_0011 );

  check( 1, 0, 16'b1111_1111_1111_1111, 16'b1100_1100_1100_1100 ); // rst=1, en=0
  check( 1, 0, 16'b0000_1111_0000_1111, 16'b0000_0000_0000_0000 );
  check( 1, 0, 16'b1111_1111_1111_1111, 16'b0000_0000_0000_0000 );

  check( 0, 0, 16'b1111_0000_1111_0000, 16'b0000_0000_0000_0000 );
  check( 0, 0, 16'b0011_0011_0011_0011, 16'b0000_0000_0000_0000 );
  check( 0, 0, 16'b1100_1100_1100_1100, 16'b0000_0000_0000_0000 );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_6_xprop
//------------------------------------------------------------------------

task test_case_6_xprop();
  t.test_case_begin( "test_case_6_xprop" );

  //     rst  en  d   q
  check( 'x, 'x, 'x,  0 );
  check( 'x, 'x, 'x, 'x );
  check( 'x, 'x, 'x, 'x );
  check( 'x, 'x, 'x, 'x );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

initial begin
  t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
  if ((t.n <= 0) || (t.n == 2)) test_case_2_directed_ones();
  if ((t.n <= 0) || (t.n == 3)) test_case_3_directed_values();
  if ((t.n <= 0) || (t.n == 4)) test_case_4_directed_enable();
  if ((t.n <= 0) || (t.n == 5)) test_case_5_directed_reset();
  if ((t.n <= 0) || (t.n == 6)) test_case_6_xprop();

  t.test_bench_end();
end

