//========================================================================
// ProcScycle
//========================================================================

`ifndef PROC_SCYCLE_V
`define PROC_SCYCLE_V

`include "lab4/ProcScycleDpath.v"
`include "lab4/ProcScycleCtrl.v"

module ProcScycle
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Memory Interface

  (* keep=1 *) output logic        imem_val,
  (* keep=1 *) input  logic        imem_wait,
  (* keep=1 *) output logic [31:0] imem_addr,
  (* keep=1 *) input  logic [31:0] imem_rdata,

  (* keep=1 *) output logic        dmem_val,
  (* keep=1 *) input  logic        dmem_wait,
  (* keep=1 *) output logic        dmem_type,
  (* keep=1 *) output logic [31:0] dmem_addr,
  (* keep=1 *) output logic [31:0] dmem_wdata,
  (* keep=1 *) input  logic [31:0] dmem_rdata,

  // Trace Interface

  (* keep=1 *) output logic        trace_val,
  (* keep=1 *) output logic [31:0] trace_addr,
  (* keep=1 *) output logic        trace_wen,
  (* keep=1 *) output logic [4:0]  trace_wreg,
  (* keep=1 *) output logic [31:0] trace_wdata
);

  // Control Signals (Control Unit -> Datapath)

  logic        op2_sel;
  logic [1:0]   wb_sel;
  logic [1:0] imm_type;
  logic [1:0]   pc_sel;
  logic          pc_en;
  logic       alu_func;
  logic         rf_wen;

  // Status Signals (Datapath -> Control Unit)

  logic [31:0]   inst;
  logic        alu_eq;

  // Insantiate/Connect Datapath and Control Unit

  ProcScycleDpath dpath
  (
    .*
  );

  ProcScycleCtrl ctrl
  (
    .*
  );

endmodule

`endif /* PROC_SCYCLE_V */

