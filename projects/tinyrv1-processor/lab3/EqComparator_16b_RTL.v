//========================================================================
// EqComparator_16b_RTL
//========================================================================

`ifndef EQCOMPARATOR_16B_RTL_V
`define EQCOMPARATOR_16B_RTL_V

`include "ece2300/ece2300-misc.v"

module EqComparator_16b_RTL
(
  (* keep=1 *) input  logic [15:0] in0,
  (* keep=1 *) input  logic [15:0] in1,
  (* keep=1 *) output logic        eq
);

  assign eq = (in0 == in1);

endmodule

`endif /* EQCOMPARATOR_16B_RTL_V */

