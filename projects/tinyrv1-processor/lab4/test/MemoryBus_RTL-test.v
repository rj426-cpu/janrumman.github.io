//========================================================================
// MemoryBus-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/MemoryBus_RTL.v"

// ece2300-lint off
`include "lab4/test/TestMemory.v"

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

  logic        imem_val;
  logic        imem_wait;
  logic [31:0] imem_addr;
  logic [31:0] imem_rdata;

  logic        dmem_val;
  logic        dmem_wait;
  logic        dmem_type;
  logic [31:0] dmem_addr;
  logic [31:0] dmem_wdata;
  logic [31:0] dmem_rdata;

  logic        hmem_val;
  logic [31:0] hmem_addr;
  logic [31:0] hmem_wdata;

  logic        mem0_val;
  logic        mem0_wait;
  logic        mem0_type;
  logic [31:0] mem0_addr;
  logic [31:0] mem0_wdata;
  logic [31:0] mem0_rdata;

  logic        mem1_val;
  logic        mem1_wait;
  logic        mem1_type;
  logic [31:0] mem1_addr;
  logic [31:0] mem1_wdata;
  logic [31:0] mem1_rdata;

  logic [31:0] in0, in1, in2, in3;
  logic [31:0] out0, out1, out2, out3;

  MemoryBus_RTL dut
  (
    .*
   );

  TestMemory mem
  (
    .*
  );

  //----------------------------------------------------------------------
  // imem
  //----------------------------------------------------------------------

  logic        save_imem_val;
  logic        save_imem_wait;
  logic [31:0] save_imem_addr;
  logic [31:0] save_imem_rdata;

  task imem
  (
    input logic        imem_val_,
    input logic        imem_wait_,
    input logic [31:0] imem_addr_,
    input logic [31:0] imem_rdata_
  );

    if ( !t.failed ) begin

      imem_val  = imem_val_;
      imem_addr = imem_addr_;

      save_imem_val   = imem_val_;
      save_imem_wait  = imem_wait_;
      save_imem_addr  = imem_addr_;
      save_imem_rdata = imem_rdata_;

    end

  endtask

  //----------------------------------------------------------------------
  // dmem
  //----------------------------------------------------------------------

  logic        save_dmem_val;
  logic        save_dmem_wait;
  logic        save_dmem_type;
  logic [31:0] save_dmem_addr;
  logic [31:0] save_dmem_wdata;
  logic [31:0] save_dmem_rdata;

  task dmem
  (
    input logic        dmem_val_,
    input logic        dmem_wait_,
    input logic        dmem_type_,
    input logic [31:0] dmem_addr_,
    input logic [31:0] dmem_wdata_,
    input logic [31:0] dmem_rdata_
  );

    if ( !t.failed ) begin

      dmem_val   = dmem_val_;
      dmem_type  = dmem_type_;
      dmem_addr  = dmem_addr_;
      dmem_wdata = dmem_wdata_;

      save_dmem_val   = dmem_val_;
      save_dmem_wait  = dmem_wait_;
      save_dmem_type  = dmem_type_;
      save_dmem_addr  = dmem_addr_;
      save_dmem_wdata = dmem_wdata_;
      save_dmem_rdata = dmem_rdata_;

    end

  endtask

  //----------------------------------------------------------------------
  // hmem
  //----------------------------------------------------------------------

  logic        save_hmem_val;
  logic [31:0] save_hmem_addr;
  logic [31:0] save_hmem_wdata;

  task hmem
  (
    input logic        hmem_val_,
    input logic [31:0] hmem_addr_,
    input logic [31:0] hmem_wdata_
  );

    if ( !t.failed ) begin

      hmem_val   = hmem_val_;
      hmem_addr  = hmem_addr_;
      hmem_wdata = hmem_wdata_;

      save_hmem_val   = hmem_val_;
      save_hmem_addr  = hmem_addr_;
      save_hmem_wdata = hmem_wdata_;

    end

  endtask

  //----------------------------------------------------------------------
  // io
  //----------------------------------------------------------------------

  logic [31:0] save_out0;
  logic [31:0] save_out1;
  logic [31:0] save_out2;
  logic [31:0] save_out3;

  task io
  (
    input logic [31:0] in0_,
    input logic [31:0] in1_,
    input logic [31:0] in2_,
    input logic [31:0] in3_,

    input logic [31:0] out0_,
    input logic [31:0] out1_,
    input logic [31:0] out2_,
    input logic [31:0] out3_
  );

    if ( !t.failed ) begin

      in0 = in0_;
      in1 = in1_;
      in2 = in2_;
      in3 = in3_;

      save_out0 = out0_;
      save_out1 = out1_;
      save_out2 = out2_;
      save_out3 = out3_;

    end

  endtask

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------

  task check();

    if ( !t.failed ) begin
      t.num_checks += 1;

      #8;

      if ( t.n != 0 ) begin
        $write( "%3d: ", t.cycles );

        if ( save_hmem_val )
          $write( "wr:%x:%x", save_hmem_addr, save_hmem_wdata );
        else if ( save_imem_val )
          $write( "rd:%x:        ", save_imem_addr );
        else
          $write( "                    " );

        $write( "|" );

        if ( save_dmem_val ) begin
          if ( save_dmem_type == 0 )
            $write( "rd:%x:        ", save_dmem_addr );
          else
            $write( "wr:%x:%x", save_dmem_addr, save_dmem_wdata );
        end
        else
          $write( "                    " );

        $write( " > " );

        if ( save_imem_val )
          $write( "%x", save_imem_rdata );
        else
          $write( "        " );

        $write( "|" );

        if ( save_dmem_val && (save_dmem_type == 0) )
          $write( "%x", save_dmem_rdata );
        else
          $write( "        " );

        $write(" [%d %d %d %d]", save_out0, save_out1, save_out2, save_out3);

        $write( "\n" );
      end

      `ECE2300_CHECK_EQ_HEX( imem_wait,  save_imem_wait  );

      if ( save_imem_val && !save_imem_wait )
        `ECE2300_CHECK_EQ_HEX( imem_rdata, save_imem_rdata );

      `ECE2300_CHECK_EQ_HEX( dmem_wait,  save_dmem_wait  );
      if ( save_dmem_val && !save_dmem_wait && (save_dmem_type == 0) )
        `ECE2300_CHECK_EQ_HEX( dmem_rdata, save_dmem_rdata );

      `ECE2300_CHECK_EQ_HEX( out0, save_out0 );
      `ECE2300_CHECK_EQ_HEX( out1, save_out1 );
      `ECE2300_CHECK_EQ_HEX( out2, save_out2 );
      `ECE2300_CHECK_EQ_HEX( out3, save_out3 );

      #2;

    end

  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   1,   32'h0000_0000, 32'h0000_0011, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   0,   32'h0000_0000, 32'h0000_0000, 32'h0000_0011 );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    t.test_case_end();
  endtask

  // ----------------------------------------------------------------------
  // test_case_2_proc_imem
  // ----------------------------------------------------------------------

  task test_case_2_proc_imem();
    t.test_case_begin( "test_case_2_proc_imem" );

    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   1,   32'h0000_0000, 32'h0000_0006, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 1,  0,        32'h0000_0000,                32'h0000_0006 );
    dmem ( 1,  0,   1,   32'h0000_0004, 32'h0000_0009, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 1,  0,        32'h0000_0004,                32'h0000_0009 );
    dmem ( 1,  0,   1,   32'h0000_01fc, 32'h0000_0002, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 1,  0,        32'h0000_01fc,                32'h0000_0002 );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_proc_dmem
  //----------------------------------------------------------------------

  task test_case_3_proc_dmem();
    t.test_case_begin( "test_case_3_proc_dmem" );

    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   1,   32'h0000_0000, 32'h0000_0002, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   0,   32'h0000_0000, 32'h0000_0000, 32'h0000_0002 );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   1,   32'h0000_0004, 32'h0000_0012, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   0,   32'h0000_0004, 32'h0000_0000, 32'h0000_0012 );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   1,   32'h0000_01fc, 32'h0000_0007, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   0,   32'h0000_01fc, 32'h0000_0000, 32'h0000_0007 );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_4_proc_io
  //----------------------------------------------------------------------

  task test_case_4_proc_io();
    t.test_case_begin( "test_case_4_proc_io" );

    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   0,   32'h0000_0200, 32'h0000_0000, 32'h0000_0001 );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 1,  2,  5,  9,  0,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   0,   32'h0000_0204, 32'h0000_0000, 32'h0000_0002 );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 1,  2,  5,  9,  0,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   0,   32'h0000_0208, 32'h0000_0000, 32'h0000_0005 );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 1,  2,  5,  9,  0,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   0,   32'h0000_020c, 32'h0000_0000, 32'h0000_0009 );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 1,  2,  5,  9,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   1,   32'h0000_0210, 32'h0000_0003, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 1,  2,  5,  9,  0,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   1,   32'h0000_0214, 32'h0000_0006, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 1,  2,  5,  9,  3,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   1,   32'h0000_0218, 32'h0000_0007, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 1,  2,  5,  9,  3,   6,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   1,   32'h0000_021c, 32'h0000_000a, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 1,  2,  5,  9,  3,   6,   7,   0   );
    check();

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_5_hmem
  //----------------------------------------------------------------------

  task test_case_5_hmem();
    t.test_case_begin( "test_case_5_hmem" );

    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 1,            32'h0000_0000, 32'h0020_0093                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 1,            32'h0000_0004, 32'h0020_8113                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 1,  1,        32'h0000_0000,                'x            );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 1,            32'h0000_0008, 32'h4100_0193                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 1,            32'h0000_000c, 32'h0021_a023                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 1,            32'h0000_0010, 32'h0000_006f                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 1,  0,        32'h0000_0000,                32'h0020_0093 );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 1,  0,        32'h0000_0004,                32'h0020_8113 );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 1,  0,        32'h0000_0008,                32'h4100_0193 );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 1,  0,        32'h0000_000c,                32'h0021_a023 );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    //     val wait type addr           wdata          rdata
    imem ( 1,  0,        32'h0000_0010,                32'h0000_006f );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_6_simultaneous
  //----------------------------------------------------------------------

  task test_case_6_simultaneous();
    t.test_case_begin( "test_case_6_simultaneous" );

    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 0,  0,        32'h0000_0000,                'x            );
    dmem ( 1,  0,   1,   32'h0000_0000, 32'h0000_0003, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 1,  0,        32'h0000_0000,                32'h0000_0003 );
    dmem ( 1,  0,   1,   32'h0000_0004, 32'h0000_0005, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 1,  0,        32'h0000_0004,                32'h0000_0005 );
    dmem ( 1,  0,   0,   32'h0000_0000, 32'h0000_0000, 32'h0000_0003 );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 1,  0,        32'h0000_0000,                32'h0000_0003 );
    dmem ( 1,  0,   1,   32'h0000_0214, 32'h0000_000b, 'x            );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
    check();
    //     val wait type addr           wdata          rdata
    imem ( 1,  0,        32'h0000_0004,                32'h0000_0005 );
    dmem ( 1,  0,   0,   32'h0000_020c, 32'h0000_0000, 32'h0000_000d );
    hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
    //     in0 in1 in2 in3 out0 out1 out2 out3
    io   ( 0,  0,  0,  13, 0,   11,  0,   0   );
    check();

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_7_random
  //----------------------------------------------------------------------

  localparam MEM_SIZE = 2**7;

  logic [31:0] rand_mem [MEM_SIZE];

  logic        rand_imem_val;
  logic        rand_imem_wait;
  logic [31:0] rand_imem_addr;
  logic [31:0] rand_imem_rdata;

  logic        rand_dmem_val;
  logic        rand_dmem_type;
  logic [31:0] rand_dmem_addr;
  logic [31:0] rand_dmem_wdata;
  logic [31:0] rand_dmem_rdata;

  logic        rand_hmem_val;
  logic [31:0] rand_hmem_addr;
  logic [31:0] rand_hmem_wdata;

  logic [31:0] rand_in0;
  logic [31:0] rand_in1;
  logic [31:0] rand_in2;
  logic [31:0] rand_in3;

  logic [31:0] rand_out0;
  logic [31:0] rand_out1;
  logic [31:0] rand_out2;
  logic [31:0] rand_out3;

  logic [31:0] rand_out_regs [4];

  task test_case_7_random();
    t.test_case_begin( "test_case_7_random" );

    // initialize memories with random data

    for ( int i = 0; i < MEM_SIZE; i = i+1 ) begin
      rand_mem[i] = 32'($urandom(t.seed));
      mem.write( 32'(i << 2), rand_mem[i] );
    end

    // zero initialize external output registers

    for ( int i = 0; i < 4; i = i+1 ) begin
      rand_out_regs[i] = 32'b0;
    end

    // random test loop

    for ( int i = 0; i < 200; i = i+1 ) begin

      // Generate random values for all inputs

      rand_imem_val   = 1'($urandom(t.seed));
      rand_imem_addr  = { 23'b0, 7'($urandom(t.seed)), 2'b0 };

      rand_hmem_val   = 1'($urandom(t.seed));
      rand_hmem_addr  = { 23'b0, 7'($urandom(t.seed)), 2'b0 };
      rand_hmem_wdata = 32'($urandom(t.seed));

      rand_dmem_val   = 1'($urandom(t.seed));
      rand_dmem_addr  = { 23'b0, 7'($urandom(t.seed)), 2'b0 };
      rand_dmem_type  = 1'($urandom(t.seed));
      rand_dmem_wdata = 32'($urandom(t.seed));

      rand_in0        = 32'($urandom(t.seed));
      rand_in1        = 32'($urandom(t.seed));
      rand_in2        = 32'($urandom(t.seed));
      rand_in3        = 32'($urandom(t.seed));

      // Determine correct answer

      rand_imem_wait = rand_imem_val && rand_hmem_val;

      rand_out0 = rand_out_regs[0];
      rand_out1 = rand_out_regs[1];
      rand_out2 = rand_out_regs[2];
      rand_out3 = rand_out_regs[3];

      if ( rand_imem_val && !rand_hmem_val )
        rand_imem_rdata = rand_mem[rand_imem_addr[$clog2(MEM_SIZE)+1:2]];
      else
        rand_imem_rdata = 'x;

      rand_dmem_rdata = 'x;

      if (rand_dmem_val && (rand_dmem_type == 0)) begin
        if ( rand_dmem_addr < 32'h0000_0200 )
          rand_dmem_rdata = rand_mem[rand_dmem_addr[$clog2(MEM_SIZE)+1:2]];
        else if ( rand_dmem_addr == 32'h0000_0200 )
          rand_dmem_rdata = rand_in0;
        else if ( rand_dmem_addr == 32'h0000_0204 )
          rand_dmem_rdata = rand_in1;
        else if ( rand_dmem_addr == 32'h0000_0208 )
          rand_dmem_rdata = rand_in2;
        else if ( rand_dmem_addr == 32'h0000_020c )
          rand_dmem_rdata = rand_in3;
      end

      // Check DUT output matches correct answer

      imem ( rand_imem_val, rand_imem_wait, rand_imem_addr, rand_imem_rdata );
      dmem ( rand_dmem_val, 1'b0, rand_dmem_type, rand_dmem_addr,
                    rand_dmem_wdata, rand_dmem_rdata);
      hmem ( rand_hmem_val, rand_hmem_addr, rand_hmem_wdata );
      io   ( rand_in0, rand_in1, rand_in2, rand_in3, rand_out0, rand_out1, rand_out2, rand_out3 );
      check();

      // Update memory

      if ( rand_hmem_val && rand_dmem_val && (rand_dmem_type == 1) &&
            (rand_hmem_addr == rand_dmem_addr) )
        rand_mem[rand_hmem_addr[$clog2(MEM_SIZE)+1:2]] = rand_hmem_wdata;
      else begin
        if ( rand_hmem_val && (rand_hmem_addr < 32'h0000_0200) )
          rand_mem[rand_hmem_addr[$clog2(MEM_SIZE)+1:2]] = rand_hmem_wdata;

        if ( rand_dmem_val && (rand_dmem_type == 1)
                && (rand_dmem_addr < 32'h0000_0200))
          rand_mem[rand_dmem_addr[$clog2(MEM_SIZE)+1:2]] = rand_dmem_wdata;
      end

      // Update external output registers

      if ( rand_dmem_val && (rand_dmem_type == 1)
              && (rand_dmem_addr[31:4] == 28'h0000_021) )
        rand_out_regs[rand_dmem_addr[3:2]] = rand_dmem_wdata;

    end

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_wait_signal
  //----------------------------------------------------------------------

  // task test_case_wait_signal();
  //   t.test_case_begin( "test_case_wait_signal" );
  //
  //   // Set memory delay
  //
  //   mem.set_random_wait(25);
  //
  //   //     val wait type addr           wdata          rdata
  //   imem ( 0,  0,        32'h0000_0000,                'x            );
  //   dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
  //   hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
  //   //     in0 in1 in2 in3 out0 out1 out2 out3
  //   io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
  //   check();
  //   //     val wait type addr           wdata          rdata
  //   imem ( 1,  1,        32'h0000_0000,                'x            );
  //   dmem ( 1,  1,   1,   32'h0000_0000, 32'h0000_0009, 'x            );
  //   hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
  //   //     in0 in1 in2 in3 out0 out1 out2 out3
  //   io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
  //   check();
  //   //     val wait type addr           wdata          rdata
  //   imem ( 1,  1,        32'h0000_0000,                'x            );
  //   dmem ( 1,  0,   1,   32'h0000_0000, 32'h0000_0009, 'x            );
  //   hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
  //   //     in0 in1 in2 in3 out0 out1 out2 out3
  //   io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
  //   check();
  //   //     val wait type addr           wdata          rdata
  //   imem ( 1,  0,        32'h0000_0000,                32'h0000_0009 );
  //   dmem ( 1,  1,   1,   32'h0000_0004, 32'h0000_0007, 'x            );
  //   hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
  //   //     in0 in1 in2 in3 out0 out1 out2 out3
  //   io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
  //   check();
  //   //     val wait type addr           wdata          rdata
  //   imem ( 0,  0,        32'h0000_0000,                'x            );
  //   dmem ( 1,  0,   1,   32'h0000_0004, 32'h0000_0007, 'x            );
  //   hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
  //   //     in0 in1 in2 in3 out0 out1 out2 out3
  //   io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
  //   check();
  //   //     val wait type addr           wdata          rdata
  //   imem ( 0,  0,        32'h0000_0000,                'x            );
  //   dmem ( 1,  1,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
  //   hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
  //   //     in0 in1 in2 in3 out0 out1 out2 out3
  //   io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
  //   check();
  //   //     val wait type addr           wdata          rdata
  //   imem ( 0,  0,        32'h0000_0000,                'x            );
  //   dmem ( 1,  0,   0,   32'h0000_0000, 32'h0000_0000, 32'h0000_0009 );
  //   hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
  //   //     in0 in1 in2 in3 out0 out1 out2 out3
  //   io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
  //   check();
  //   //     val wait type addr           wdata          rdata
  //   imem ( 0,  0,        32'h0000_0000,                'x            );
  //   dmem ( 0,  0,   0,   32'h0000_0000, 32'h0000_0000, 'x            );
  //   hmem ( 0,            32'h0000_0000, 32'h0000_0000                );
  //   //     in0 in1 in2 in3 out0 out1 out2 out3
  //   io   ( 0,  0,  0,  0,  0,   0,   0,   0   );
  //   check();
  //
  //   t.test_case_end();
  // endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_proc_imem();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_proc_dmem();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_proc_io();
    if ((t.n <= 0) || (t.n == 5)) test_case_5_hmem();
    if ((t.n <= 0) || (t.n == 6)) test_case_6_simultaneous();
    if ((t.n <= 0) || (t.n == 7)) test_case_7_random();

    t.test_bench_end();
  end

endmodule
