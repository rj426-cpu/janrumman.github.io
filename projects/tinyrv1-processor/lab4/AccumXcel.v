//========================================================================
// AccumXcel
//========================================================================

`ifndef ACCUM_XCEL_V
`define ACCUM_XCEL_V

`include "ece2300/ece2300-misc.v"
`include "lab4/AccumXcelDpath.v"
`include "lab4/AccumXcelCtrl.v"

module AccumXcel
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Input val/rdy interface

  (* keep=1 *) output logic        in_rdy,
  (* keep=1 *) input  logic        in_val,
  (* keep=1 *) input  logic  [6:0] in_size, 

  // Result

  (* keep=1 *) output logic [31:0] result,

  // Memory interface

  (* keep=1 *) output logic        mem_val,
  (* keep=1 *) output logic [31:0] mem_addr,
  (* keep=1 *) input  logic [31:0] mem_rdata

);
  // Additional Logic

  logic         addr_counter_load;
  logic                  mem_type;
  logic [15:0] addr_counter_start;
  logic                     state;
  logic                     equal;
  logic                    add_en;
  logic                   rst_sel;

  AccumXcelCtrl ctrl
  (
    .*
  );

  AccumXcelDpath dpath
  (
    .*
  );

`ECE2300_UNUSED(mem_type);
`ECE2300_UNUSED(in_val  );
`ECE2300_UNUSED(state   );

endmodule


`endif /* ACCUM_XCEL_V */
