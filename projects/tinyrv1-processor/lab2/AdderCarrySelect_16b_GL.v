//========================================================================
// AdderCarrySelect_16b_GL
//========================================================================

`ifndef ADDER_CARRY_SELECT_16B_GL
`define ADDER_CARRY_SELECT_16B_GL

`include "ece2300/ece2300-misc.v"
`include "lab2/AdderRippleCarry_8b_GL.v"
`include "lab2/Mux2_8b_GL.v"
`include "lab2/Mux2_1b_GL.v"

module AdderCarrySelect_16b_GL
(
  (* keep=1 *) input  wire [15:0] in0,
  (* keep=1 *) input  wire [15:0] in1,
  (* keep=1 *) input  wire        cin,
  (* keep=1 *) output wire        cout,
  (* keep=1 *) output wire [15:0] sum
);

// Interal carry signals and partial sums
wire carry0, carry1, carry2;
wire [7:0] sum1;
wire [7:0] sum2;

//Lower 8-bit ripple carry adder
AdderRippleCarry_8b_GL adder0
(
  .in0  ( in0[7:0] ),
  .in1  ( in1[7:0] ),
  .cin  ( cin      ),
  .cout ( carry0   ),
  .sum  ( sum[7:0] )
);

// Upper 8-bit ripple-carry adder with cin = 0
AdderRippleCarry_8b_GL adder1
(
  .in0  ( in0[15:8] ),
  .in1  ( in1[15:8] ),
  .cin  ( 1'b0      ),
  .cout ( carry1    ),
  .sum  ( sum1      )
);

// Upper 8-bit ripple-carry adder with cin = 1
AdderRippleCarry_8b_GL adder2
(
  .in0  ( in0[15:8] ),
  .in1  ( in1[15:8] ),
  .cin  ( 1'b1      ),
  .cout ( carry2    ),
  .sum  ( sum2      )
);

//Upper bit sums based on carry0
Mux2_8b_GL mux0 
(
  .in0 ( sum1      ),
  .in1 ( sum2      ),
  .sel ( carry0    ),
  .out ( sum[15:8] )
);

//final carry out signal signal
Mux2_1b_GL mux1 
(
  .in0 ( carry1 ),
  .in1 ( carry2 ),
  .sel ( carry0 ),
  .out ( cout   )
);

endmodule

`endif /* ADDER_CARRY_SELECT_16B_GL */

