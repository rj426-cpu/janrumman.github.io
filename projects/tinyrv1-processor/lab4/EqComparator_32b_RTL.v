//========================================================================
// EqComparator_32b_RTL
//========================================================================

`ifndef EQ_COMPARATOR_32B_RTL_V
`define EQ_COMPARATOR_32B_RTL_V

`include "ece2300/ece2300-misc.v"

module EqComparator_32b_RTL
(
  (* keep=1 *) input  logic [31:0] in0,
  (* keep=1 *) input  logic [31:0] in1,
  (* keep=1 *) output logic        eq
);

  assign eq = (in0 == in1);

endmodule

`endif /* EQ_COMPARATOR_32B_RTL_V */

