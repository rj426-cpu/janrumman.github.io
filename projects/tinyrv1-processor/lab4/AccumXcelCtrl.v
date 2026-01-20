//========================================================================
// AccumXcelCtrl
//========================================================================

`ifndef ACCUM_XCEL_CTRL_V
`define ACCUM_XCEL_CTRL_V

`include "lab4/Register_32b_RTL.v"

module AccumXcelCtrl
( 
  // Clock and Reset
  (* keep=1 *) input  logic          clk,
  (* keep=1 *) input  logic          rst,

  // Valid/Rdy interface
  (* keep=1 *) output  logic         in_rdy,
  (* keep=1 *) input   logic         in_val,

  // Memory Interface
  (* keep=1 *) output  logic         mem_val,
  (* keep=1 *) output  logic         mem_type,

  // Control Signals (ctrl -> dpath)
  (* keep=1 *) output  logic        addr_counter_load,
  (* keep=1 *) output  logic [15:0] addr_counter_start,
  (* keep=1 *) output  logic        add_en,
  (* keep=1 *) output  logic        rst_sel,

  // Status Signals (dpath -> ctrl)
  (* keep=1 *) input   logic         equal,

  // Testing Interface
  (* keep=1 *) output  logic         state
  
);

// State parameters
localparam STATE_IDLE  = 1'b0;
localparam STATE_FETCH = 1'b1;

// Internal logic
logic [31:0]      reg_q;
logic [31:0]      reg_d;
logic        next_state;

assign state    = reg_q[0];
assign reg_d    = {31'b0, next_state};
assign mem_type = 1'b0;

// Register to store state
Register_32b_RTL reg0
(
  .clk    (clk),
  .rst    (rst),
  .en     (1'b1),
  .d      (reg_d),
  .q      (reg_q)
);

// Next state logic
always_comb begin
  case(state)
  
  STATE_IDLE:  next_state = (in_val) ? STATE_FETCH : STATE_IDLE;
  STATE_FETCH: next_state = (equal)  ? STATE_IDLE  : STATE_FETCH;
  default: next_state = 'x;

  endcase
end

// Output logic
always_comb begin
  case (state)
  STATE_IDLE: begin
    in_rdy            = 1'b1;
    addr_counter_load = 1'b1;
    add_en            = in_val;
    mem_val           = 1'b0;
    rst_sel           = 1'b1;
  end

  STATE_FETCH: begin
    in_rdy            = 1'b0;
    addr_counter_load = 1'b0;
    add_en            = (!equal);
    mem_val           = 1'b1;
    rst_sel           = 1'b0; 
  end

  default: begin
    in_rdy            = 'x;
    addr_counter_load = 'x;
    mem_val           = 'x;
    add_en            = 'x;
    rst_sel           = 'x;
  end
  endcase
end

// start the counter from zeros
assign addr_counter_start = 16'b0;

`ECE2300_UNUSED(reg_q[31:1]);

endmodule

`endif /* ACCUM_XCEL_CTRL_V */

