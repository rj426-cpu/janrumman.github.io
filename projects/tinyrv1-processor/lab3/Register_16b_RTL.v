//========================================================================
// Register_16b_RTL
//========================================================================

`ifndef REGISTER_16B_RTL_V
`define REGISTER_16B_RTL_V

`include "ece2300/ece2300-misc.v"

module Register_16b_RTL
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,
  (* keep=1 *) input  logic        en,
  (* keep=1 *) input  logic [15:0] d,
  (* keep=1 *) output logic [15:0] q
);

always_ff @( posedge clk ) begin
  
  if ( rst )
    q <= 16'b0;
  else if ( en )
    q <= d;
  else  
    q <= q;
    
  `ECE2300_SEQ_XPROP( q, $isunknown(rst) );
  `ECE2300_SEQ_XPROP( q, (rst == 0) && $isunknown(en) );
end

endmodule

`endif /* REGISTER_16B_RTL_V */

