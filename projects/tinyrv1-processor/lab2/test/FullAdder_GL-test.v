//========================================================================
// FullAdder_GL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab2/FullAdder_GL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  CombinationalTestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic in0;
  logic in1;
  logic cin;
  logic cout;
  logic sum;

  FullAdder_GL dut
  (
    .in0  (in0),
    .in1  (in1),
    .cin  (cin),
    .cout (cout),
    .sum  (sum)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // We set the inputs, wait 8 tau, check the outputs, wait 2 tau. Each
  // check will take a total of 10 tau.

  task check
  (
    input logic in0_,
    input logic in1_,
    input logic cin_,
    input logic cout_,
    input logic sum_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in0 = in0_;
      in1 = in1_;
      cin = cin_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b + %b + %b > %b %b", t.cycles, in0, in1, cin, cout, sum );

      `ECE2300_CHECK_EQ( cout, cout_ );
      `ECE2300_CHECK_EQ( sum,  sum_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0 in1 cin co  sum
    check( 0,  0,  0,  0,  0 );
    check( 1,  1,  0,  1,  0 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_2_exhaustive
  //----------------------------------------------------------------------

  task test_case_2_exhaustive();
    t.test_case_begin( "test_case_2_exhaustive" );

    //     in0   in1   cin   cout  sum
    check( 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 );
    check( 1'b1, 1'b0, 1'b0, 1'b0, 1'b1 );
    check( 1'b0, 1'b1, 1'b0, 1'b0, 1'b1 );
    check( 1'b1, 1'b1, 1'b0, 1'b1, 1'b0 );

    t.test_case_end();

  endtask

  //----------------------------------------------------------------------
  // test_case_3_xprop
  //----------------------------------------------------------------------

  task test_case_3_xprop();
    t.test_case_begin( "test_case_3_xprop" );

    //     in0 in1 cin co  sum
    check( 'x, 'x, 'x, 'x, 'x );
    check( 'x, 'x,  0, 'x, 'x );
    check( 'x,  0,  0,  0, 'x );
    check( 'x, 'x,  1, 'x, 'x );
    check(  1,  1, 'x,  1, 'x );
    check( 'x,  0,  0,  0, 'x );  
    check( 'x,  1,  1,  1, 'x ); 
    check(  0, 'x, 'x, 'x, 'x );
    check( 'x,  0, 'x, 'x, 'x );  

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

