//========================================================================
// BinaryToSevenSegOpt_GL
//========================================================================

`ifndef BINARY_TO_SEVEN_SEG_OPT_GL_V
`define BINARY_TO_SEVEN_SEG_OPT_GL_V

`include "ece2300/ece2300-misc.v"

module BinaryToSevenSegOpt_GL
(
  input  wire [3:0] in,
  output wire [6:0] seg
);
  // Assigning wires a, b, c, d to the 4 bit input
  wire a, b, c, d;
  assign a = in[3];
  assign b = in[2];
  assign c = in[1];
  assign d = in[0];

  // Four not gates
  wire n_a, n_b, n_c, n_d;
  not( n_a, a );
  not( n_b, b );
  not( n_c, c );
  not( n_d, d );
  
  // SOP for seg[0]: seg[0] = ~A*~B*~C*D + ~A*B*~C*~D
  // The k-map did not contain adjacent ones, cannot be simplified
  wire seg0_1, seg0_2;
  and( seg0_1, n_a, n_b, n_c,   d );
  and( seg0_2, n_a,   b, n_c, n_d );
  or ( seg[0], seg0_1, seg0_2 );

  // SOP for seg[1]: seg[1] = ~A*B*~C*D + ~A*B*C*~D
  // The k-map did not contain adjacent ones, cannot be simplified
  wire seg1_1, seg1_2;
  and( seg1_1, n_a, b, n_c,   d );
  and( seg1_2, n_a, b,   c, n_d );
  or ( seg[1], seg1_1, seg1_2 );

  // SOP for seg[2]: seg[2] =  ~A*~B*C*~D
  and( seg[2], n_a, n_b, c, n_d );

  // SOP for seg[3]: seg[3] = ~B*~C*D + ~A*B*~C*~D + ~A*B*C*D
  wire seg3_1, seg3_2, seg3_3;
  and( seg3_1,      n_b, n_c,   d );
  and( seg3_2, n_a,   b, n_c, n_d );
  and( seg3_3, n_a,   b,   c,   d );
  or ( seg[3], seg3_1, seg3_2, seg3_3 );

  // SOP for seg[4]: seg[4] = ~A*D + ~B*~C*D + ~A*B*~C*~D
  wire seg4_1, seg4_2, seg4_3;
  and( seg4_1, n_a,             d );
  and( seg4_2,      n_b, n_c,   d );
  and( seg4_3, n_a,   b, n_c, n_d );
  or ( seg[4], seg4_1, seg4_2, seg4_3 );

  // SOP for seg[5]: seg[5] = ~A*~B*D + ~A*~B*C + ~A*C*D
  wire seg5_1, seg5_2, seg5_3;
  and( seg5_1, n_a, n_b,    d );
  and( seg5_2, n_a, n_b, c    );
  and( seg5_3, n_a,      c, d );
  or ( seg[5], seg5_1, seg5_2, seg5_3 );

  // SOP for seg[6]: seg[6] = ~A*~B*~C + ~A*B*C*D
  wire seg6_1, seg6_2;
  and( seg6_1, n_a, n_b, n_c    );
  and( seg6_2, n_a,   b,   c, d );
  or ( seg[6], seg6_1, seg6_2 );

endmodule

`endif /* BINARY_TO_SEVEN_SEG_OPT_GL_V */
