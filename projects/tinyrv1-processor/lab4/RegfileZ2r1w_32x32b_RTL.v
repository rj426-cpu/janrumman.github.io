//========================================================================
// RegfileZ2r1w_32x32b_RTL
//========================================================================
// Register file with 32 32-bit entries, two read ports, and one write
// port. Reading register zero should always return zero. If waddr ==
// raddr then rdata should be the old data.

`ifndef REGFILE_Z_2R1W_32X32B_RTL
`define REGFILE_Z_2R1W_32X32B_RTL

`include "ece2300/ece2300-misc.v"

module RegfileZ2r1w_32x32b_RTL
(
  (* keep=1 *) input  logic        clk,

  (* keep=1 *) input  logic        wen,     // write enable
  (* keep=1 *) input  logic  [4:0] waddr,   // write address 
  (* keep=1 *) input  logic [31:0] wdata,   // write data

  (* keep=1 *) input  logic  [4:0] raddr0,  // read address 0
  (* keep=1 *) output logic [31:0] rdata0,  // read data    0

  (* keep=1 *) input  logic  [4:0] raddr1,  // read address 1
  (* keep=1 *) output logic [31:0] rdata1   // read data 1
);

  logic [31:0] m [32]; // instantiating 32 registers

  always_comb begin

      rdata0 = m[raddr0]; 
      rdata1 = m[raddr1]; 
  end
  
  always_ff @( posedge clk ) begin

    if ( wen )
      m[waddr] <= wdata;
    
    m[0] <= '0;

    `ECE2300_SEQ_XPROP( m[waddr], $isunknown(wen) );

  end

endmodule

`endif /* REGFILE_Z_2R1W_32x32b_RTL */
