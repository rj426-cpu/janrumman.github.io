//========================================================================
// ProcScycleCtrl
//========================================================================

`ifndef PROC_SCYCLE_CTRL_V
`define PROC_SCYCLE_CTRL_V

`include "lab4/tinyrv1.v"

module ProcScycleCtrl
(
  (* keep=1 *) input  logic        rst,

  // Memory Interface

  (* keep=1 *) output logic        imem_val,
  (* keep=1 *) input  logic        imem_wait,

  (* keep=1 *) output logic        dmem_val,
  (* keep=1 *) input  logic        dmem_wait,
  (* keep=1 *) output logic        dmem_type,

  // Trace Interface

  (* keep=1 *) output logic        trace_val,
  (* keep=1 *) output logic        trace_wen,

  // Control Signals (Control Unit -> Datapath)
  (* keep=1 *) output logic [1:0]   pc_sel,
  (* keep=1 *) output logic [1:0] imm_type,
  (* keep=1 *) output logic        op2_sel,
  (* keep=1 *) output logic       alu_func,
  (* keep=1 *) output logic [1:0]   wb_sel,
  (* keep=1 *) output logic         rf_wen,
  (* keep=1 *) output logic          pc_en,
  
  // Status Signals (Datapath -> Control Unit)

  (* keep=1 *) input  logic [31:0]  inst,
  (* keep=1 *) input  logic        alu_eq
  
);

  // Localparams for pc_sel control signal

  localparam pc_plus4   = 2'd0;
  localparam jalbr_targ = 2'd1;
  localparam jr_targ    = 2'd2;

  // Localparams for imm_type control signal

  localparam I = 2'd0;
  localparam S = 2'd1;
  localparam J = 2'd2;
  localparam B = 2'd3;

  // Localparams for op2_sel control signal

  localparam rf  = 1'd0;
  localparam imm = 1'd1;

  // Localparams for alu_func control signal

  localparam add = 1'd0;
  localparam eq  = 1'd1;

  // Localparams for web_sel control signal

  localparam mul  = 2'd1;
  localparam alu  = 2'd2;
  localparam dmem = 2'd3;

  // Localparams for dmem_type control signal

  localparam rd = 1'd0;
  localparam wr = 1'd1;

  // Internal signal for pc_sel

  logic [1:0] pc_sel_branch;
  logic          rf_wen_pre;
  logic        dmem_val_pre;
  // Task for setting control signals

  task automatic cs
  (
    input logic [1:0]       pc_sel_,
    input logic [1:0]     imm_type_,
    input logic            op2_sel_,
    input logic           alu_func_,
    input logic [1:0]       wb_sel_,
    input logic         rf_wen_pre_,
    input logic       dmem_val_pre_,
    input logic          dmem_type_
    
  ); 
    pc_sel_branch =        pc_sel_;
    imm_type      =      imm_type_;
    op2_sel       =       op2_sel_;
    alu_func      =      alu_func_;
    wb_sel        =        wb_sel_;
    rf_wen_pre    =    rf_wen_pre_;
    dmem_val_pre  =  dmem_val_pre_;
    dmem_type     =     dmem_type_;

  endtask

  // Control signal table

  always_comb begin
    casez ( inst )
                                // pc    // imm   // op2   // alu     // wb   // rf  // dmem  // dmem
                                // sel   // type  // sel   // func    // sel  // wen // val   // type
      `TINYRV1_INST_ADDI: cs(   pc_plus4,    I,    imm,      add,        alu,     1,      0,      'x );
      `TINYRV1_INST_ADD:  cs(   pc_plus4,   'x,     rf,      add,        alu,     1,      0,      'x );
      `TINYRV1_INST_MUL:  cs(   pc_plus4,   'x,     'x,       'x,        mul,     1,      0,      'x );
      `TINYRV1_INST_LW:   cs(   pc_plus4,    I,    imm,      add,       dmem,     1,      1,      rd );
      `TINYRV1_INST_SW:   cs(   pc_plus4,    S,    imm,      add,         'x,     0,      1,      wr );
      `TINYRV1_INST_JAL:  cs( jalbr_targ,    J,     'x,       'x,   pc_plus4,     1,      0,      'x );
      `TINYRV1_INST_JR:   cs(    jr_targ,   'x,     'x,       'x,         'x,     0,      0,      'x );
      `TINYRV1_INST_BNE:  cs(   pc_plus4,    B,     rf,       eq,         'x,     0,      0,      'x );
      default:            cs(         'x,   'x,     'x,       'x,         'x,    'x,     'x,      'x );
    endcase
  end

  // Additional combinational logic


  assign rf_wen = !rst && !imem_wait && !dmem_wait && rf_wen_pre;
  assign imem_val = !rst && !imem_wait;
  assign dmem_val = !rst && !imem_wait && dmem_val_pre;
  assign pc_en = !rst && !imem_wait && !dmem_wait;
  assign trace_val = !rst && !imem_wait && !dmem_wait;
  assign trace_wen = rf_wen;
  assign pc_sel = ((inst[6:0] == 7'b1100011) 
                  && (inst[14:12] == 3'b001) 
                  && !alu_eq) ? jalbr_targ : pc_sel_branch;

endmodule

`endif /* PROC_SCYCLE_CTRL_V */
