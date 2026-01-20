//========================================================================
// Multiplier_2x16b_GL
//========================================================================

`ifndef MULTIPLIER_2x16B_GL
`define MULTIPLIER_2x16B_GL

`include "ece2300/ece2300-misc.v"
`include "lab2/Multiplier_1x16b_GL.v"
`include "lab2/AdderCarrySelect_16b_GL.v"


module Multiplier_2x16b_GL
(
  (* keep=1 *) input  wire [15:0] in0,
  (* keep=1 *) input  wire [1:0 ] in1,
  (* keep=1 *) output wire [15:0] prod
);
 //instantiate new wires
 wire [15:0] mout0;
 wire [15:0] mout1;
 wire [15:0] mrow2;
 wire [15:0]   sum;
 wire         cout;

 //first 1x16b multiplier which gives us first multiplication row
 Multiplier_1x16b_GL m0
 (
  .in0(in0[15:0]   ),
  .in1(in1[0]      ),
  .prod(mout0[15:0])
 );

//second 1x16b multiplier which gives us second multiplication row
 Multiplier_1x16b_GL m1
 (
  .in0(in0[15:0]   ),
  .in1(in1[1]      ),
  .prod(mout1[15:0])
 );

//shift the second row to the left by 1 for addition
assign mrow2[15:1] =mout1[14:0];
assign mrow2[0] = 1'b0;


//now put the sum of these two products in carry select adder for addition
AdderCarrySelect_16b_GL muladd
(
  .in0  ( mout0[15:0] ),
  .in1  ( mrow2[15:0] ),
  .cin  ( 1'b0        ),
  .cout ( cout        ),
  .sum  ( sum[15:0]   )
);

//Connect the final product wire to the sum found
assign prod = sum;

//carry output from adder and most sig bit is not used in the product
`ECE2300_UNUSED( mout1[15] );
`ECE2300_UNUSED( cout      );

endmodule

`endif /* MULTIPLIER_2x16B_GL */

