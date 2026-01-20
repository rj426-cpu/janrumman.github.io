//========================================================================
// DFF_GL
//========================================================================

`ifndef DFF_GL_V
`define DFF_GL_V

`include "ece2300/ece2300-misc.v"
`include "lab3/DLatch_GL.v"

module DFF_GL
(
  input  wire clk,
  input  wire d,
  output wire q
);

wire n1, n_clk;
not( n_clk, clk );

DLatch_GL dlatch1 
(
  .clk (n_clk),
  .d   (d),
  .q   (n1)
);

DLatch_GL dlatch2 
(
  .clk (clk),
  .d   (n1),
  .q   (q)
);

endmodule

`endif /* DFF_GL_V */
