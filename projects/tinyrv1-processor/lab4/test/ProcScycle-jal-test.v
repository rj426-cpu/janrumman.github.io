//========================================================================
// ProcScycle-jal-test
//========================================================================

// ece2300-lint off
`include "ece2300/ece2300-test.v"
`include "ece2300/ece2300-misc.v"

`include "lab4/ProcScycle.v"
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

  logic        trace_val;
  logic [31:0] trace_addr;
  logic        trace_wen;
  logic [4:0]  trace_wreg;
  logic [31:0] trace_wdata;

  ProcScycle proc
  (
    .*
  );

  TestMemory mem
  (
    .clk        (clk),
    .rst        (rst),

    .mem0_val   (imem_val),
    .mem0_wait  (imem_wait),
    .mem0_type  (1'b0),
    .mem0_addr  (imem_addr),
    .mem0_wdata ('x),
    .mem0_rdata (imem_rdata),

    .mem1_val   (dmem_val),
    .mem1_wait  (dmem_wait),
    .mem1_type  (dmem_type),
    .mem1_addr  (dmem_addr),
    .mem1_wdata (dmem_wdata),
    .mem1_rdata (dmem_rdata)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------

  TinyRV1 tinyrv1();

  task check_trace
  (
    input logic [31:0] addr,
    input logic        wen,
    input logic [4:0]  wreg,
    input logic [31:0] wdata
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      #8;

      while ( !trace_val ) begin
        if ( t.n != 0 )
          $display( "%3d: %x #", t.cycles, trace_addr );
        #10;
      end

      if ( t.n != 0 ) begin
        if ( trace_wen )
          $display( "%3d: %h %-s x%0d %h", t.cycles,
                    trace_addr, tinyrv1.disasm(imem_addr,imem_rdata),
                    trace_wreg, trace_wdata );
        else
          $display( "%3d: %x %-s ", t.cycles,
                    trace_addr, tinyrv1.disasm(imem_addr,imem_rdata) );
      end

      `ECE2300_CHECK_EQ_HEX( trace_addr, addr );
      `ECE2300_CHECK_EQ_HEX( trace_wen, wen  );
      if ( wen )
        `ECE2300_CHECK_EQ_HEX( trace_wreg, wreg );
      if ( wen && (wreg > 0) )
        `ECE2300_CHECK_EQ_HEX( trace_wdata, wdata );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // asm
  //----------------------------------------------------------------------

  task asm
  (
    input logic [31:0] addr,
    input string str
  );
    mem.asm( addr, str );
  endtask

  //----------------------------------------------------------------------
  // data
  //----------------------------------------------------------------------

  logic [31:0] data_addr_unused;

  task data
  (
    input logic [31:0] addr,
    input logic [31:0] data_
  );
    mem.write( addr, data_ );
    data_addr_unused = addr;
  endtask

  //----------------------------------------------------------------------
  // test cases
  //----------------------------------------------------------------------

  `include "lab4/test/Proc-jal-test-cases.v"

endmodule
