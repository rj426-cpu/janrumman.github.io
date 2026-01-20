//========================================================================
// AdderRippleCarry_16b_GL
//========================================================================

`ifndef ADDER_RIPPLE_CARRY_16B_GL
`define ADDER_RIPPLE_CARRY_16B_GL

`include "ece2300/ece2300-misc.v"
`include "lab2/AdderRippleCarry_8b_GL.v"

module AdderRippleCarry_16b_GL
(
  (* keep=1 *) input  wire [15:0] in0,
  (* keep=1 *) input  wire [15:0] in1,
  (* keep=1 *) input  wire        cin,
  (* keep=1 *) output wire        cout,
  (* keep=1 *) output wire [15:0] sum
);

  wire carry; // carry signal from adder0 to adder1

  // AdderRippleCarry Instantiations
  // adder0: Least significant lower 8-bits
  AdderRippleCarry_8b_GL adder0 
  (
    .in0  ( in0[7:0] ),
    .in1  ( in1[7:0] ),
    .cin  ( cin      ),
    .cout ( carry    ),
    .sum  ( sum[7:0] )
  );

  // 2nd adder: uses carry from previous stage
  // adder0: Most significant upper 8-bits
  AdderRippleCarry_8b_GL adder1 
  (
    .in0  ( in0[15:8] ),
    .in1  ( in1[15:8] ),
    .cin  ( carry     ),
    .cout ( cout      ),
    .sum  ( sum[15:8] )
  );

endmodule

`endif /* ADDER_RIPPLE_CARRY_16B_GL */

