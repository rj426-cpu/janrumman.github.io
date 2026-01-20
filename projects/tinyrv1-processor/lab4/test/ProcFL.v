//========================================================================
// ProcFL
//========================================================================
// TinyRV1 functional-level model.

`ifndef PROC_FL_V
`define PROC_FL_V

`include "lab4/tinyrv1.v"

module ProcFL
(
  input  logic        clk,
  input  logic        rst,

  // Memory Bus External I/O

  input  logic [31:0] in0,
  input  logic [31:0] in1,
  input  logic [31:0] in2,
  input  logic [31:0] in3,

  output logic [31:0] out0,
  output logic [31:0] out1,
  output logic [31:0] out2,
  output logic [31:0] out3,

  // Trace interface

  output logic        trace_val,
  output logic [31:0] trace_addr,
  output logic [31:0] trace_inst,
  output logic        trace_wen,
  output logic [4:0]  trace_wreg,
  output logic [31:0] trace_wdata
);

  //----------------------------------------------------------------------
  // Architectural State
  //----------------------------------------------------------------------

  logic [31:0] M [2**7];
  logic [31:0] R [32];
  logic [31:0] pc;

  //----------------------------------------------------------------------
  // Other Signals
  //----------------------------------------------------------------------

  logic [31:0] pc_next;
  logic [31:0] ir;

  logic [`TINYRV1_INST_RS1_NBITS-1:0]   rs1;
  logic [`TINYRV1_INST_RS2_NBITS-1:0]   rs2;
  logic [`TINYRV1_INST_RD_NBITS-1:0]    rd;

  //----------------------------------------------------------------------
  // Immediates
  //----------------------------------------------------------------------

  logic [31:0] inst_unused;

  function [31:0] imm_i
  (
    input [`TINYRV1_INST_NBITS-1:0] inst
  );
    inst_unused = inst;
    return { {21{inst[31]}}, inst[30:25], inst[24:21], inst[20] };
  endfunction

  function [31:0] imm_s
  (
    input [`TINYRV1_INST_NBITS-1:0] inst
  );
    inst_unused = inst;
    return { {21{inst[31]}}, inst[30:25], inst[11:8], inst[7] };
  endfunction

  function [31:0] imm_b
  (
    input [`TINYRV1_INST_NBITS-1:0] inst
  );
    inst_unused = inst;
    return { {20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0 };
  endfunction

  function [31:0] imm_j
  (
    input [`TINYRV1_INST_NBITS-1:0] inst
  );
    inst_unused = inst;
    return { {12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0 };
  endfunction

  //----------------------------------------------------------------------
  // Main Always Block
  //----------------------------------------------------------------------

  // verilator lint_off SIDEEFFECT
  // verilator lint_off BLKSEQ
  always @( posedge clk ) begin

    if ( rst ) begin
      pc         <= 32'h0000_0000;
      out0       <= '0;
      out1       <= '0;
      out2       <= '0;
      out3       <= '0;
      trace_val  <= 1'b0;
      trace_addr <= 'x;
      trace_inst <= 'x;
      trace_wen  <= 1'b0;
      trace_wreg <= 5'bx;
      trace_wdata <= 'x;
    end
    else begin

      // Fetch instruction

      ir = M[pc[8:2]];

      // Unpack instruction

      rd  = ir[`TINYRV1_INST_RD];
      rs1 = ir[`TINYRV1_INST_RS1];
      rs2 = ir[`TINYRV1_INST_RS2];

      // Make sure any reads to R0 gets a zero

      R[ 5'd0 ] = 32'b0;

      // Default is to increment PC by 4

      pc_next = pc + 4;

      // Semantics for each instruction

      trace_wen  <= 1'b0;
      trace_wreg <= 5'bx;
      trace_wdata <= 'x;

      casez ( ir )

        `TINYRV1_INST_ADD:
          begin
            R[rd] = R[rs1] + R[rs2];
            trace_wen  <= 1'b1;
            trace_wreg <= rd;
            trace_wdata <= R[rd];
          end

        `TINYRV1_INST_ADDI:
          begin
            R[rd] = R[rs1] + imm_i(ir);
            trace_wen  <= 1'b1;
            trace_wreg <= rd;
            trace_wdata <= R[rd];
          end

        `TINYRV1_INST_MUL:
          begin
            R[rd] = R[rs1] * R[rs2];
            trace_wen  <= 1'b1;
            trace_wreg <= rd;
            trace_wdata <= R[rd];
          end

        `TINYRV1_INST_LW:
          begin
            integer addr;
            addr = (R[rs1] + imm_i(ir));

            if ( addr < 32'h200 ) begin
              R[rd] = M[ addr[8:2] ];
            end
            else begin
              case ( addr )
                32'h200 : R[rd] = in0;
                32'h204 : R[rd] = in1;
                32'h208 : R[rd] = in2;
                32'h20c : R[rd] = in3;
                default: ;
              endcase
            end

            trace_wen  <= 1;
            trace_wreg <= rd;
            trace_wdata <= R[rd];
          end

        `TINYRV1_INST_SW:
          begin
            integer addr;
            addr = R[rs1] + imm_s(ir);

            if ( addr < 32'h200 ) begin
              M[ addr[8:2] ] =  R[rs2];
            end
            else begin
              case ( addr )
                32'h210 : out0 <= R[rs2];
                32'h214 : out1 <= R[rs2];
                32'h218 : out2 <= R[rs2];
                32'h21c : out3 <= R[rs2];
                default: ;
              endcase
            end
          end

        `TINYRV1_INST_JAL:
          begin
            R[rd] = pc + 4;
            pc_next = pc + imm_j(ir);
            trace_wen  <= 1'b1;
            trace_wreg <= rd;
            trace_wdata <= R[rd];
          end

        `TINYRV1_INST_JR:
          begin
            pc_next = R[rs1];
          end

        `TINYRV1_INST_BNE:
          begin
            if ( R[rs1] != R[rs2] )
              pc_next = pc + imm_b(ir);
          end

      endcase

      // Update trace output

      trace_val  <= 1'b1;
      trace_addr <= pc;
      trace_inst <= ir;

      // Update pc

      pc <= pc_next;

    end

  end
  // verilator lint_on BLKSEQ
  // verilator lint_on SIDEEFFECT

endmodule

`endif /* PROC_FL_V */
