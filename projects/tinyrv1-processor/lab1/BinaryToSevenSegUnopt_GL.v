//========================================================================
// BinaryToSevenSegUnopt_GL
//========================================================================

`ifndef BINARY_TO_SEVEN_SEG_UNOPT_GL_V
`define BINARY_TO_SEVEN_SEG_UNOPT_GL_V

`include "ece2300/ece2300-misc.v"

module BinaryToSevenSegUnopt_GL
(
  input  wire [3:0] in,
  output wire [6:0] seg
);

  wire a, b, c, d;

  // Assigning wires a, b, c, d to the 4 bit input
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

  // There are 9 rows where the outputs are not all 0. So we will 
  // create 9 AND gates to represent these rows 
  wire d0, d1, d2, d3, d4, d5, d6, d7, d9; // signifying decimal values
  
  and( d0, n_a, n_b, n_c, n_d );             
  and( d1, n_a, n_b, n_c,   d );
  and( d2, n_a, n_b,   c, n_d );
  and( d3, n_a, n_b,   c,   d );
  and( d4, n_a,   b, n_c, n_d );
  and( d5, n_a,   b, n_c,   d );
  and( d6, n_a,   b,   c, n_d );
  and( d7, n_a,   b,   c,   d );
  and( d9,   a, n_b, n_c,   d );

  // Seven OR gates for each segment of the 7-segment display
  or( seg[6], d0, d1, d7             );     // segment 7
  or( seg[5], d1, d2, d3, d7         );     // segment 6 
  or( seg[4], d1, d3, d4, d5, d7, d9 );     // segment 5  
  or( seg[3], d1, d4, d7, d9         );     // segment 4 
  or( seg[2], d2                     );     // segment 3
  or( seg[1], d5, d6                 );     // segment 2
  or( seg[0], d1, d4                 );     // segment 1

endmodule

`endif /* BINARY_TO_SEVEN_SEG_UNOPT_GL_V */
