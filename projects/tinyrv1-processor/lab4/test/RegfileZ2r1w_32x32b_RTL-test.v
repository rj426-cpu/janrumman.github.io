//========================================================================
// RegfileZ2r1w_32x32b_RTL-test
//========================================================================

`include "ece2300/ece2300-misc.v"
`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/RegfileZ2r1w_32x32b_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  logic clk;
  logic rst;

  TestUtilsClkRst t
  (
    .clk (clk),
    .rst (rst)
  );

  `ECE2300_UNUSED( rst );

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic        wen;
  logic  [4:0] waddr;
  logic [31:0] wdata;
  logic  [4:0] raddr0;
  logic [31:0] rdata0;
  logic  [4:0] raddr1;
  logic [31:0] rdata1;

  RegfileZ2r1w_32x32b_RTL dut
  (
    .clk    (clk),
    .wen    (wen),
    .waddr  (waddr),
    .wdata  (wdata),
    .raddr0 (raddr0),
    .rdata0 (rdata0),
    .raddr1 (raddr1),
    .rdata1 (rdata1)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // The ECE 2300 test framework adds a 1 tau delay with respect to the
  // rising clock edge at the very beginning of the test bench. So if we
  // immediately set the inputs this will take effect 1 tau after the clock
  // edge. Then we wait 8 tau, check the outputs, and wait 2 tau which
  // means the next check will again start 1 tau after the rising clock
  // edge.

  task check
  (
    input logic        wen_,
    input logic  [4:0] waddr_,
    input logic [31:0] wdata_,
    input logic  [4:0] raddr0_,
    input logic [31:0] rdata0_,
    input logic  [4:0] raddr1_,
    input logic [31:0] rdata1_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      wen    = wen_;
      waddr  = waddr_;
      wdata  = wdata_;
      raddr0 = raddr0_;
      raddr1 = raddr1_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b %2d %h | %2d %2d > %h %h", t.cycles,
                  wen, waddr, wdata, raddr0, raddr1, rdata0, rdata1 );

      `ECE2300_CHECK_EQ( rdata0, rdata0_ );
      `ECE2300_CHECK_EQ( rdata1, rdata1_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //    wen wa wdata  ra0 rdata0 ra1 rdata1
    check( 1, 1, 32'h0, 0,  32'h0, 0,  32'h0 );
    check( 1, 1, 32'h1, 1,  32'h0, 1,  32'h0 );
    check( 0, 1, 32'h0, 1,  32'h1, 1,  32'h1 );

    t.test_case_end();
  endtask

 task test_case_2_directed_wa();
    t.test_case_begin( "test_case_2_directed_wa" );

    //    wen wa wdata  ra0 rdata0 ra1 rdata1
    check( 1, 1, 32'h0,  0,  32'h0,  0,  32'h0  );
    check( 1, 1, 32'h16, 0,  32'h0,  0,  32'h0  );
    check( 0, 1, 32'h16, 1,  32'h16, 1,  32'h16 );

    // changing wa to 2
    check( 1, 2, 32'h17, 0,  32'h0,  0,  32'h0  );
    check( 0, 2, 32'h17, 2,  32'h17, 2,  32'h17 );

    // changing wa to 3
    check( 1, 3, 32'h18, 0,  32'h0,  0,  32'h0  );
    check( 0, 3, 32'h18, 3,  32'h18, 3,  32'h18 );

    // changing wa to 4
    check( 1, 4, 32'h19, 0,  32'h0,  0,  32'h0  );
    check( 0, 4, 32'h19, 4,  32'h19, 4,  32'h19 );

    // changing wa to 0
    check( 1, 0, 32'h20, 0,  32'h0, 0,  32'h0   );
    check( 0, 0, 32'h20, 0,  32'h0, 0,  32'h0   );

    // changing wa back to 1
    check( 1, 1, 32'h64, 0,  32'h0,  0,  32'h0  );
    check( 0, 1, 32'h64, 1,  32'h64, 1,  32'h64 );

    t.test_case_end();
  endtask

  //------------------------------------------------------------------------
  // test_case_3_directed_wdata
  //------------------------------------------------------------------------

  task test_case_3_directed_wdata();
    t.test_case_begin( "test_case_3_directed_wdata" );
 
    //    large wdata
    //    wen wa      wdata    ra0 rdata0 ra1 rdata1
    check( 1, 1, 32'hFFFF_FFFF, 0,  32'h0,         0,  32'h0         );
    check( 1, 1, 32'hFFFF_FFFF, 0,  32'h0,         0,  32'h0         );
    check( 0, 1, 32'hFFFF_FFFF, 1,  32'hFFFF_FFFF, 1,  32'hFFFF_FFFF );

    //    mixed wdata
    check( 1, 1, 32'hFFFF_0FFF, 0,  32'h0,         0,  32'h0         );
    check( 0, 1, 32'hFFFF_0FFF, 1,  32'hFFFF_0FFF, 1,  32'hFFFF_0FFF );

    //    small wdata
    check( 1, 1, 32'h0FFF, 0,  32'h0,    0,  32'h0    );
    check( 0, 1, 32'h0FFF, 1,  32'h0FFF, 1,  32'h0FFF );

    //    reg0 stays 0  
    check( 1, 0, 32'h00FF, 0,  32'h0, 0,  32'h0 );
    check( 0, 0, 32'h00FF, 0,  32'h0, 0,  32'h0 );
    
    //    alternating wdata 
    check( 1, 1, 32'hAAAA_AAAA, 0,  32'h0,         0,  32'h0         );
    check( 0, 1, 32'hAAAA_AAAA, 1,  32'hAAAA_AAAA, 0,  32'h0         );
    check( 0, 1, 32'hAAAA_AAAA, 0,  32'h0,         1,  32'hAAAA_AAAA );
    check( 0, 1, 32'hAAAA_AAAA, 1,  32'hAAAA_AAAA, 1,  32'hAAAA_AAAA );

    //    nibble boundary wdata
    check( 1, 2, 32'h1234_5678, 0,  32'h0,         0,  32'h0         );
    check( 0, 2, 32'h1234_5678, 2,  32'h1234_5678, 2,  32'h1234_5678 );
  
    //    edge boundary wdata
    check( 1, 2, 32'h0000_0001, 0,  32'h0,         0,  32'h0         );
    check( 0, 2, 32'h0000_0001, 2,  32'h0000_0001, 2,  32'h0000_0001 );

    //    insignificance of wdata when reading
    check( 1, 1, 32'h30D40,     0,  32'h0,     0,  32'h0     );
    check( 0, 1, 32'h0000_0000, 1,  32'h30D40, 1,  32'h30D40 );

    t.test_case_end();
  endtask

  //------------------------------------------------------------------------
  // test_case_4_directed_rdata
  //------------------------------------------------------------------------
  // Test enable input

  task test_case_4_directed_rdata();
    t.test_case_begin( "test_case_4_directed_rdata" );

    //    wen wa wdata  ra0 rdata0 ra1 rdata1
    //    rdata 0 always reads 0 
    check( 1, 1, 32'hFFFF_FFFF, 0,  32'h0, 0,  32'h0 );
    check( 0, 1, 32'hFFFF_FFFF, 0,  32'h0, 0,  32'h0 );
    check( 1, 2, 32'hFFFF_FFFF, 0,  32'h0, 0,  32'h0 );
    check( 0, 2, 32'hFFFF_FFFF, 0,  32'h0, 0,  32'h0 );
    check( 1, 3, 32'hFFFF_FFFF, 0,  32'h0, 0,  32'h0 );
    check( 0, 3, 32'hFFFF_FFFF, 0,  32'h0, 0,  32'h0 );

    //    rdata 1 
    //    wen wa wdata   ra0  rdata0  ra1 rdata1
    check( 1, 1, 32'h1F4, 0,  32'h0,   0,  32'h0   );
    check( 0, 1, 32'h0,   1,  32'h1F4, 1,  32'h1F4 );
    check( 0, 1, 32'h0,   0,  32'h0,   1,  32'h1F4 );
    check( 0, 1, 32'h0,   1,  32'h1F4, 0,  32'h0   );

    //    rdata 2
    //    wen wa wdata   ra0  rdata0  ra1 rdata1
    check( 1, 2, 32'h3E8, 0,  32'h0,   0,  32'h0   );
    check( 0, 2, 32'h0,   2,  32'h3E8, 2,  32'h3E8 );
    check( 0, 2, 32'h0,   0,  32'h0,   2,  32'h3E8 );
    check( 0, 2, 32'h0,   2,  32'h3E8, 0,  32'h0   );

    //    rdata 3
    //    wen wa wdata   ra0  rdata0  ra1 rdata1
    check( 1, 3, 32'h7D0, 0,  32'h0,   0,  32'h0   );
    check( 0, 3, 32'h0,   3,  32'h7D0, 3,  32'h7D0 );
    check( 0, 3, 32'h0,   0,  32'h0,   3,  32'h7D0 );
    check( 0, 3, 32'h0,   3,  32'h7D0, 0,  32'h0   );

    //    rdata 4
    //    wen wa wdata   ra0  rdata0  ra1 rdata1
    check( 1, 4, 32'hBB8, 0,  32'h0,   0,  32'h0   );
    check( 0, 4, 32'h0,   4,  32'hBB8, 4,  32'hBB8 );
    check( 0, 4, 32'h0,   0,  32'h0,   4,  32'hBB8 );
    check( 0, 4, 32'h0,   4,  32'hBB8, 0,  32'h0   );   
    
    //    mixed rdata and insignificant wa + wdata
    //    wen wa wdata   ra0  rdata0  ra1 rdata1
    check( 0, 0, 32'h0, 1,  32'h1F4, 1,  32'h1F4 );
    check( 0, 0, 32'h0, 2,  32'h3E8, 2,  32'h3E8 );
    check( 0, 0, 32'h0, 3,  32'h7D0, 3,  32'h7D0 );
    check( 0, 0, 32'h0, 4,  32'hBB8, 4,  32'hBB8 );
    check( 0, 1, 32'h0, 1,  32'h1F4, 2,  32'h3E8 );
    check( 0, 1, 32'h0, 2,  32'h3E8, 3,  32'h7D0 );
    check( 0, 3, 32'h0, 3,  32'h7D0, 4,  32'hBB8 );
    check( 0, 4, 32'h0, 4,  32'hBB8, 1,  32'h1F4 );

    t.test_case_end();
  endtask

  //------------------------------------------------------------------------
  // test_case_5_random
  //------------------------------------------------------------------------

  // Declaring variables
  logic          random_wen;
  logic [4:0 ] random_waddr;
  logic [31:0] random_wdata;
  logic [4:0] random_ra0;
  logic [4:0] random_ra1;
  logic [31:0] expected_rd0;
  logic [31:0] expected_rd1;
  logic [31:0] ref_regfile [32];

  task test_case_5_random();
    t.test_case_begin( "test_case_5_random" );

    for ( int i = 0; i < 32; i = i+1 ) begin
      ref_regfile[i] = 0;
    //      wen   wa    wdata ra0  rdata0  ra1 rdata1
      check( 1, i[4:0], 32'h0, 0,    0,     0,   0 );
    end

    // Run 50 random test cases
    for ( int i = 0; i < 50; i += 1) begin

      // Generate random values
      random_wen   = 1'($urandom(t.seed));
      random_wdata = 32'($urandom(t.seed));
      random_waddr = 5'($urandom(t.seed));
      random_ra0   = 5'($urandom(t.seed));
      random_ra1   = 5'($urandom(t.seed));

      if (random_ra0 == 5'h0) 
      expected_rd0 = 32'h0;
      else
      expected_rd0 = ref_regfile[random_ra0];

      if (random_ra1 == 5'h0) 
      expected_rd1 = 32'h0;
      else
      expected_rd1 = ref_regfile[random_ra1];

      check(random_wen, random_waddr, random_wdata, 
          random_ra0, expected_rd0,
          random_ra1, expected_rd1);

    if (random_wen && (random_waddr != 5'h0)) begin
      ref_regfile[random_waddr] = random_wdata;
    end
    end

    t.test_case_end();
  endtask

  //------------------------------------------------------------------------
  // test_case_6_xprop
  //------------------------------------------------------------------------

  task test_case_6_xprop();
    t.test_case_begin( "test_case_6_xprop" );

    //     wen  wa wdata  ra0 rdata0 ra1 rdata1
    check( 'x, 'x, 32'bx, 'x,  32'bx, 'x,  32'bx );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1))           test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2))     test_case_2_directed_wa();
    if ((t.n <= 0) || (t.n == 3))  test_case_3_directed_wdata();
    if ((t.n <= 0) || (t.n == 4))  test_case_4_directed_rdata();
    if ((t.n <= 0) || (t.n == 5))          test_case_5_random();
    if ((t.n <= 0) || (t.n == 6))           test_case_6_xprop();

    t.test_bench_end();
  end

endmodule

