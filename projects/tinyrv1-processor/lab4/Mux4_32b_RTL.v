//========================================================================
// Mux4_32b_RTL
//========================================================================

`ifndef MUX4_32b_RTL
`define MUX4_32b_RTL

`include "ece2300/ece2300-misc.v"

module Mux4_32b_RTL
(
  (* keep=1 *) input  logic [31:0] in0,
  (* keep=1 *) input  logic [31:0] in1,
  (* keep=1 *) input  logic [31:0] in2,
  (* keep=1 *) input  logic [31:0] in3,
  (* keep=1 *) input  logic  [1:0] sel,
  (* keep=1 *) output logic [31:0] out
);

  always_comb begin 
    case ( sel )
      2'b00: out = in0;
      2'b01: out = in1;
      2'b10: out = in2;
      2'b11: out = in3;
      default: out = 'x;
    endcase
  end 

endmodule

`endif /* MUX4_32b_RTL */

