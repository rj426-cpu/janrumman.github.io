//========================================================================
// Mux8_1b_RTL
//========================================================================

`ifndef MUX8_1B_RTL
`define MUX8_1B_RTL

`include "ece2300/ece2300-misc.v"

module Mux8_1b_RTL
(
  (* keep=1 *) input  logic       in0,
  (* keep=1 *) input  logic       in1,
  (* keep=1 *) input  logic       in2,
  (* keep=1 *) input  logic       in3,
  (* keep=1 *) input  logic       in4,
  (* keep=1 *) input  logic       in5,
  (* keep=1 *) input  logic       in6,
  (* keep=1 *) input  logic       in7,
  (* keep=1 *) input  logic [2:0] sel,
  (* keep=1 *) output logic       out
);

  always_comb begin 
    case ( sel )
      3'b000: out = in0;
      3'b001: out = in1;
      3'b010: out = in2; 
      3'b011: out = in3;
      3'b100: out = in4;
      3'b101: out = in5;
      3'b110: out = in6;
      3'b111: out = in7;
      default: out = 'x;
    endcase
  end 

endmodule

`endif /* MUX8_1B_RTL */

