//========================================================================
// MemoryBus_RTL
//========================================================================

`ifndef MEMORY_BUS_RTL_V
`define MEMORY_BUS_RTL_V

`include "lab4/MemoryBusCtrl_RTL.v"
`include "lab4/MemoryBusDpath_RTL.v"

module MemoryBus_RTL
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Processor Interface

  (* keep=1 *) input  logic        imem_val,
  (* keep=1 *) output logic        imem_wait,
  (* keep=1 *) input  logic [31:0] imem_addr,
  (* keep=1 *) output logic [31:0] imem_rdata,

  (* keep=1 *) input  logic        dmem_val,
  (* keep=1 *) output logic        dmem_wait,
  (* keep=1 *) input  logic        dmem_type,
  (* keep=1 *) input  logic [31:0] dmem_addr,
  (* keep=1 *) input  logic [31:0] dmem_wdata,
  (* keep=1 *) output logic [31:0] dmem_rdata,

  // SPI Interface

  (* keep=1 *) input  logic        hmem_val,
  (* keep=1 *) input  logic [31:0] hmem_addr,
  (* keep=1 *) input  logic [31:0] hmem_wdata,

  // Memory Interface

  (* keep=1 *) output logic        mem0_val,
  (* keep=1 *) input  logic        mem0_wait,
  (* keep=1 *) output logic        mem0_type,
  (* keep=1 *) output logic [31:0] mem0_addr,
  (* keep=1 *) output logic [31:0] mem0_wdata,
  (* keep=1 *) input  logic [31:0] mem0_rdata,

  (* keep=1 *) output logic        mem1_val,
  (* keep=1 *) input  logic        mem1_wait,
  (* keep=1 *) output logic        mem1_type,
  (* keep=1 *) output logic [31:0] mem1_addr,
  (* keep=1 *) output logic [31:0] mem1_wdata,
  (* keep=1 *) input  logic [31:0] mem1_rdata,

  // External I/O Interface

  (* keep=1 *) input  logic [31:0] in0,
  (* keep=1 *) input  logic [31:0] in1,
  (* keep=1 *) input  logic [31:0] in2,
  (* keep=1 *) input  logic [31:0] in3,

  (* keep=1 *) output logic [31:0] out0,
  (* keep=1 *) output logic [31:0] out1,
  (* keep=1 *) output logic [31:0] out2,
  (* keep=1 *) output logic [31:0] out3
);

  // Control signals (ctrl -> dpath)

  logic mem0_addr_sel;
  logic dmem_wen;

  // Control Unit

  MemoryBusCtrl_RTL ctrl
  (
    .*
  );
   
  // Datapath

  MemoryBusDpath_RTL dpath
  (
    .*
  );


endmodule

`endif /* MEMORY_BUS_V */
