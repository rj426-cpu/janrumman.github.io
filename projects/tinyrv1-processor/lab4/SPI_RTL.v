//========================================================================
// SPI_RTL
//========================================================================

`ifndef SPI_RTL_V
`define SPI_RTL_V

`include "ece2300/ece2300-misc.v"

`include "lab4/Synchronizer_RTL.v"
`include "lab4/EdgeDetector_RTL.v"
`include "lab4/ShiftRegister_44b_RTL.v"

module SPI_RTL
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Serial Peripheral Interface

  (* keep=1 *) input  logic        cs,
  (* keep=1 *) input  logic        sclk,
  (* keep=1 *) input  logic        mosi,
  (* keep=1 *) output logic        miso,

  // On-chip Interface

  (* keep=1 *) output logic        hmem_val,
  (* keep=1 *) output logic [31:0] hmem_addr,
  (* keep=1 *) output logic [31:0] hmem_wdata
);

  // Internal Logic
  
  logic            q_cs;
  logic          q_mosi;
  logic          q_sclk;
  logic        shift_en;
  logic [43:0]   sr_out;

  // CS

  Synchronizer_RTL synchronizer_cs
  (
    .clk (clk),
    .d   (cs),
    .q   (q_cs) 
  );

  EdgeDetector_RTL edge_detect_cs
  (
    .clk      (clk),
    .d        (q_cs),
    .pos_edge (hmem_val)
  );

  // MOSI

  Synchronizer_RTL synchronizer_mosi
  (
    .clk  (clk),
    .d    (mosi),
    .q    (q_mosi) 
  );

  // SCLK

  Synchronizer_RTL synchronizer_sclk
  (
    .clk  (clk),
    .d    (sclk),
    .q    (q_sclk) 
  );

  EdgeDetector_RTL edge_detect_sclk
  (
    .clk       (clk),
    .d         (q_sclk),
    .pos_edge  (shift_en)
  );

  ShiftRegister_44b_RTL shift_reg
  (
    .clk   (clk),
    .rst   (rst),
    .en    (shift_en),
    .sin   (q_mosi),
    .pout  (sr_out)
  );

  // MISO

  assign miso = 1'b0;

  // Output Logic
  
  assign hmem_addr = {20'b0, sr_out[43:32]};
  assign hmem_wdata = sr_out[31:0];

endmodule

`endif /* SPI_RTL_V */
