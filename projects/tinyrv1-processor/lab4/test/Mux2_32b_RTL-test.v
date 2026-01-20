//========================================================================
// Mux2_32b_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/Mux2_32b_RTL.v"

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
  logic        sel;
  logic [31:0] out;

  Mux2_32b_RTL dut
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
    input logic [31:0] in0_,
    input logic [31:0] in1_,
    input logic        sel_,
    input logic [31:0] out_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in0 = in0_;
      in1 = in1_;
      sel = sel_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %h %h %b > %h", t.cycles, in0, in1, sel, out );

      `ECE2300_CHECK_EQ( out, out_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0            in1            sel   out
    check( 32'h0000_0000, 32'h0000_0000, 1'b0, 32'h0000_0000 );
    check( 32'h0000_0000, 32'h0000_0000, 1'b1, 32'h0000_0000 );

    t.test_case_end();
  endtask

task test_case_2_same();
    t.test_case_begin( "test_case_2_same" );

    //     in0            in1           sel   out
    check( 32'hFFFF_FFFF, 32'hFFFF_FFFF, 0,    32'hFFFF_FFFF ); // sel = 0, out = FFFF_FFFF
    check( 32'hFFFF_FFFF, 32'hFFFF_FFFF, 1,    32'hFFFF_FFFF ); // sel = 1, out = FFFF_FFFF

    t.test_case_end();
  endtask

  task test_case_3_alternate();
    t.test_case_begin( "test_case_3_alternate" );

    //     in0            in1           sel        out
    check( 32'h1212_1212, 32'h0000_0000, 0,   32'h1212_1212 ); // sel = 0, out = 1212_1212
    check( 32'h1212_1212, 32'h0000_0000, 1,   32'h0000_0000 ); // sel = 1, out = 0000_0000
    check( 32'h0000_0000, 32'h1212_1212, 0,   32'h0000_0000 ); // sel = , out = 0000_0000
    check( 32'h0000_0000, 32'h1212_1212, 1,   32'h1212_1212 ); // sel = 1, out = 1212_1212
    t.test_case_end();
  endtask

  task test_case_4_patterns();
    t.test_case_begin( "test_case_4_patterns" );

    //     in0            in1             sel       out
    check( 32'h1234_5678, 32'h9ABC_DEF0,  0,   32'h1234_5678 ); 
    check( 32'hAAAA_BBBB, 32'hCCCC_DDDD,  1,   32'hCCCC_DDDD ); 
    check( 32'h7654_3210, 32'hFEDC_BA98,  0,   32'h7654_3210 );
    check( 32'h2222_2222, 32'h4444_4444,  1,   32'h4444_4444 ); 

    t.test_case_end();

  endtask

  //----------------------------------------------------------------------
  // test_case_5_random
  //----------------------------------------------------------------------

  //declaring variables for input and output
  logic [31:0]      random_in0;
  logic [31:0]      random_in1;
  logic             random_sel;
  logic [31:0]    expected_out;

  task test_case_5_random();
    t.test_case_begin("test_case_5_random");

      // Run 50 iterations / perform 50 randomized tests
      for ( int i = 0; i < 50; i = i+1 ) begin

        // Generate a 32-bit random value for in0, in1, in2, in3 and 1-bit for sel

        random_in0 = 32'($urandom(t.seed));
        random_in1 = 32'($urandom(t.seed));
        random_sel = 1'($urandom(t.seed));
          
        if ( random_sel == 1'b0 ) 
          expected_out = random_in0;
        else if ( random_sel == 1'b1 ) 
          expected_out = random_in1;
        end
          
        // Apply the random input values and check the output value
        check( random_in0, random_in1, random_sel, expected_out);
      
    t.test_case_end();

  endtask

  //------------------------------------------------------------------------
  // test_case_6_xprop
  //------------------------------------------------------------------------

  task test_case_6_xprop();
    t.test_case_begin("test_case_6_xprop");

      check( 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx,
             32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx,
             'x, 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx );

      check( 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx,
             32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx,
             1'b0, 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx );

      check( 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx,
             32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx,
             1'b1, 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx );

      check( 32'b0000_0000_0000_0000_0000_0000_0000_0000,
             32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx,
             1'b0, 32'b0000_0000_0000_0000_0000_0000_0000_0000 );

      check( 32'b0000_0000_0000_0000_0000_0000_0000_0000,
             32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx,
             1'b1, 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx );

      check( 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx,
             32'b0000_0000_0000_0000_0000_0000_0000_0000,
             1'b1, 32'b0000_0000_0000_0000_0000_0000_0000_0000 );

      check( 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx,
             32'b0000_0000_0000_0000_0000_0000_0000_0000,
             1'b0, 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx );

      check( 32'b1111_1111_1111_1111_1111_1111_1111_1111,
             32'b0000_0000_0000_0000_0000_0000_0000_0000,
             'x, 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();
    if ((t.n <= 0) || (t.n == 1))           test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2))            test_case_2_same();
    if ((t.n <= 0) || (t.n == 3))       test_case_3_alternate();
    if ((t.n <= 0) || (t.n == 4))        test_case_4_patterns();
    if ((t.n <= 0) || (t.n == 5))          test_case_5_random();
    if ((t.n <= 0) || (t.n == 6))           test_case_6_xprop();
    t.test_bench_end();
  end

endmodule

