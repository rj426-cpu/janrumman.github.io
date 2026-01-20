//========================================================================
// EdgeDetector_RTL
//========================================================================

`ifndef EDGE_DETECTOR_RTL_V
`define EDGE_DETECTOR_RTL_V

`include "ece2300/ece2300-misc.v"
`include "lab3/DFF_RTL.v"

module EdgeDetector_RTL
(
  (* keep=1 *) input  logic clk,
  (* keep=1 *) input  logic d,
  (* keep=1 *) output logic pos_edge
);
  logic d_out;
  DFF_RTL dff
  (
    .clk (clk),
    .d   (d),
    .q   (d_out)
  );

  always_comb begin
    pos_edge = 1'b0;

    if (d_out == 0 && d == 1)
      pos_edge = 1'b1; 

    `ECE2300_XPROP( pos_edge, $isunknown(d_out) && $isunknown(d) );
  end

endmodule

`endif /* EDGE_DETECTOR_RTL_V */
