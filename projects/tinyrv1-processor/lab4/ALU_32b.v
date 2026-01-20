//========================================================================
// ALU_32b
//========================================================================
// Simple ALU which supports both addition and equality comparision. For
// equality comparison the least-significant bit will be one if in0
// equals in1 and zero otherwise; the remaining 31 bits will always be
// zero.
//
//  - op == 0 : add
//  - op == 1 : equality comparison
//

`ifndef ALU_32B_V
`define ALU_32B_V

`include "ece2300/ece2300-misc.v"
`include "lab4/Adder_32b_GL.v"
`include "lab4/EqComparator_32b_RTL.v"
`include "lab4/Mux2_32b_RTL.v"

module ALU_32b
(
  (* keep=1 *) input  logic [31:0] in0,
  (* keep=1 *) input  logic [31:0] in1,
  (* keep=1 *) input  logic        op,
  (* keep=1 *) output logic [31:0] out
);

  wire [31:0] add_out;
  wire         eq_out;
  wire [31:0]  mux_eq;
  
  assign mux_eq[31:1] = 31'b0;
  assign mux_eq[0] = eq_out;

  Adder_32b_GL Adder
  (
    .in0  (in0),
    .in1  (in1),
    .sum  (add_out)
  );

  EqComparator_32b_RTL Eqcomp
  (
    .in0  (in0),
    .in1  (in1),
    .eq   (eq_out)
  );

  Mux2_32b_RTL Mux
  (
    .in0  (add_out),
    .in1  (mux_eq),
    .sel  (op),
    .out  (out)
  );

endmodule

`endif /* ALU_32B_V */

