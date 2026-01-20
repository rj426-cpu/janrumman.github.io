//========================================================================
// Mux2_16b_GL
//========================================================================

`ifndef MUX2_16B_GL
`define MUX2_16B_GL

`include "ece2300/ece2300-misc.v"
`include "lab2/Mux2_8b_GL.v"

module Mux2_16b_GL
(
  (* keep=1 *) input  wire [15:0] in0,
  (* keep=1 *) input  wire [15:0] in1,
  (* keep=1 *) input  wire        sel,
  (* keep=1 *) output wire [15:0] out
);


Mux2_8b_GL mux0 
(
  .in0( in0[7:0] ),
  .in1( in1[7:0] ),
  .sel( sel      ),
  .out( out[7:0] )   
);  

Mux2_8b_GL mux1 
(
  .in0( in0[15:8] ),
  .in1( in1[15:8] ),
  .sel( sel       ),
  .out( out[15:8] )   
);  

endmodule

`endif /* MUX2_16B_GL */

