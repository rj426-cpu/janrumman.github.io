//========================================================================
// Mux2_8b_GL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab2/Mux2_8b_GL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  CombinationalTestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic [7:0] in0;
  logic [7:0] in1;
  logic       sel;
  logic [7:0] out;

  Mux2_8b_GL dut
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
    input logic [7:0] in0_,
    input logic [7:0] in1_,
    input logic       sel_,
    input logic [7:0] out_
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

    //     in0           in1           sel   out
    check( 8'b0000_0000, 8'b0000_0000, 1'b0, 8'b0000_0000 );
    check( 8'b0000_0000, 8'b0000_0000, 1'b1, 8'b0000_0000 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // Directed Tests
  //----------------------------------------------------------------------

  // when sel=0, out must equal in0
  task test_case_2_sel0();
    t.test_case_begin( "test_case_2_sel0" );

    //     in0           in1           sel   out
    check( 8'b0000_0000, 8'b1111_1111, 1'b0, 8'b0000_0000 ); // in0 is 0
    check( 8'b1111_1111, 8'b0000_0000, 1'b0, 8'b1111_1111 ); // in1 is 0
    check( 8'b1111_1111, 8'b1111_1111, 1'b0, 8'b1111_1111 ); // in0 and in1 are non zero

    t.test_case_end();
  endtask

  // when sel=1, out must equal in1
  task test_case_3_sel1();
    t.test_case_begin( "test_case_3_sel1" );

    //     in0           in1           sel   out
    check( 8'b0000_0000, 8'b1111_1111, 1'b1, 8'b1111_1111 ); // in0 is 0
    check( 8'b1111_1111, 8'b0000_0000, 1'b1, 8'b0000_0000 ); // in1 is 0
    check( 8'b1111_1111, 8'b1111_1111, 1'b1, 8'b1111_1111 ); // in0 and in1 are non zero

    t.test_case_end();
  endtask  

  // when the inputs are equal, output should match regardless of sel
  task test_case_4_equal_in();
    t.test_case_begin( "test_case_4_equal_in" );

    //     in0           in1           sel   out
    check( 8'b1111_0000, 8'b1111_0000, 1'b0, 8'b1111_0000 ); 
    check( 8'b1111_0000, 8'b1111_0000, 1'b1, 8'b1111_0000 ); 
    check( 8'b1010_1010, 8'b1010_1010, 1'b0, 8'b1010_1010 ); 
    check( 8'b1010_1010, 8'b1010_1010, 1'b1, 8'b1010_1010 ); 
    check( 8'b0101_0101, 8'b0101_0101, 1'b0, 8'b0101_0101 );
    check( 8'b0101_0101, 8'b0101_0101, 1'b1, 8'b0101_0101 );    

    t.test_case_end();
  endtask  

  //----------------------------------------------------------------------
  // Random Test
  //----------------------------------------------------------------------

  logic [7:0] random_in0;
  logic [7:0] random_in1;
  logic       random_sel;
  logic [7:0] expected_out;

  task test_case_5_random();
    t.test_case_begin( "test_case_5_random" );

    // Generate 50 random test cases
    for (int i = 0; i < 50; i = i + 1) begin

      // Generate a 16-bit random value for in0, in1, and 1-bit for cin
      random_in0 = 8'($urandom(t.seed));
      random_in1 = 8'($urandom(t.seed));
      random_sel = 1'($urandom(t.seed));
    
      if ( random_sel == 1'b0 )
        expected_out = random_in0;
      else 
        expected_out = random_in1;

      //     in0           in1           sel         out  
      check( random_in0,   random_in1,   random_sel, expected_out );

    end 
    t.test_case_end();

  endtask

  task test_case_6_xprop();
    t.test_case_begin( "test_case_6_xprop" );

    //     in0           in1           sel   out
    check( 8'bxxxx_xxxx, 8'bxxxx_xxxx, 1'bx, 8'bxxxx_xxxx ); 
    check( 8'bxxxx_xxxx, 8'bxxxx_xxxx, 1'b0, 8'bxxxx_xxxx ); 
    check( 8'bxxxx_xxxx, 8'b0000_0000, 1'b0, 8'bxxxx_xxxx ); 
    check( 8'bxxxx_xxxx, 8'b0000_0000, 1'b1, 8'b0000_0000 ); 
    check( 8'b0000_0000, 8'b0000_0000, 1'bx, 8'b0000_0000 ); 
    check( 8'bxxxx_xxxx, 8'b1111_1111, 1'b1, 8'b1111_1111 ); 
    check( 8'b0000_0000, 8'b1111_1111, 1'bx, 8'bxxxx_xxxx );

    t.test_case_end();
  endtask  
  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1))    test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2))     test_case_2_sel0();
    if ((t.n <= 0) || (t.n == 3))     test_case_3_sel1();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_equal_in();
    if ((t.n <= 0) || (t.n == 5))   test_case_5_random();
    if ((t.n <= 0) || (t.n == 6))    test_case_6_xprop();

    t.test_bench_end();
  end

endmodule

