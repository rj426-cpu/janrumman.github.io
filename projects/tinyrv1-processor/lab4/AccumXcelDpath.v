//========================================================================
// AccumXcelDpath
//========================================================================

`ifndef ACCUM_XCEL_DPATH_V
`define ACCUM_XCEL_DPATH_V

`include "ece2300/ece2300-misc.v"
`include "lab3/Counter_16b_RTL.v"
`include "lab4/EqComparator_32b_RTL.v"
`include "lab4/Mux2_32b_RTL.v"
`include "lab4/Adder_32b_GL.v"
`include "lab4/Register_32b_RTL.v"

module AccumXcelDpath
(
  // Clock and Reset

  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Memory Interface
  (* keep=1 *) output logic  [31:0]  mem_addr,
  (* keep=1 *)  input logic  [31:0]  mem_rdata,
  (* keep=1 *)  input logic  [6:0 ]  in_size,

  // Control Signals (ctrl -> dpath)
  (* keep=1 *) input  logic         addr_counter_load,
  (* keep=1 *) input  logic [15:0]  addr_counter_start,
  (* keep=1 *) input  logic         mem_val,
  (* keep=1 *) input  logic         add_en,
  (* keep=1 *) input  logic         rst_sel,
  
  // Status Signals (dpath -> ctrl)
  (* keep=1 *) output logic         equal,
  (* keep=1 *) output logic [31:0]  result

);

  // Address Counter
  logic [15:0]   count;
  logic [15:0]    size;
  logic [31:0] add_in0;
  logic [31:0] mux_in0;
  logic [31:0]    d_in;
  logic [31:0] add_in1;
  logic [31:0]     sum;

 // Counter for memory addresses incremented by 4 up until in_size
  Counter_16b_RTL incr
  (
    .clk    (clk),
    .rst    (rst),
    .en     (mem_val),
    .load   (addr_counter_load),
    .start  (addr_counter_start),
    .incr   (16'd4),
    .finish (size),
    .count  (count),
    .done   (equal)
  );

  // Sign extending for signals
  assign mem_addr = {16'b0, count};
  assign size     = {7'b0, in_size, 2'b0};

  // Mux for selecting the memory read data only until counter is done
  Mux2_32b_RTL mux0
  (
    .in0 (32'b0),
    .in1 (mem_rdata),
    .sel (add_en),
    .out (add_in0)
  );

  // Register to store prev value each accumulation cycle
  Register_32b_RTL reg0
  (
    .clk (clk),
    .rst (rst),
    .en  (add_en),
    .d   (d_in),
    .q   (mux_in0)
  );

  // Mux to start the cycle with 0s when loading a new value in the counter 
  Mux2_32b_RTL mux1
  (
    .in0 (sum),
    .in1 (32'b0),
    .sel (rst_sel),
    .out (d_in)
  );

  // Mux to force register to be zero before accumulating a new message
  Mux2_32b_RTL mux2
  (
    .in0 (mux_in0),
    .in1 (32'b0),
    .sel (addr_counter_load),
    .out (add_in1)
  );
 
  // Adder to obtain the accumulated sum
  Adder_32b_GL adder
  (
    .in0 (add_in0),
    .in1 (add_in1),
    .sum (sum)
  );
  
  // the output of reg0 is the result of the adder from prev cycle
  assign result = mux_in0;

endmodule

`endif /* ACCUM_XCEL_DPATH_V */
