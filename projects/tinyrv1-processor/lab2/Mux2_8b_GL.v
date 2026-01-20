//========================================================================
// Mux2_8b_GL
//========================================================================

`ifndef MUX2_8B_GL
`define MUX2_8B_GL

`include "ece2300/ece2300-misc.v"
`include "lab2/Mux2_1b_GL.v"

module Mux2_8b_GL
(
  (* keep=1 *) input  wire [7:0] in0,
  (* keep=1 *) input  wire [7:0] in1,
  (* keep=1 *) input  wire       sel,
  (* keep=1 *) output wire [7:0] out
);

Mux2_1b_GL mux0 
(
  .in0( in0[0] ),
  .in1( in1[0] ),
  .sel( sel    ),
  .out( out[0] )   
);

Mux2_1b_GL mux1 
(
  .in0( in0[1] ),
  .in1( in1[1] ),
  .sel( sel    ),
  .out( out[1] )   
);

Mux2_1b_GL mux2 
(
  .in0( in0[2] ),
  .in1( in1[2] ),
  .sel( sel    ),
  .out( out[2] )   
);

Mux2_1b_GL mux3 
(
  .in0( in0[3] ),
  .in1( in1[3] ),
  .sel( sel    ),
  .out( out[3] )   
);

Mux2_1b_GL mux4 
(
  .in0( in0[4] ),
  .in1( in1[4] ),
  .sel( sel    ),
  .out( out[4] )   
);

Mux2_1b_GL mux5 
(
  .in0( in0[5] ),
  .in1( in1[5] ),
  .sel( sel    ),
  .out( out[5] )   
);

Mux2_1b_GL mux6 
(
  .in0( in0[6] ),
  .in1( in1[6] ),
  .sel( sel    ),
  .out( out[6] )   
);

Mux2_1b_GL mux7 
(
  .in0( in0[7] ),
  .in1( in1[7] ),
  .sel( sel    ),
  .out( out[7] )   
);

endmodule

`endif /* MUX2_8B_GL */

