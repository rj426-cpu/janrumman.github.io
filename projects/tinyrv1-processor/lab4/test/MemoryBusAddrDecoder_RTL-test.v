//========================================================================
// MemoryBusAddrDecoder_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/MemoryBusAddrDecoder_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  CombinationalTestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic        en;
  logic [31:0] addr;

  logic        out0_en;
  logic        out1_en;
  logic        out2_en;
  logic        out3_en;

  MemoryBusAddrDecoder_RTL dut
  (
    .en       (en),
    .addr     (addr),

    .out0_en  (out0_en),
    .out1_en  (out1_en),
    .out2_en  (out2_en),
    .out3_en  (out3_en)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // We set the inputs, wait 8 tau, check the outputs, wait 2 tau. Each
  // check will take a total of 10 tau.

  task check
  (
    input logic        en_,
    input logic [31:0] addr_,
    input logic        out0_en_,
    input logic        out1_en_,
    input logic        out2_en_,
    input logic        out3_en_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      en   = en_;
      addr = addr_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b %3h > %b %b %b %b", t.cycles, en, addr,
                  out0_en, out1_en, out2_en, out3_en );

      `ECE2300_CHECK_EQ( out0_en, out0_en_ );
      `ECE2300_CHECK_EQ( out1_en, out1_en_ );
      `ECE2300_CHECK_EQ( out2_en, out2_en_ );
      `ECE2300_CHECK_EQ( out3_en, out3_en_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     en  addr     out0  out1  out2  out3
    check( 0,  32'h000, 0,    0,    0,    0    );
    check( 0,  32'h000, 0,    0,    0,    0    );
    check( 0,  32'h000, 0,    0,    0,    0    );
    check( 0,  32'h000, 0,    0,    0,    0    );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_2_directed_val_type
  //----------------------------------------------------------------------

  task test_case_2_directed_val_type();
    t.test_case_begin( "test_case_2_directed_val_type" );

    //     en  addr     out0  out1  out2  out3
    check( 0,  32'h000, 0,    0,    0,    0    );
    check( 1,  32'h000, 0,    0,    0,    0    );

    check( 0,  32'h210, 0,    0,    0,    0    );
    check( 1,  32'h210, 1,    0,    0,    0    );

    check( 0,  32'h214, 0,    0,    0,    0    );
    check( 1,  32'h214, 0,    1,    0,    0    );

    check( 0,  32'h218, 0,    0,    0,    0    );
    check( 1,  32'h218, 0,    0,    1,    0    );

    check( 0,  32'h21c, 0,    0,    0,    0    );
    check( 1,  32'h21c, 0,    0,    0,    1    );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_directed_any_addr
  //----------------------------------------------------------------------

  task test_case_3_directed_any_addr();
    t.test_case_begin( "test_case_3_directed_any_addr" );

    //     en  addr     out0  out1  out2  out3
    check( 1,  32'h000, 0,    0,    0,    0    );
    check( 1,  32'h004, 0,    0,    0,    0    );
    check( 1,  32'h008, 0,    0,    0,    0    );
    check( 1,  32'h00c, 0,    0,    0,    0    );

    check( 1,  32'h010, 0,    0,    0,    0    );
    check( 1,  32'h104, 0,    0,    0,    0    );
    check( 1,  32'h118, 0,    0,    0,    0    );
    check( 1,  32'h17c, 0,    0,    0,    0    );

    check( 1,  32'h200, 0,    0,    0,    0    );
    check( 1,  32'h204, 0,    0,    0,    0    );
    check( 1,  32'h208, 0,    0,    0,    0    );
    check( 1,  32'h20c, 0,    0,    0,    0    );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_4_random
  //----------------------------------------------------------------------

  logic        rand_en;
  logic        rand_io;
  logic [31:0] rand_addr;

  logic        rand_out0_en;
  logic        rand_out1_en;
  logic        rand_out2_en;
  logic        rand_out3_en;

  task test_case_4_random();
    t.test_case_begin( "test_case_4_random" );

    for ( int i = 0; i < 50; i = i+1 ) begin

      // Generate random values for en and addr

      rand_en = 1'($urandom(t.seed));
      rand_io = 1'($urandom(t.seed));

      if ( rand_io )
        rand_addr = { 27'b10_000, 3'($urandom(t.seed)), 2'b0 };
      else
        rand_addr = { 25'b0, 5'($urandom(t.seed)), 2'b0 };

      // Determine correct answer

      rand_out0_en = 1'b0;
      rand_out1_en = 1'b0;
      rand_out2_en = 1'b0;
      rand_out3_en = 1'b0;

      if ( rand_en && (rand_addr == 32'h210) )
        rand_out0_en = 1'b1;
      else if ( rand_en && (rand_addr == 32'h214) )
        rand_out1_en = 1'b1;
      else if ( rand_en && (rand_addr == 32'h218) )
        rand_out2_en = 1'b1;
      else if ( rand_en && (rand_addr == 32'h21c) )
        rand_out3_en = 1'b1;

      // Check DUT output matches correct answer

      check( rand_en, rand_addr,
             rand_out0_en, rand_out1_en, rand_out2_en, rand_out3_en );

    end

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_5_xprop
  //----------------------------------------------------------------------

  task test_case_5_xprop();
    t.test_case_begin( "test_case_5_xprop" );

    //     en  addr     out0  out1  out2  out3
    check( 'x, 'x,      'x,   'x,   'x,   'x    );

    check( 'x, 32'h000,  0,    0,    0,    0    );
    check( 'x, 32'h100,  0,    0,    0,    0    );

    check(  1, 'x,      'x,   'x,   'x,   'x    );
    check(  0, 'x,       0,    0,    0,    0    );

    t.test_case_end();
  endtask

  //<'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_directed_val_type();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_directed_any_addr();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_random();
    if ((t.n <= 0) || (t.n == 5)) test_case_5_xprop();

    t.test_bench_end();
  end

endmodule
