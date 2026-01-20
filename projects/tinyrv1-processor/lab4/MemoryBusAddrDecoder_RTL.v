//========================================================================
// MemoryBusAddrDecoder_RTL
//========================================================================

`ifndef MEMORY_BUS_ADDR_DECODER_V
`define MEMORY_BUS_ADDR_DECODER_V

`include "ece2300/ece2300-misc.v"

module MemoryBusAddrDecoder_RTL
(
  (* keep=1 *) input  logic        en,
  (* keep=1 *) input  logic [31:0] addr,

  (* keep=1 *) output logic        out0_en,
  (* keep=1 *) output logic        out1_en,
  (* keep=1 *) output logic        out2_en,
  (* keep=1 *) output logic        out3_en
);

  assign out0_en = ( addr == 32'h0000_0210 ) & en;
  assign out1_en = ( addr == 32'h0000_0214 ) & en;
  assign out2_en = ( addr == 32'h0000_0218 ) & en;
  assign out3_en = ( addr == 32'h0000_021c ) & en;

endmodule

`endif /* MEMORY_BUS_ADDR_DECODER_V */

