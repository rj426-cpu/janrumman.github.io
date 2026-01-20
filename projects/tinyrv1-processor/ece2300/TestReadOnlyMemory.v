//========================================================================
// TestReadOnlyMemory
//========================================================================
// A non-synthesizable read-only memory used for testing.

`ifndef TEST_READ_ONLY_MEMORY_V
`define TEST_READ_ONLY_MEMORY_V

`include "ece2300/ece2300-misc.v"

module TestReadOnlyMemory
(
  input  logic        mem_val,
  input  logic [15:0] mem_addr,
  output logic [31:0] mem_rdata
);

  // Memory size in words

  localparam MEM_SIZE = 4096;

  // Calculate address index

  logic [$clog2(MEM_SIZE)-1:0] mem_addr_idx;
  assign mem_addr_idx = mem_addr[$clog2(MEM_SIZE)+1:2];

  // Memory array

  logic [31:0] m [MEM_SIZE];

  // Read port

  always_comb begin

    if ( mem_val )
      mem_rdata = m[mem_addr_idx];
    else
      mem_rdata = 'x;

  end

  // Unused address bits

  `ECE2300_UNUSED( mem_addr );

  // Test interface

  logic [15:0] addr_unused;

  task init( input logic [15:0] addr, input logic [31:0] wdata );
    addr_unused = addr;
    m[addr[$clog2(MEM_SIZE)+1:2]] = wdata;
  endtask

  function [31:0] read( input logic [15:0] addr );
    addr_unused = addr;
    return m[addr[$clog2(MEM_SIZE)+1:2]];
  endfunction

endmodule

`endif /* TEST_READ_ONLY_MEMORY_V */
