//=========================================================================
// Cache Word Write-Byte-Enable Decoder
//=========================================================================

`ifndef LAB3_MEM_CACHE_WBEN_V
`define LAB3_MEM_CACHE_WBEN_V

module lab3_mem_CacheWben
(
  input  logic [ 1:0] word_offset,
  output logic [15:0] byte_en
);

  // Enable the four bytes belonging to the selected 32-bit word.

  always_comb begin
    case (word_offset)
      2'b00:   byte_en = 16'h000f;
      2'b01:   byte_en = 16'h00f0;
      2'b10:   byte_en = 16'h0f00;
      2'b11:   byte_en = 16'hf000;
      default: byte_en = 16'h0000;
    endcase
  end

endmodule

`endif