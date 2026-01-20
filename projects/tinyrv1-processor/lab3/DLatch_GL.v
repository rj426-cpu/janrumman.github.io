//========================================================================
// DLatch_GL
//========================================================================

`ifndef DLATCH_GL_V
`define DLATCH_GL_V

`include "ece2300/ece2300-misc.v"

// verilator lint_off UNOPTFLAT

module DLatch_GL
(
  (* keep=1 *) input  wire clk,
  (* keep=1 *) input  wire d,
  (* keep=1 *) output wire q
);

wire n_d, s, r, w;

// Invert data input
not( n_d, d );

// Generate Set s and Reset r based on clk and d
and( s, d, clk );     // Set when clk=1 and d=1
and( r, clk, n_d );     // Reset when clk=1 and d=0

// SR latch implementation using cross-coupled NOR gates
nor( w, s, q );
nor( q, w, r );

endmodule

`endif /* DLATCH_GL_V */
