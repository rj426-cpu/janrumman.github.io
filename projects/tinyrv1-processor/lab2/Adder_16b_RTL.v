//========================================================================
// Adder_16b_RTL
//========================================================================

`ifndef ADDER_16B_RTL
`define ADDER_16B_RTL

`include "ece2300/ece2300-misc.v"

module Adder_16b_RTL
(
  (* keep=1 *) input  logic [15:0] in0,
  (* keep=1 *) input  logic [15:0] in1,
  (* keep=1 *) input  logic        cin,
  (* keep=1 *) output logic        cout,
  (* keep=1 *) output logic [15:0] sum
  
);
  
  logic [16:0] result;
  assign result = in0 + in1 + { 15'b0, cin };
  assign cout = result[16];
  assign sum = result[15:0];  

endmodule

`endif /* ADDER_16B_RTL */

