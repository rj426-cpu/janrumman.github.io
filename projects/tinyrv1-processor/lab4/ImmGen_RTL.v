//========================================================================
// ImmGen_RTL
//========================================================================
// Generate immediate from a TinyRV1 instruction.
//
//  imm_type == 0 : I-type (ADDI)
//  imm_type == 1 : S-type (SW)
//  imm_type == 2 : J-type (JAL)
//  imm_type == 3 : B-type (BNE)
//

`ifndef IMM_GEN_RTL_V
`define IMM_GEN_RTL_V

`include "ece2300/ece2300-misc.v"

module ImmGen_RTL
(
  (* keep=1 *) input  logic [31:0] inst,
  (* keep=1 *) input  logic  [1:0] imm_type,
  (* keep=1 *) output logic [31:0] imm
);
  always_comb begin
  case (imm_type)
    2'b00 :  begin
      imm[0] = inst[20]; 
      imm[4:1] = inst[24:21];
      imm[10:5] = inst[30:25];
      imm[31:11] = (inst[31] == 1) ? {21{1'b1}} : 21'b0;
      end
    2'b01 : begin
      imm[0] = inst[7];
      imm[4:1] = inst[11:8];
      imm[10:5] = inst[30:25]; 
      imm[31:11] = (inst[31] == 1) ? {21{1'b1}} : 21'b0;
    end
    2'b10 : begin
      imm[0] = 1'b0; 
      imm[4:1] = inst[24:21]; 
      imm[10:5] = inst[30:25]; 
      imm[11] = inst[20];
      imm[19:12] = inst[19:12];
      imm[31:20] = (inst[31] == 1) ? {12{1'b1}}  : 12'b0;
    end
    2'b11 : begin
      imm[0] = 1'b0;
      imm[4:1] = inst[11:8];
      imm[10:5] = inst[30:25];
      imm[11] = inst[7];
      imm[31:12] = (inst[31] == 1) ? {20{1'b1}}  : 20'b0;
      end
    default: imm = 32'bx;
  endcase
  end 
  `ECE2300_UNUSED(inst[6:0]);
endmodule

`endif /* IMM_GEN_RTL_V */

