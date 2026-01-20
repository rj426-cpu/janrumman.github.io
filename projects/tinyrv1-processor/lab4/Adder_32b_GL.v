//========================================================================
// Adder_32b_GL
//========================================================================

`ifndef ADDER_32B_GL
`define ADDER_32B_GL

`include "ece2300/ece2300-misc.v"
`include "lab2/AdderCarrySelect_16b_GL.v"

module Adder_32b_GL
(
  (* keep=1 *) input  wire [31:0] in0,
  (* keep=1 *) input  wire [31:0] in1,
  (* keep=1 *) output wire [31:0] sum
);

  wire out;
  wire cout;

  AdderCarrySelect_16b_GL Adder0
  (
    .in0  (in0[15:0]),
    .in1  (in1[15:0]),
    .cin  (1'b0),
    .cout (cout),
    .sum  (sum[15:0])
  );

  AdderCarrySelect_16b_GL Adder1
  (
    .in0  (in0[31:16]),
    .in1  (in1[31:16]),
    .cin  (cout),
    .cout (out),
    .sum  (sum[31:16])
  );

  `ECE2300_UNUSED( out  );

endmodule

`endif /* ADDER_32B_GL */

