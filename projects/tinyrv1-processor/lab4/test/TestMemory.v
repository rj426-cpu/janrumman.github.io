//========================================================================
// TestMemory
//========================================================================
// A non-synthesizable memory used for testing

`ifndef TEST_MEMORY_V
`define TEST_MEMORY_V

`include "ece2300/ece2300-misc.v"
`include "lab4/tinyrv1.v"

module TestMemory
(
  input  logic        clk,
  input  logic        rst,

  input  logic        mem0_val,
  output logic        mem0_wait,
  input  logic        mem0_type,
  input  logic [31:0] mem0_addr,
  input  logic [31:0] mem0_wdata,
  output logic [31:0] mem0_rdata,

  input  logic        mem1_val,
  output logic        mem1_wait,
  input  logic        mem1_type,
  input  logic [31:0] mem1_addr,
  input  logic [31:0] mem1_wdata,
  output logic [31:0] mem1_rdata
);

  //----------------------------------------------------------------------
  // Memory Index
  //----------------------------------------------------------------------

  logic [6:0] mem0_addr_idx;
  assign mem0_addr_idx = mem0_addr[8:2];

  `ECE2300_UNUSED( mem0_addr[31:9] );
  `ECE2300_UNUSED( mem0_addr[1:0] );

  logic [6:0] mem1_addr_idx;
  assign mem1_addr_idx = mem1_addr[8:2];

  `ECE2300_UNUSED( mem1_addr[31:9] );
  `ECE2300_UNUSED( mem1_addr[1:0] );

  //----------------------------------------------------------------------
  // Memory Array
  //----------------------------------------------------------------------

  logic [31:0] m [2**7];

  //----------------------------------------------------------------------
  // Write Ports
  //----------------------------------------------------------------------

  always_ff @( posedge clk ) begin

    if ( mem0_val && (mem0_type == 1) && (mem0_addr[31:9] == 0) )
      m[mem0_addr_idx] <= mem0_wdata;

    if ( mem1_val && (mem1_type == 1) && (mem1_addr[31:9] == 0) )
      m[mem1_addr_idx] <= mem1_wdata;

  end

  //----------------------------------------------------------------------
  // Wait
  //----------------------------------------------------------------------

  logic [31:0] random_wait_seed;
  logic        random_wait_enabled;
  logic [31:0] random_wait;

  always_ff @( posedge clk ) begin
    if ( rst ) begin
      random_wait_enabled <= 1'b0;
      random_wait_seed    <= 32'b0;
      random_wait         <= 32'b0;
      mem0_wait           <= 1'b0;
      mem1_wait           <= 1'b0;
    end
    else if ( random_wait_enabled ) begin
      mem0_wait <= ( ($urandom(random_wait_seed) % 100) < random_wait );
      mem1_wait <= ( ($urandom(random_wait_seed) % 100) < random_wait );
    end
  end

  //----------------------------------------------------------------------
  // Read Ports
  //----------------------------------------------------------------------

  always_comb begin

    if ( mem0_val && (mem0_type == 0) )
      mem0_rdata = m[mem0_addr_idx];
    else
      mem0_rdata = 'x;

    if ( mem1_val && (mem1_type == 0) )
      mem1_rdata = m[mem1_addr_idx];
    else
      mem1_rdata = 'x;

  end

  //----------------------------------------------------------------------
  // Test Interface
  //----------------------------------------------------------------------

  TinyRV1 tinyrv1();

  logic [31:0] addr_unused;

  task set_random_wait
  (
    input logic [31:0] random_wait_seed_,
    input logic [31:0] random_wait_
  );
    random_wait_enabled = 1'b1;
    random_wait_seed = random_wait_seed_;
    random_wait = random_wait_;
  endtask

  task write( input logic [31:0] addr, input logic [31:0] wdata );
    addr_unused = addr;
    m[addr[8:2]] = wdata;
  endtask

  function [31:0] read( input logic [31:0] addr );
    addr_unused = addr;
    return m[addr[8:2]];
  endfunction

  task asm( input logic [31:0] addr, input string str );
    write( addr, tinyrv1.asm( addr, str ) );
  endtask

endmodule

`endif /* TEST_MEMORY_V */
