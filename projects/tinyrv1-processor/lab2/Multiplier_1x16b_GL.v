//========================================================================
// Multiplier_1x16b_GL
//========================================================================

`ifndef MULTIPLIER_1x16B_GL
`define MULTIPLIER_1x16B_GL

`include "ece2300/ece2300-misc.v"

module Multiplier_1x16b_GL
(
  (* keep=1 *) input  wire [15:0] in0,
  (* keep=1 *) input  wire        in1,
  (* keep=1 *) output wire [15:0] prod
);

  and( prod[0] , in0[0] , in1 );
  and( prod[1] , in0[1] , in1 );
  and( prod[2] , in0[2] , in1 );
  and( prod[3] , in0[3] , in1 );
  and( prod[4] , in0[4] , in1 );
  and( prod[5] , in0[5] , in1 );
  and( prod[6] , in0[6] , in1 );
  and( prod[7] , in0[7] , in1 );
  and( prod[8] , in0[8] , in1 );
  and( prod[9] , in0[9] , in1 );
  and( prod[10], in0[10], in1 );
  and( prod[11], in0[11], in1 );
  and( prod[12], in0[12], in1 );
  and( prod[13], in0[13], in1 );
  and( prod[14], in0[14], in1 );
  and( prod[15], in0[15], in1 );

endmodule

`endif /* MULTIPLIER_1x16B_GL */

