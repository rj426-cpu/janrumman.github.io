//========================================================================
// Register_16b_GL
//========================================================================

`ifndef REGISTER_16B_GL_V
`define REGISTER_16B_GL_V

`include "ece2300/ece2300-misc.v"
`include "lab3/DFFRE_GL.v"

module Register_16b_GL
(
  (* keep=1 *) input  wire        clk,
  (* keep=1 *) input  wire        rst,
  (* keep=1 *) input  wire        en,
  (* keep=1 *) input  wire [15:0] d,
  (* keep=1 *) output wire [15:0] q
);

DFFRE_GL dffr0
(
  .clk (clk),
  .rst (rst),
  .en  (en),
  .d   (d[0]),
  .q   (q[0])
);

DFFRE_GL dffr1
(
  .clk (clk),
  .rst (rst),
  .en  (en),
  .d   (d[1]),
  .q   (q[1])
);

DFFRE_GL dffr2
(
  .clk (clk),
  .rst (rst),
  .en  (en),
  .d   (d[2]),
  .q   (q[2])
);

DFFRE_GL dffr3
(
  .clk (clk),
  .rst (rst),
  .en  (en),
  .d   (d[3]),
  .q   (q[3])
);

DFFRE_GL dffr4
(
  .clk (clk),
  .rst (rst),
  .en  (en),
  .d   (d[4]),
  .q   (q[4])
);

DFFRE_GL dffr5
(
  .clk (clk),
  .rst (rst),
  .en  (en),
  .d   (d[5]),
  .q   (q[5])
);

DFFRE_GL dffr6
(
  .clk (clk),
  .rst (rst),
  .en  (en),
  .d   (d[6]),
  .q   (q[6])
);

DFFRE_GL dffr7
(
  .clk (clk),
  .rst (rst),
  .en  (en),
  .d   (d[7]),
  .q   (q[7])
);

DFFRE_GL dffr8
(
  .clk (clk),
  .rst (rst),
  .en  (en),
  .d   (d[8]),
  .q   (q[8])
);

DFFRE_GL dffr9
(
  .clk (clk),
  .rst (rst),
  .en  (en),
  .d   (d[9]),
  .q   (q[9])
);

DFFRE_GL dffr10
(
  .clk (clk),
  .rst (rst),
  .en  (en),
  .d   (d[10]),
  .q   (q[10])
);

DFFRE_GL dffr11
(
  .clk (clk),
  .rst (rst),
  .en  (en),
  .d   (d[11]),
  .q   (q[11])
);

DFFRE_GL dffr12
(
  .clk (clk),
  .rst (rst),
  .en  (en),
  .d   (d[12]),
  .q   (q[12])
);

DFFRE_GL dffr13
(
  .clk (clk),
  .rst (rst),
  .en  (en),
  .d   (d[13]),
  .q   (q[13])
);

DFFRE_GL dffr14
(
  .clk (clk),
  .rst (rst),
  .en  (en),
  .d   (d[14]),
  .q   (q[14])
);

DFFRE_GL dffr15
(
  .clk (clk),
  .rst (rst),
  .en  (en),
  .d   (d[15]),
  .q   (q[15])
);

endmodule

`endif /* REGISTER_16B_GL_V */

