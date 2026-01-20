//========================================================================
// MemoryBusDataMux_RTL
//========================================================================

`ifndef MEMORY_BUS_DATA_MUX_V
`define MEMORY_BUS_DATA_MUX_V

`include "ece2300/ece2300-misc.v"

module MemoryBusDataMux_RTL
(
  (* keep=1 *) input  logic [31:0] std,
  (* keep=1 *) input  logic [31:0] in0,
  (* keep=1 *) input  logic [31:0] in1,
  (* keep=1 *) input  logic [31:0] in2,
  (* keep=1 *) input  logic [31:0] in3,
  (* keep=1 *) input  logic [31:0] addr,
  (* keep=1 *) output logic [31:0] out
);

  assign out = ( addr == 32'h0000_0200 ) ? in0
             : ( addr == 32'h0000_0204 ) ? in1
             : ( addr == 32'h0000_0208 ) ? in2
             : ( addr == 32'h0000_020c ) ? in3
             :                             std;

endmodule

`endif /* MEMORY_BUS_DATA_MUX_V */
