//========================================================================
// Register_32b_RTL
//========================================================================

`ifndef REGISTER_32B_RTL_V
`define REGISTER_32B_RTL_V

`include "ece2300/ece2300-misc.v"

module Register_32b_RTL
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,
  (* keep=1 *) input  logic        en,
  (* keep=1 *) input  logic [31:0] d,
  (* keep=1 *) output logic [31:0] q
);

always_ff @( posedge clk ) begin

  if ( rst )
    q <= 32'b0;      // Reset output to 0
  else if ( en )
    q <= d;         // Load new data if enabled
  else  
    q <= q;         // Hold current value

  `ECE2300_SEQ_XPROP( q, $isunknown(rst) );
  `ECE2300_SEQ_XPROP( q, (rst == 0) && $isunknown(en) );
end

endmodule

`endif /* REGISTER_32B_RTL_V */

