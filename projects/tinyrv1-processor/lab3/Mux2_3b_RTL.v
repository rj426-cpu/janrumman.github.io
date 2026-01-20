//========================================================================
// Mux2_3b_RTL
//========================================================================

`ifndef MUX2_3B_RTL
`define MUX2_3B_RTL

`include "ece2300/ece2300-misc.v"

module Mux2_3b_RTL
(
  (* keep=1 *) input  logic [2:0] in0,
  (* keep=1 *) input  logic [2:0] in1,
  (* keep=1 *) input  logic       sel,
  (* keep=1 *) output logic [2:0] out
);

  always_comb begin 
    case (sel) 
    1'b0: out = in0;
    1'b1: out = in1;
    default: out = 'x;
    endcase
  end

endmodule

`endif /* MUX2_3B_RTL */
