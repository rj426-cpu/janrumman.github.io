//=========================================================================
// Integer Multiplier Detector Implementation
//=========================================================================

`ifndef LAB1_IMUL_INT_MUL_ALT_DETECTOR_V
`define LAB1_IMUL_INT_MUL_ALT_DETECTOR_V

module lab1_imul_IntMulAltDetector
(
  input  logic [31:0] b,
  output logic [3:0]  shift_amt
);

  always_comb begin

    if ( b[0] )
      shift_amt = 4'd1;

    else if ( b[7:0] == 8'b00000000 )
      shift_amt = 4'd8;

    else if ( b[6:0] == 7'b0000000 )
      shift_amt = 4'd7;

    else if ( b[5:0] == 6'b000000 )
      shift_amt = 4'd6;

    else if ( b[4:0] == 5'b00000 )
      shift_amt = 4'd5;

    else if ( b[3:0] == 4'b0000 )
      shift_amt = 4'd4;

    else if ( b[2:0] == 3'b000 )
      shift_amt = 4'd3;

    else if ( b[1:0] == 2'b00 )
      shift_amt = 4'd2;

    else
      shift_amt = 4'd1;

  end

endmodule

`endif /* LAB1_IMUL_INT_MUL_ALT_DETECTOR_V */
