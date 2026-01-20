//========================================================================
// FullAdder_GL
//========================================================================

`ifndef FULL_ADDER_GL_V
`define FULL_ADDER_GL_V

`include "ece2300/ece2300-misc.v"

module FullAdder_GL
(
  (* keep=1 *) input  wire in0,
  (* keep=1 *) input  wire in1,
  (* keep=1 *) input  wire cin,
  (* keep=1 *) output wire cout,
  (* keep=1 *) output wire sum
);

  wire cout_0, cout_1, cout_2; 

  // Logic for cout
  and( cout_0, in0, in1 ); 
  and( cout_1, in1, cin ); 
  and( cout_2, in0, cin );
  
  // Minterms combined in an OR 
  or ( cout, cout_0, cout_1, cout_2 ); 

  // odd parity of in0, in1, cin
  xor( sum, in0, in1, cin ); 

endmodule

`endif /* FULL_ADDER_GL_V */

