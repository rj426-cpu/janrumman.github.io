//========================================================================
// DFFR_RTL
//========================================================================

`ifndef DFFR_RTL_V
`define DFFR_RTL_V

`include "ece2300/ece2300-misc.v"

module DFFR_RTL
(
  (* keep=1 *) input  logic clk,
  (* keep=1 *) input  logic rst,
  (* keep=1 *) input  logic d,
  (* keep=1 *) output logic q
);

always_ff @( posedge clk ) begin

  if ( rst )
    q <= 1'b0;
  else
    q <= d;

 `ECE2300_SEQ_XPROP( q, $isunknown(rst) );
end

endmodule

`endif /* DFFR_RTL_V */

