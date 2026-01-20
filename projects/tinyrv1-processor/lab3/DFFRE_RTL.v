//========================================================================
// DFFRE_RTL_V
//========================================================================

`ifndef DFFRE_RTL_V
`define DFFRE_RTL_V

`include "ece2300/ece2300-misc.v"

module DFFRE_RTL
(
  (* keep=1 *) input  logic clk,
  (* keep=1 *) input  logic rst,
  (* keep=1 *) input  logic en,
  (* keep=1 *) input  logic d,
  (* keep=1 *) output logic q
);

always_ff @( posedge clk ) begin

  if ( rst )
    q <= 1'b0;      // Reset output to 0
  else if ( en )
    q <= d;         // Load new data if enabled
  else  
    q <= q;         // Hold current value

  `ECE2300_SEQ_XPROP( q, $isunknown(rst) );
  `ECE2300_SEQ_XPROP( q, (rst == 0) && $isunknown(en) );
end

endmodule

`endif /* DFFRE_RTL_V */

