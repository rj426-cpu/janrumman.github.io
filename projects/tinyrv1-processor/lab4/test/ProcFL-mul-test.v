//========================================================================
// ProcFL-mul-test
//========================================================================

`include "ece2300/ece2300-test.v"
`include "ece2300/ece2300-misc.v"

// ece2300-lint off
`include "lab4/test/ProcFL.v"

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

  logic [31:0] in0, in1, in2, in3;
  logic [31:0] out0, out1, out2, out3;

  logic        trace_val;
  logic [31:0] trace_addr;
  logic [31:0] trace_inst;
  logic        trace_wen;
  logic [4:0]  trace_wreg;
  logic [31:0] trace_wdata;

  ProcFL proc
  (
    .*
  );

  assign in0 = 'x;
  assign in1 = 'x;
  assign in2 = 'x;
  assign in3 = 'x;

  `ECE2300_UNUSED( out0 );
  `ECE2300_UNUSED( out1 );
  `ECE2300_UNUSED( out2 );
  `ECE2300_UNUSED( out3 );

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
        #10;
      end

      if ( t.n != 0 ) begin
        if ( trace_wen )
          $display( "%3d: %h %-s x%0d %h", t.cycles,
                    trace_addr, tinyrv1.disasm(trace_addr, trace_inst),
                    trace_wdata, trace_wreg);
        else
          $display( "%3d: %h %-s", t.cycles,
                    trace_addr, tinyrv1.disasm(trace_addr, trace_inst));
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
    proc.M[addr[8:2]] = tinyrv1.asm( addr, str );
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
    proc.M[addr[8:2]] = data_;
    data_addr_unused = addr;
  endtask

  //----------------------------------------------------------------------
  // test cases
  //----------------------------------------------------------------------

  `include "lab4/test/Proc-mul-test-cases.v"

endmodule
