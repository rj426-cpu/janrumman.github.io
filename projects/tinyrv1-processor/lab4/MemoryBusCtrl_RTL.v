//========================================================================
// MemoryBusCtrl_RTL
//========================================================================

`ifndef MEMORY_BUS_CTRL_RTL_V
`define MEMORY_BUS_CTRL_RTL_V

`include "ece2300/ece2300-misc.v"

module MemoryBusCtrl_RTL
(
  // Processor Interface

  (* keep=1 *) input  logic imem_val,
  (* keep=1 *) output logic imem_wait,

  (* keep=1 *) input  logic dmem_val,
  (* keep=1 *) output logic dmem_wait,
  (* keep=1 *) input  logic dmem_type,

  // SPI Interface

  (* keep=1 *) input  logic hmem_val,

  // Memory Interface

  (* keep=1 *) output logic mem0_val,
  (* keep=1 *) input  logic mem0_wait,
  (* keep=1 *) output logic mem0_type,

  (* keep=1 *) output logic mem1_val,
  (* keep=1 *) input  logic mem1_wait,
  (* keep=1 *) output logic mem1_type,

  // Control Signals (ctrl -> dpath)

  (* keep=1 *) output logic mem0_addr_sel,
  (* keep=1 *) output logic dmem_wen
);

  assign mem0_addr_sel = ( hmem_val) ? 1'b1 : 1'b0;
  assign dmem_wen      = ( dmem_val) ? 1'b1 : 1'b0;
  assign mem0_val      = ( imem_val || hmem_val) ? 1'b1 : 1'b0;
  assign mem1_val      = ( dmem_val ) ? 1'b1 : 1'b0;
  assign mem0_type     = ( hmem_val ) ? 1'b1 : 1'b0;
  assign mem1_type     = ( dmem_type ) ? 1'b1 : 1'b0;
  assign imem_wait     = ( mem0_wait || (hmem_val && imem_val)) ? 1'b1 : 1'b0;
  assign dmem_wait     = ( mem1_wait ) ? 1'b1 : 1'b0;

endmodule

`endif /* MEMORY_BUS_CTRL_RTL_V */
