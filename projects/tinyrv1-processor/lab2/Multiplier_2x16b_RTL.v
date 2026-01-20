//========================================================================
// Multiplier_2x16b_RTL
//========================================================================

`ifndef MULTIPLIER_2x16B_RTL
`define MULTIPLIER_2x16B_RTL

`include "ece2300/ece2300-misc.v"

module Multiplier_2x16b_RTL
(
  (* keep=1 *) input  logic [15:0] in0,
  (* keep=1 *) input  logic  [1:0] in1,
  (* keep=1 *) output logic [15:0] prod
);

  assign prod = in0 * in1;

endmodule

`endif /* MULTIPLIER_2x16b_RTL */

