//========================================================================
// SPI2300_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/SPI_RTL.v"

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

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic        cs;
  logic        sclk;
  logic        mosi;
  logic        miso;

  logic        hmem_val;
  logic [31:0] hmem_addr;
  logic [31:0] hmem_wdata;

  SPI_RTL dut
  (
    .clk        (clk),
    .rst        (rst),

    .cs         (cs),
    .sclk       (sclk),
    .mosi       (mosi),
    .miso       (miso),

    .hmem_val   (hmem_val),
    .hmem_addr  (hmem_addr),
    .hmem_wdata (hmem_wdata)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------

  task check
  (
    input logic        cs_,
    input logic        sclk_,
    input logic        mosi_,

    input logic        hmem_val_,
    input logic [31:0] hmem_addr_,
    input logic [31:0] hmem_wdata_,

    input logic outputs_undefined = 0
  );

    if ( !t.failed ) begin
      t.num_checks += 1;

      cs   = cs_;
      sclk = sclk_;
      mosi = mosi_;

      #8;

      if ( t.n != 0 ) begin
        $write( "%3d: %b ", t.cycles, cs );

        if ( !cs )
          $write( "%b %b %b", sclk, mosi, miso );
        else
          $write( "     " );

        if ( hmem_val )
          $write( " > %b %x %x\n", hmem_val, hmem_addr, hmem_wdata );
        else
          $write( " > \n" );
      end

      if ( !outputs_undefined ) begin
        `ECE2300_CHECK_EQ_HEX( miso,     0         );
        `ECE2300_CHECK_EQ_HEX( hmem_val, hmem_val_ );
        if ( hmem_val ) begin
          `ECE2300_CHECK_EQ_HEX( hmem_addr,  hmem_addr_  );
          `ECE2300_CHECK_EQ_HEX( hmem_wdata, hmem_wdata_ );
        end
      end

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // check_spi_helper
  //----------------------------------------------------------------------
  // The ECE 2300 test framework adds a 1 tau delay with respect to the
  // rising clock edge at the very beginning of the test bench. So if we
  // immediately set the inputs this will take effect 1 tau after the
  // clock edge. Then we wait 8 tau, check the outputs, and wait 2 tau
  // which means the next check will again start 1 tau after the rising
  // clock edge.

  logic save_sclk;

  task check_spi_helper
  (
    input logic        cs_,
    input logic        sclk_,
    input logic        mosi_,

    input logic        hmem_val_,
    input logic [31:0] hmem_addr_,
    input logic [31:0] hmem_wdata_
  );

    if ( !t.failed ) begin
      t.num_checks += 1;

      cs   = cs_;
      sclk = sclk_;
      mosi = mosi_;

      #8;

      if ( t.n != 0 ) begin
        if ( (sclk && !save_sclk) || cs ) begin

          $write( "%3d: %b ", t.cycles, cs );

          if ( !cs )
            $write( "%b %b %b", sclk, mosi, miso );
          else
            $write( "     " );

          if ( hmem_val )
            $write( " > %b %x %x\n", hmem_val, hmem_addr, hmem_wdata );
          else
            $write( " > \n" );
        end
      end

      `ECE2300_CHECK_EQ_HEX( miso,     0         );
      `ECE2300_CHECK_EQ_HEX( hmem_val, hmem_val_ );
      if ( hmem_val ) begin
        `ECE2300_CHECK_EQ_HEX( hmem_addr,  hmem_addr_  );
        `ECE2300_CHECK_EQ_HEX( hmem_wdata, hmem_wdata_ );
      end

      #2;

      save_sclk = sclk_;

    end
  endtask

  //----------------------------------------------------------------------
  // check_spi
  //----------------------------------------------------------------------

  logic [43:0] hmem_data;

  task check_spi
  (
    input logic [31:0] addr,
    input logic [31:0] wdata,
    input integer      half_period
  );

    if ( !t.failed ) begin
      hmem_data = { addr[11:0], wdata };

      //                ---- spi -----  ---------- hmem ----------
      //                cs  sclk  mosi  val addr     wdata
      check_spi_helper( 1,  0,    0,    0,  32'hx,   32'hx         );

      for (int i=0; i<44; i=i+1) begin
        //                  ---- spi -----             ---------- hmem ----------
        //                  cs  sclk  mosi             val addr     wdata
        for (int k=0; k<half_period; k=k+1) begin
          check_spi_helper( 0,  0,    hmem_data[43-i], 0,  32'hx,   32'hx         );
        end

        for (int k=0; k<half_period; k=k+1) begin
          check_spi_helper( 0,  1,    hmem_data[43-i], 0,  32'hx,   32'hx         );
        end
      end

      //                  ---- spi -----  ---------- hmem ----------
      //                  cs  sclk  mosi  val addr     wdata
      for (int i=0; i<half_period; i=i+1) begin
        check_spi_helper( 0,  0,    0,    0,  32'hx,   32'hx         );
      end

      check_spi_helper( 1,  0,    0,    0,  32'hx,   32'hx         );
      check_spi_helper( 1,  0,    0,    0,  32'hx,   32'hx         );
      check_spi_helper( 1,  0,    0,    1,  addr,    wdata         );

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    // First three cycles the outputs are undefined because we
    // cannot reset the synchronizers

    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );
    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );
    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );

    //         addr     wdata
    check_spi( 32'h000, 32'h0000_0001, 3 );
    check_spi( 32'h004, 32'h0000_0002, 3 );
    check_spi( 32'h008, 32'h0000_0003, 3 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_2_directed_extrema
  //----------------------------------------------------------------------

  task test_case_2_directed_extrema();
    t.test_case_begin( "test_case_2_directed_extrema" );

    // First three cycles the outputs are undefined because we
    // cannot reset the synchronizers

    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );
    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );
    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );

    //         addr     wdata
    check_spi( 32'h000, 32'h0000_0000, 3 );
    check_spi( 32'h3dc, 32'hffff_ffff, 3 );
    check_spi( 32'h354, 32'h5555_5555, 3 );
    check_spi( 32'h3a8, 32'haaaa_aaaa, 3 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_directed_program
  //----------------------------------------------------------------------

  task test_case_3_directed_program();
    t.test_case_begin( "test_case_3_directed_program" );

    // First three cycles the outputs are undefined because we
    // cannot reset the synchronizers

    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );
    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );
    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );

    //         addr     wdata
    check_spi( 32'h000, 32'h00200093, 3 );
    check_spi( 32'h004, 32'h00208113, 3 );
    check_spi( 32'h008, 32'h7f000193, 3 );
    check_spi( 32'h00c, 32'h0021a023, 3 );
    check_spi( 32'h010, 32'h0000006f, 3 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_4_period6_random
  //----------------------------------------------------------------------

  logic [31:0] rand_addr;
  logic [31:0] rand_wdata;

  task test_case_4_period6_random();
    t.test_case_begin( "test_case_4_period6_random" );

    // First three cycles the outputs are undefined because we
    // cannot reset the synchronizers

    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );
    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );
    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );

    for (int i=0; i<15; i=i+1) begin

      // Generate random addr and wdata

      rand_addr  = { 22'b0, 8'($urandom(t.seed)), 2'b0};
      rand_wdata = 32'($urandom(t.seed));

      // Send addr and wdata through the spi

      check_spi( rand_addr, rand_wdata, 3 );

    end

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_5_period8_random
  //----------------------------------------------------------------------

  task test_case_5_period8_random();
    t.test_case_begin( "test_case_5_period8_random" );

    // First three cycles the outputs are undefined because we
    // cannot reset the synchronizers

    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );
    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );
    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );

    for (int i=0; i<15; i=i+1) begin

      // Generate random addr and wdata

      rand_addr  = { 22'b0, 8'($urandom(t.seed)), 2'b0};
      rand_wdata = 32'($urandom(t.seed));

      // Send addr and wdata through the spi

      check_spi( rand_addr, rand_wdata, 4 );

    end

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_6_period10_random
  //----------------------------------------------------------------------

  task test_case_6_period10_random();
    t.test_case_begin( "test_case_6_period10_random" );

    // First three cycles the outputs are undefined because we
    // cannot reset the synchronizers

    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );
    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );
    check( 1, 0, 0, 0, 32'hx, 32'hx, t.outputs_undefined );

    for (int i=0; i<15; i=i+1) begin

      // Generate random addr and wdata

      rand_addr  = { 22'b0, 8'($urandom(t.seed)), 2'b0};
      rand_wdata = 32'($urandom(t.seed));

      // Send addr and wdata through the spi

      check_spi( rand_addr, rand_wdata, 5 );

    end

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_directed_extrema();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_directed_program();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_period6_random();
    if ((t.n <= 0) || (t.n == 5)) test_case_5_period8_random();
    if ((t.n <= 0) || (t.n == 6)) test_case_6_period10_random();

    t.test_bench_end();
  end

endmodule
