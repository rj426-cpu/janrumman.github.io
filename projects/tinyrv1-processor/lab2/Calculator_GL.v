//========================================================================
// Calculator_GL
//========================================================================

`ifndef CALCULATOR_GL
`define CALCULATOR_GL

`include "ece2300/ece2300-misc.v"
`include "lab2/AdderCarrySelect_16b_GL.v"
`include "lab2/Multiplier_2x16b_GL.v"
`include "lab2/Mux2_16b_GL.v"

module Calculator_GL
(
  (* keep=1 *) input  wire [15:0] in0,
  (* keep=1 *) input  wire [15:0] in1,
  (* keep=1 *) input  wire        op,
  (* keep=1 *) output wire [15:0] result
);

wire [15:0]  sum;
wire [15:0] prod;
wire cout;

// Compute 16-bit sum using carry-select adder
AdderCarrySelect_16b_GL adder 
(
  .in0  ( in0  ),
  .in1  ( in1  ),
  .cin  ( 1'b0 ),
  .cout ( cout ),
  .sum  ( sum  )
);

// Compute 2x16-bit product (low 16 bits only), using the 2 LSB of in1
Multiplier_2x16b_GL multiplier 
(
  .in0  ( in0       ),
  .in1  ( in1[1:0]  ),
  .prod ( prod      )
);

// Select between addition result and multiplication result from op
Mux2_16b_GL mux 
(
  .in0  ( sum    ),
  .in1  ( prod   ),
  .sel  ( op     ),
  .out  ( result )
);

// Overflow bit from adder is unused
`ECE2300_UNUSED( cout );

endmodule

`endif /* CALCULATOR_GL */

