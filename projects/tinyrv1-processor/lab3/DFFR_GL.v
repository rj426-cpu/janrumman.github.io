//========================================================================
// DFFR_GL
//========================================================================

`ifndef DFFR_GL_V
`define DFFR_GL_V

`include "lab3/DFF_GL.v"

module DFFR_GL
(
  (* keep=1 *) input  wire clk,
  (* keep=1 *) input  wire rst,
  (* keep=1 *) input  wire d,
  (* keep=1 *) output wire q
);

wire n_rst, in_d;

not( n_rst, rst     ); // Invert the reset to for active-low 
and( in_d, d, n_rst ); // Mask input 'd' with reset

DFF_GL flipflop 
(
  .clk (clk),
  .d   (in_d),
  .q   (q)
);

endmodule

`endif /* DFFR_GL_V */
