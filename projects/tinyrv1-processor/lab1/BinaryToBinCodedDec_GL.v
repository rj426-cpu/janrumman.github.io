//========================================================================
// BinaryToBinCodedDec_GL
//========================================================================

`ifndef BINARY_TO_BIN_CODED_DEC_GL_V
`define BINARY_TO_BIN_CODED_DEC_GL_V

`include "ece2300/ece2300-misc.v"

module BinaryToBinCodedDec_GL
(
  input  wire [4:0] in,
  output wire [3:0] tens,
  output wire [3:0] ones
);
  wire a, b, c, d, e; 

  // Assigning wires a, b, c, d, e to the 5 bit input
  assign a = in[4];
  assign b = in[3]; 
  assign c = in[2]; 
  assign d = in[1];
  assign e = in[0]; 

  // Five not gates
  wire n_a, n_b, n_c, n_d, n_e;
  
  not( n_a, a );
  not( n_b, b );
  not( n_c, c );
  not( n_d, d );
  not( n_e, e );

  // 31 wires for 31 rows with non 0 output
  wire d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10;
  wire d11, d12, d13, d14, d15, d16, d17, d18, d19, d20;
  wire d21, d22, d23, d24, d25, d26, d27, d28, d29, d30;

  and( d0,  n_a, n_b, n_c, n_d,   e );  // 1
  and( d1,  n_a, n_b, n_c,   d, n_e );  // 2
  and( d2,  n_a, n_b, n_c,   d,   e );  // 3
  and( d3,  n_a, n_b,   c, n_d, n_e );  // 4
  and( d4,  n_a, n_b,   c, n_d,   e );  // 5
  and( d5,  n_a, n_b,   c,   d, n_e );  // 6
  and( d6,  n_a, n_b,   c,   d,   e );  // 7
  and( d7,  n_a,   b, n_c, n_d, n_e );  // 8
  and( d8,  n_a,   b, n_c, n_d,   e );  // 9
  and( d9,  n_a,   b, n_c,   d, n_e );  // 10
  and( d10, n_a,   b, n_c,   d,   e );  // 11
  and( d11, n_a,   b,   c, n_d, n_e );  // 12
  and( d12, n_a,   b,   c, n_d,   e );  // 13
  and( d13, n_a,   b,   c,   d, n_e );  // 14
  and( d14, n_a,   b,   c,   d,   e );  // 15
  and( d15,   a, n_b, n_c, n_d, n_e );  // 16
  and( d16,   a, n_b, n_c, n_d,   e );  // 17
  and( d17,   a, n_b, n_c,   d, n_e );  // 18
  and( d18,   a, n_b, n_c,   d,   e );  // 19
  and( d19,   a, n_b,   c, n_d, n_e );  // 20
  and( d20,   a, n_b,   c, n_d,   e );  // 21
  and( d21,   a, n_b,   c,   d, n_e );  // 22
  and( d22,   a, n_b,   c,   d,   e );  // 23
  and( d23,   a,   b, n_c, n_d, n_e );  // 24
  and( d24,   a,   b, n_c, n_d,   e );  // 25 
  and( d25,   a,   b, n_c,   d, n_e );  // 26
  and( d26,   a,   b, n_c,   d,   e );  // 27
  and( d27,   a,   b,   c, n_d, n_e );  // 28
  and( d28,   a,   b,   c, n_d,   e );  // 29
  and( d29,   a,   b,   c,   d, n_e );  // 30
  and( d30,   a,   b,   c,   d,   e );  // 31

  // Or segments 
  or ( ones[3],
       d7,  d8,  d17, d18,
       d27, d28
     );

  or ( ones[2],
       d3,  d4,  d5,  d6,
       d13, d14, d15, d16,
       d23, d24, d25, d26
     );

  or ( ones[1],
       d1,  d2,  d5,  d6,
       d11, d12, d15, d16,
       d21, d22, d25, d26
     );

  or ( ones[0],
       d0,  d2,  d4,  d6,
       d8,  d10, d12, d14,
       d16, d18, d20, d22,
       d24, d26, d28, d30
     );

  or ( tens[1],
       d19, d20, d21, d22,
       d23, d24, d25, d26,
       d27, d28, d29, d30
     );

  or ( tens[0],
       d9,  d10, d11, d12,
       d13, d14, d15, d16,
       d17, d18, d29, d30
     );


  assign tens[2] = 1'b0;
  assign tens[3] = 1'b0;

endmodule

`endif /* BINARY_TO_BIN_CODED_DEC_GL_V */
