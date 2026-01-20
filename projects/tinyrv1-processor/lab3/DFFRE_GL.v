//========================================================================
// DFFRE_GL
//========================================================================

`ifndef DFFRE_GL_V
`define DFFRE_GL_V

`include "ece2300/ece2300-misc.v"
`include "lab2/Mux2_1b_GL.v"
`include "lab3/DFFR_GL.v"

// verilator lint_off UNOPTFLAT

module DFFRE_GL
(
  (* keep=1 *) input  wire clk,
  (* keep=1 *) input  wire rst,
  (* keep=1 *) input  wire en,
  (* keep=1 *) input  wire d,
  (* keep=1 *) output wire q
);

wire n_rst, din;
wire mux_out;

not( n_rst, rst          );
and( din, mux_out, n_rst );

// Multiplexer selects between current output q and new data d
// If en=1, pass d; if en=0, hold current value q
Mux2_1b_GL flipmux
(
  .in0 (q),
  .in1 (d),
  .sel (en),
  .out (mux_out)
);

DFF_GL flipflop 
(
  .clk (clk),
  .d   (din),
  .q   (q)
);

endmodule

`endif /* DFFRE_GL_V */
