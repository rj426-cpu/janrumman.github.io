//========================================================================
// Register_32b_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/Register_32b_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  logic clk;
  logic rst_utils;

  TestUtilsClkRst t
  (
    .clk (clk),
    .rst (rst_utils)
  );

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic        rst;
  logic        en;
  logic [31:0] d;
  logic [31:0] q;

  Register_32b_RTL register
  (
    .clk (clk),
    .rst (rst | rst_utils),
    .en  (en),
    .d   (d),
    .q   (q)
  );

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
    input logic [31:0] d_,
    input logic [31:0] q_
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
    check( 0, 1, 32'h0000_0000, 32'h0000_0000 );
    check( 0, 1, 32'h0000_0001, 32'h0000_0000 );
    check( 0, 1, 32'h0000_0000, 32'h0000_0001 );
    check( 0, 1, 32'h0000_0010, 32'h0000_0000 );
    check( 0, 1, 32'h0000_0000, 32'h0000_0010 );

    t.test_case_end();
  endtask

  //------------------------------------------------------------------------
  // test_case_2_directed_ones
  //------------------------------------------------------------------------
  // Test registering different values with a single one

  task test_case_2_directed_ones();
    t.test_case_begin( "test_case_2_directed_ones" );

    //    rst en d                        q
    check( 0, 1, 32'h0000_0000, 32'h0000_0000 );
    check( 0, 1, 32'h0000_0001, 32'h0000_0000 );
    check( 0, 1, 32'h0000_0002, 32'h0000_0001 );
    check( 0, 1, 32'h0000_0004, 32'h0000_0002 );
    check( 0, 1, 32'h0000_0008, 32'h0000_0004 );
    check( 0, 1, 32'h0000_0010, 32'h0000_0008 );
    check( 0, 1, 32'h0000_0020, 32'h0000_0010 );
    check( 0, 1, 32'h0000_0040, 32'h0000_0020 );
    check( 0, 1, 32'h0000_0080, 32'h0000_0040 );
    check( 0, 1, 32'h0000_0100, 32'h0000_0080 );
    check( 0, 1, 32'h0000_0200, 32'h0000_0100 );
    check( 0, 1, 32'h0000_0400, 32'h0000_0200 );
    check( 0, 1, 32'h0000_0800, 32'h0000_0400 );
    check( 0, 1, 32'h0000_1000, 32'h0000_0800 );
    check( 0, 1, 32'h0000_2000, 32'h0000_1000 );
    check( 0, 1, 32'h0000_4000, 32'h0000_2000 );
    check( 0, 1, 32'h0000_8000, 32'h0000_4000 );
    check( 0, 1, 32'h0001_0000, 32'h0000_8000 );
    check( 0, 1, 32'h0002_0000, 32'h0001_0000 );
    check( 0, 1, 32'h0004_0000, 32'h0002_0000 );
    check( 0, 1, 32'h0008_0000, 32'h0004_0000 );
    check( 0, 1, 32'h0010_0000, 32'h0008_0000 );
    check( 0, 1, 32'h0020_0000, 32'h0010_0000 );
    check( 0, 1, 32'h0040_0000, 32'h0020_0000 );
    check( 0, 1, 32'h0080_0000, 32'h0040_0000 );
    check( 0, 1, 32'h0100_0000, 32'h0080_0000 );
    check( 0, 1, 32'h0200_0000, 32'h0100_0000 );
    check( 0, 1, 32'h0400_0000, 32'h0200_0000 );
    check( 0, 1, 32'h0800_0000, 32'h0400_0000 );
    check( 0, 1, 32'h1000_0000, 32'h0800_0000 );
    check( 0, 1, 32'h2000_0000, 32'h1000_0000 );
    check( 0, 1, 32'h4000_0000, 32'h2000_0000 );
    check( 0, 1, 32'h8000_0000, 32'h4000_0000 );
    check( 0, 1, 32'h0000_0000, 32'h8000_0000 );

    t.test_case_end();
  endtask

  //------------------------------------------------------------------------
  // test_case_3_directed_values
  //------------------------------------------------------------------------
  // Test registering different multi-bit values

  task test_case_3_directed_values();
    t.test_case_begin( "test_case_3_directed_values" );

    //    rst en d                        q
    check( 0, 1, 32'h0000_0000, 32'h0000_0000 );
    check( 0, 1, 32'h3333_3333, 32'h0000_0000 );
    check( 0, 1, 32'h5555_5555, 32'h3333_3333 );
    check( 0, 1, 32'haaaa_aaaa, 32'h5555_5555 );
    check( 0, 1, 32'hcccc_cccc, 32'haaaa_aaaa );
    check( 0, 1, 32'h0f0f_0f0f, 32'hcccc_cccc );
    check( 0, 1, 32'hf0f0_f0f0, 32'h0f0f_0f0f );
    check( 0, 1, 32'h0000_0000, 32'hf0f0_f0f0 );
    check( 0, 1, 32'hffff_ffff, 32'h0000_0000 );
    check( 0, 1, 32'h0000_0000, 32'hffff_ffff );

    t.test_case_end();
  endtask

  //------------------------------------------------------------------------
  // test_case_4_directed_enable
  //------------------------------------------------------------------------
  // Test enable input

  task test_case_4_directed_enable();
    t.test_case_begin( "test_case_4_directed_enable" );

    //    rst en d                        q
    check( 0, 1, 32'h0000_0000, 32'h0000_0000 ); // en=1
    check( 0, 1, 32'h3333_3333, 32'h0000_0000 );
    check( 0, 1, 32'hcccc_cccc, 32'h3333_3333 );

    check( 0, 0, 32'hffff_ffff, 32'hcccc_cccc ); // en=0
    check( 0, 0, 32'hf0f0_f0f0, 32'hcccc_cccc );
    check( 0, 0, 32'h0f0f_0f0f, 32'hcccc_cccc );

    check( 0, 1, 32'hffff_ffff, 32'hcccc_cccc ); // en=1
    check( 0, 1, 32'hf0f0_f0f0, 32'hffff_ffff );
    check( 0, 1, 32'h0000_0000, 32'hf0f0_f0f0 );

    t.test_case_end();
  endtask

  //------------------------------------------------------------------------
  // test_case_5_directed_reset
  //------------------------------------------------------------------------
  // Test various reset conditions

  task test_case_5_directed_reset();
    t.test_case_begin( "test_case_5_directed_reset" );

    //    rst en d                        q
    check( 0, 1, 32'h0000_0000, 32'h0000_0000 );
    check( 0, 1, 32'h3333_3333, 32'h0000_0000 );
    check( 0, 1, 32'hcccc_cccc, 32'h3333_3333 );

    check( 1, 1, 32'hffff_ffff, 32'hcccc_cccc ); // rst=1, en=1
    check( 1, 1, 32'h0f0f_0f0f, 32'h0000_0000 );
    check( 1, 1, 32'hffff_ffff, 32'h0000_0000 );

    check( 0, 1, 32'hf0f0_f0f0, 32'h0000_0000 );
    check( 0, 1, 32'h3333_3333, 32'hf0f0_f0f0 );
    check( 0, 1, 32'hcccc_cccc, 32'h3333_3333 );

    check( 1, 0, 32'hffff_ffff, 32'hcccc_cccc ); // rst=1, en=0
    check( 1, 0, 32'h0f0f_0f0f, 32'h0000_0000 );
    check( 1, 0, 32'hffff_ffff, 32'h0000_0000 );

    check( 0, 0, 32'hf0f0_f0f0, 32'h0000_0000 );
    check( 0, 0, 32'h3333_3333, 32'h0000_0000 );
    check( 0, 0, 32'hcccc_cccc, 32'h0000_0000 );

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

    check(  1, 'x, 'x, 'x );
    check(  1, 'x, 'x,  0 );
    check(  1, 'x, 'x,  0 );
    check(  0, 'x, 'x,  0 );
    check(  0, 'x, 'x, 'x );
    check(  0, 'x, 'x, 'x );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

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

endmodule

