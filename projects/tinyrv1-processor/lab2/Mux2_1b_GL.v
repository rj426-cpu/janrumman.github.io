//========================================================================
// Mux2_1b_GL
//========================================================================

`ifndef MUX2_1B_GL
`define MUX2_1B_GL

`include "ece2300/ece2300-misc.v"

module Mux2_1b_GL
(
  (* keep=1 *) input  in0,
  (* keep=1 *) input  in1,
  (* keep=1 *) input  sel,
  (* keep=1 *) output out
);
  // Not gate
  wire n_sel;
  not( n_sel, sel );

  // Summing minterms with an OR gate
  wire minterm1, minterm2;
  
  and( minterm1, n_sel, in0 );
  and( minterm2,   sel, in1 );

  or ( out, minterm1, minterm2 );

endmodule

`endif /* MUX2_1B_GL */

