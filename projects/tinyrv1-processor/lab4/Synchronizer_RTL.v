//========================================================================
// Synchronizer_RTL
//========================================================================

`ifndef SYNCHRONIZER_RTL_V
`define SYNCHRONIZER_RTL_V

`include "ece2300/ece2300-misc.v"
`include "lab3/DFF_RTL.v"

module Synchronizer_RTL
(
  (* keep=1 *) input  logic clk,
  (* keep=1 *) input  logic d,
  (* keep=1 *) output logic q
);

  logic q0; 

  DFF_RTL dff1 
  (
    .clk  (clk),
    .d    (d),
    .q    (q0)
  );

  DFF_RTL dff2
  (
    .clk  (clk),
    .d    (q0),
    .q    (q)
  );

endmodule

`endif /* SYNCHRONIZER_RTL_V */
