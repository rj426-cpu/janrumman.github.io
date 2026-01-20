//========================================================================
// ProcScycleDpath
//========================================================================

`ifndef PROC_SCYCLE_DPATH_V
`define PROC_SCYCLE_DPATH_V

`include "lab4/tinyrv1.v"
`include "lab4/Register_32b_RTL.v"
`include "lab4/Adder_32b_GL.v"
`include "lab4/RegfileZ2r1w_32x32b_RTL.v"
`include "lab4/ALU_32b.v"
`include "lab4/ImmGen_RTL.v"
`include "lab4/Multiplier_32x32b_RTL.v"
`include "lab4/Mux2_32b_RTL.v"
`include "lab4/Mux4_32b_RTL.v"

module ProcScycleDpath
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Memory Interface

  (* keep=1 *) output logic [31:0] imem_addr,
  (* keep=1 *) input  logic [31:0] imem_rdata,

  (* keep=1 *) output logic [31:0] dmem_addr,
  (* keep=1 *) output logic [31:0] dmem_wdata,
  (* keep=1 *) input  logic [31:0] dmem_rdata,

  // Trace Interface

  (* keep=1 *) output logic [31:0] trace_addr,
  (* keep=1 *) output logic [4:0]  trace_wreg,
  (* keep=1 *) output logic [31:0] trace_wdata,

  // Control Signals (Control Unit -> Datapath)

  (* keep=1 *) input  logic         op2_sel,
  (* keep=1 *) input  logic [1:0]    wb_sel,
  (* keep=1 *) input  logic [1:0]  imm_type,
  (* keep=1 *) input  logic          rf_wen,
  (* keep=1 *) input  logic [1:0]    pc_sel,
  (* keep=1 *) input  logic        alu_func,  
  (* keep=1 *) input  logic           pc_en, 

  // Status Signals (Datapath -> Control Unit)

  (* keep=1 *) output logic [31:0] inst,
  (* keep=1 *) output logic       alu_eq
);

  // PC Register
  logic [31:0] pc, pc_next;

  // PC Mux
  logic [31:0] pc_plus4;

  // JAL related instantiation
  logic [31:0] jalbr_targ;

  // JR
  logic [31:0] jr_targ;
  
  Register_32b_RTL pc_reg
  (
    .clk (clk),
    .rst (rst),
    .en  (pc_en),
    .d   (pc_next),
    .q   (pc)
  );

  assign imem_addr = pc;

  // PC+4 Adder
  Adder_32b_GL pc_adder
  (
    .in0 (pc),
    .in1 (32'd4),
    .sum (pc_plus4)
  );

  // Extract instruction fields
  assign inst = imem_rdata;

  logic [`TINYRV1_INST_RS1_NBITS-1:0] rs1;
  logic [`TINYRV1_INST_RS1_NBITS-1:0] rs2;
  logic [`TINYRV1_INST_RD_NBITS-1: 0]  rd;

  assign rs1 = inst[`TINYRV1_INST_RS1];
  assign rs2 = inst[`TINYRV1_INST_RS2];
  assign rd  = inst[`TINYRV1_INST_RD ];

  // Register File
  logic [31:0]  rf_wdata;
  logic [31:0] rf_rdata0;
  logic [31:0] rf_rdata1;

  RegfileZ2r1w_32x32b_RTL rf
  (
    .clk    (clk),

    .wen    (rf_wen),
    .waddr  (rd),
    .wdata  (rf_wdata),

    .raddr0 (rs1),
    .rdata0 (rf_rdata0),

    .raddr1 (rs2),
    .rdata1 (rf_rdata1)
  );

  // Immediate Generation

  logic [31:0] immgen_imm;

  ImmGen_RTL immgen
  (
    .inst     (inst),
    .imm_type (imm_type),
    .imm      (immgen_imm)
   );

  // Op2 Mux

  logic [31:0] op2_data;

  Mux2_32b_RTL op2_mux
  (
    .in0 (rf_rdata1),
    .in1 (immgen_imm),
    .sel (op2_sel),
    .out (op2_data)
  );

  // ALU
  logic [31:0] alu_out;

  ALU_32b alu
  (
    .in0 (rf_rdata0),
    .in1 (op2_data),
    .op  (alu_func),
    .out (alu_out)
  );
  
  // Alu_Eq becomes a sel signal for pc_sel mux
  assign alu_eq = (alu_out == 32'b1 ) ? 1'b1 : 1'b0;

  // MUL
  logic [31:0] mul_out;

  Multiplier_32x32b_RTL mul 
  (
    .in0  (rf_rdata0),
    .in1  (rf_rdata1),
    .prod (mul_out)
  );

  // WB Mux 
  Mux4_32b_RTL wb_mux 
  (
    .in0  (pc_plus4),
    .in1  (mul_out),
    .in2  (alu_out),
    .in3  (dmem_rdata),
    .sel  (wb_sel),
    .out  (rf_wdata)
  );

  Mux4_32b_RTL pc_mux
  (
    .in0 (pc_plus4),
    .in1 (jalbr_targ),
    .in2 (jr_targ),
    .in3 (32'b0),
    .sel (pc_sel),
    .out (pc_next)
  );

  Adder_32b_GL adder 
  (
    .in0 (immgen_imm),
    .in1 (pc),
    .sum (jalbr_targ)
  );

  assign jr_targ = rf_rdata0;

  // Data Memory 

  assign dmem_addr  = alu_out;
  assign dmem_wdata = rf_rdata1;

  // Trace Output

  assign trace_addr  = pc;
  assign trace_wreg  = rd;
  assign trace_wdata = rf_wdata;

endmodule

`endif /* PROC_SCYCLE_DPATH_V */
