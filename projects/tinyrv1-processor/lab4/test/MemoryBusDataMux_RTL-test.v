//========================================================================
// MemoryBusDataMux_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/MemoryBusDataMux_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  CombinationalTestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic [31:0] std;
  logic [31:0] in0;
  logic [31:0] in1;
  logic [31:0] in2;
  logic [31:0] in3;
  logic [31:0] addr;
  logic [31:0] out;

  MemoryBusDataMux_RTL dut
  (
    .std  (std),
    .in0  (in0),
    .in1  (in1),
    .in2  (in2),
    .in3  (in3),
    .addr (addr),
    .out  (out)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // We set the inputs, wait 8 tau, check the outputs, wait 2 tau. Each
  // check will take a total of 10 tau.

  task check
  (
    input logic [31:0] std_,
    input logic [31:0] in0_,
    input logic [31:0] in1_,
    input logic [31:0] in2_,
    input logic [31:0] in3_,
    input logic [31:0] addr_,
    input logic [31:0] out_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      std  = std_;
      in0  = in0_;
      in1  = in1_;
      in2  = in2_;
      in3  = in3_;
      addr = addr_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %h %h %h %h %h %3h > %h", t.cycles, std,
                  std, in0, in1, in2, in3, addr, out );

      `ECE2300_CHECK_EQ( out, out_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     std       in0       in1       in2       in3       addr     out
    check( 32'h0000, 32'h0000, 32'h0000, 32'h0000, 32'h0000, 32'h000, 32'h0000 );
    check( 32'h0000, 32'h0000, 32'h0000, 32'h0000, 32'h0000, 32'h000, 32'h0000 );
    check( 32'h0000, 32'h0000, 32'h0000, 32'h0000, 32'h0000, 32'h000, 32'h0000 );
    check( 32'h0000, 32'h0000, 32'h0000, 32'h0000, 32'h0000, 32'h000, 32'h0000 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_2_standard
  //----------------------------------------------------------------------

  task test_case_2_standard();
    t.test_case_begin( "test_case_2_standard" );

    //     std       in0       in1       in2       in3       addr     out
    check( 32'h0000, 32'h3333, 32'h5555, 32'haaaa, 32'hcccc, 32'h000, 32'h0000 );
    check( 32'h0000, 32'h3333, 32'h5555, 32'haaaa, 32'hcccc, 32'h004, 32'h0000 );
    check( 32'h0000, 32'h3333, 32'h5555, 32'haaaa, 32'hcccc, 32'h008, 32'h0000 );
    check( 32'h0000, 32'h3333, 32'h5555, 32'haaaa, 32'hcccc, 32'h00c, 32'h0000 );
    check( 32'h0000, 32'h3333, 32'h5555, 32'haaaa, 32'hcccc, 32'h010, 32'h0000 );
    check( 32'h0000, 32'h3333, 32'h5555, 32'haaaa, 32'hcccc, 32'h100, 32'h0000 );
    check( 32'h0000, 32'h3333, 32'h5555, 32'haaaa, 32'hcccc, 32'h1fc, 32'h0000 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_non_standard
  //----------------------------------------------------------------------

  task test_case_3_non_standard();
    t.test_case_begin( "test_case_3_non_standard" );

    //     std       in0       in1       in2       in3       addr     out
    check( 32'h0000, 32'h3333_3333, 32'h5555_5555, 32'haaaa_aaaa, 32'hcccc_cccc, 32'h200, 32'h3333_3333 );
    check( 32'h0000, 32'h3333_3333, 32'h5555_5555, 32'haaaa_aaaa, 32'hcccc_cccc, 32'h204, 32'h5555_5555 );
    check( 32'h0000, 32'h3333_3333, 32'h5555_5555, 32'haaaa_aaaa, 32'hcccc_cccc, 32'h208, 32'haaaa_aaaa );
    check( 32'h0000, 32'h3333_3333, 32'h5555_5555, 32'haaaa_aaaa, 32'hcccc_cccc, 32'h20c, 32'hcccc_cccc );

    check( 32'h0000, 32'h1010_1010, 32'h2020_2020, 32'h3030_3030, 32'h4040_4040, 32'h200, 32'h1010_1010 );
    check( 32'h0000, 32'h1010_1010, 32'h2020_2020, 32'h3030_3030, 32'h4040_4040, 32'h204, 32'h2020_2020 );
    check( 32'h0000, 32'h1010_1010, 32'h2020_2020, 32'h3030_3030, 32'h4040_4040, 32'h208, 32'h3030_3030 );
    check( 32'h0000, 32'h1010_1010, 32'h2020_2020, 32'h3030_3030, 32'h4040_4040, 32'h20c, 32'h4040_4040 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_4_random
  //----------------------------------------------------------------------

  logic [31:0] rand_std;
  logic [31:0] rand_in0;
  logic [31:0] rand_in1;
  logic [31:0] rand_in2;
  logic [31:0] rand_in3;
  logic        rand_io;
  logic [31:0] rand_addr;
  logic [31:0] rand_out;

  task test_case_4_random();
    t.test_case_begin( "test_case_4_random" );

    for ( int i = 0; i < 50; i = i+1 ) begin

      // Generate random values for inputs and addr

      rand_std = 32'($urandom(t.seed));
      rand_in0 = 32'($urandom(t.seed));
      rand_in1 = 32'($urandom(t.seed));
      rand_in2 = 32'($urandom(t.seed));
      rand_in3 = 32'($urandom(t.seed));
      rand_io  = 1'($urandom(t.seed));

      if ( rand_io )
        rand_addr = { 27'b0, 3'($urandom(t.seed)), 2'b0 };
      else
        rand_addr = { 25'b0, 5'($urandom(t.seed)), 2'b0 };

      // Determine correct answer

      if ( rand_addr < 32'h200 )
        rand_out = rand_std;
      else if ( rand_addr == 32'h200 )
        rand_out = rand_in0;
      else if ( rand_addr == 32'h204 )
        rand_out = rand_in1;
      else if ( rand_addr == 32'h208 )
        rand_out = rand_in2;
      else if ( rand_addr == 32'h20c )
        rand_out = rand_in3;

      // Check DUT output matches correct answer

      check( rand_std, rand_in0, rand_in1, rand_in2, rand_in3, rand_addr, rand_out );

    end

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_standard();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_non_standard();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_random();

    t.test_bench_end();
  end

endmodule
