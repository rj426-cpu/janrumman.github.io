//========================================================================
// AdderRippleCarry_8b_GL
//========================================================================

`ifndef ADDER_RIPPLE_CARRY_8B_GL
`define ADDER_RIPPLE_CARRY_8B_GL

`include "ece2300/ece2300-misc.v"
`include "lab2/FullAdder_GL.v"

module AdderRippleCarry_8b_GL
(
  (* keep=1 *) input  wire [7:0] in0,
  (* keep=1 *) input  wire [7:0] in1,
  (* keep=1 *) input  wire       cin,
  (* keep=1 *) output wire       cout,
  (* keep=1 *) output wire [7:0] sum
);

  // internal carry signals between full adders
  wire carry0, carry1, carry2, carry3;
  wire carry4, carry5, carry6;

  // Full Adder Instantiations
  // 1st adder: Least significant bit 
  FullAdder_GL fa0 
  (
    .in0  ( in0[0] ),
    .in1  ( in1[0] ),
    .cin  ( cin    ),
    .cout ( carry0 ),
    .sum  ( sum[0] )
  );

  // 2nd adder: uses carry from previous stage
  FullAdder_GL fa1 
  (
    .in0  ( in0[1] ),
    .in1  ( in1[1] ),
    .cin  ( carry0 ),
    .cout ( carry1 ),
    .sum  ( sum[1] )
  );

  // 3rd adder: continues the ripple carry chain
  FullAdder_GL fa2 
  (
    .in0  ( in0[2] ),
    .in1  ( in1[2] ),
    .cin  ( carry1 ),
    .cout ( carry2 ),
    .sum  ( sum[2] )
  );

  // 4th adder: continues the ripple carry chain
  FullAdder_GL fa3 
  (
    .in0  ( in0[3] ),
    .in1  ( in1[3] ),
    .cin  ( carry2 ),
    .cout ( carry3 ),
    .sum  ( sum[3] )
  );

  // 5th adder: continues the ripple carry chain
  FullAdder_GL fa4 
  (
    .in0  ( in0[4] ),
    .in1  ( in1[4] ),
    .cin  ( carry3 ),
    .cout ( carry4 ),
    .sum  ( sum[4] )
  );

  // 6th adder: continues the ripple carry chain
  FullAdder_GL fa5 
  (
    .in0  ( in0[5] ),
    .in1  ( in1[5] ),
    .cin  ( carry4 ),
    .cout ( carry5 ),
    .sum  ( sum[5] )
  );

  // 7th adder: continues the ripple carry chain
  FullAdder_GL fa6 
  (
    .in0  ( in0[6] ),
    .in1  ( in1[6] ),
    .cin  ( carry5 ),
    .cout ( carry6 ),
    .sum  ( sum[6] )
  );

  // 8th adder: continues the ripple carry chain
  FullAdder_GL fa7 
  (
    .in0  ( in0[7] ),
    .in1  ( in1[7] ),
    .cin  ( carry6 ),
    .cout ( cout   ),
    .sum  ( sum[7] )
  );


endmodule

`endif /* ADDER_RIPPLE_CARRY_8B_GL */

