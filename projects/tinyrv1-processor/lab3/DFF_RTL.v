//========================================================================
// DFF_RTL
//========================================================================

`ifndef DFF_RTL_V
`define DFF_RTL_V

`include "ece2300/ece2300-misc.v"

module DFF_RTL
(
  (* keep=1 *) input  logic clk,
  (* keep=1 *) input  logic d,
  (* keep=1 *) output logic q
);

  always_ff @( posedge clk ) begin
    q <= d;
  end

endmodule

`endif /* DFF_RTL_V */
