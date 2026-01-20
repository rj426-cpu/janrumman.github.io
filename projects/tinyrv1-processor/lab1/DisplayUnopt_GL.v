//========================================================================
// DisplayUnopt_GL
//========================================================================

`ifndef DISPLAY_UNOPT_GL_V
`define DISPLAY_UNOPT_GL_V

`include "ece2300/ece2300-misc.v"
`include "lab1/BinaryToBinCodedDec_GL.v"
`include "lab1/BinaryToSevenSegUnopt_GL.v"

module DisplayUnopt_GL
(
  input  wire [4:0] in,
  output wire [6:0] seg_tens,
  output wire [6:0] seg_ones
);

  wire [3:0] tens_bcd; // 4 digits of tens converted w BinaryToBinCodedDec
  wire [3:0] ones_bcd; // 4 digits of ones converted w BinaryToBinCodedDec
  
  BinaryToBinCodedDec_GL bcd_converter (
    .in   (in),
    .tens (tens_bcd),
    .ones (ones_bcd)
  );

  BinaryToSevenSegUnopt_GL seg_tens_converter (
    .in   (tens_bcd),
    .seg  (seg_tens)
  );

  BinaryToSevenSegUnopt_GL seg_ones_converter (
    .in   (ones_bcd),
    .seg  (seg_ones)
  );

endmodule

`endif /* DISPLAY_UNOPT_GL_V */
