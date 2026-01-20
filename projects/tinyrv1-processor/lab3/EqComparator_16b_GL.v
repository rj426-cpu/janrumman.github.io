//========================================================================
// EqComparator_16b_GL
//========================================================================

`ifndef EQCOMPARATOR_16B_GL_V
`define EQCOMPARATOR_16B_GL_V

`include "ece2300/ece2300-misc.v"

module EqComparator_16b_GL
(
  (* keep=1 *) input  wire [15:0] in0,
  (* keep=1 *) input  wire [15:0] in1,
  (* keep=1 *) output wire        eq
);

  wire out[15:0];
  xnor( out[0 ], in0[0 ], in1[0 ] );
  xnor( out[1 ], in0[1 ], in1[1 ] );
  xnor( out[2 ], in0[2 ], in1[2 ] );
  xnor( out[3 ], in0[3 ], in1[3 ] );
  xnor( out[4 ], in0[4 ], in1[4 ] );
  xnor( out[5 ], in0[5 ], in1[5 ] );
  xnor( out[6 ], in0[6 ], in1[6 ] );
  xnor( out[7 ], in0[7 ], in1[7 ] );
  xnor( out[8 ], in0[8 ], in1[8 ] );
  xnor( out[9 ], in0[9 ], in1[9 ] );
  xnor( out[10], in0[10], in1[10] );
  xnor( out[11], in0[11], in1[11] );
  xnor( out[12], in0[12], in1[12] );
  xnor( out[13], in0[13], in1[13] );
  xnor( out[14], in0[14], in1[14] );
  xnor( out[15], in0[15], in1[15] );

  and ( eq,  out[0],  out[1],  out[2],  out[3],
             out[4],  out[5],  out[6],  out[7],
             out[8],  out[9], out[10], out[11],
            out[12], out[13], out[14], out[15] );

endmodule

`endif /* EQCOMPARATOR_16B_GL_V */
