//========================================================================
// Memory
//========================================================================

`ifndef MEMORY_V
`define MEMORY_V

module Memory
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  (* keep=1 *) input  logic        mem0_val,
  (* keep=1 *) output logic        mem0_wait,
  (* keep=1 *) input  logic        mem0_type,
  (* keep=1 *) input  logic [31:0] mem0_addr,
  (* keep=1 *) input  logic [31:0] mem0_wdata,
  (* keep=1 *) output logic [31:0] mem0_rdata,

  (* keep=1 *) input  logic        mem1_val,
  (* keep=1 *) output logic        mem1_wait,
  (* keep=1 *) input  logic        mem1_type,
  (* keep=1 *) input  logic [31:0] mem1_addr,
  (* keep=1 *) input  logic [31:0] mem1_wdata,
  (* keep=1 *) output logic [31:0] mem1_rdata
);

  //----------------------------------------------------------------------
  // Memory Size
  //----------------------------------------------------------------------
  // You can change the memory size here to create either a
  // mini-prototype with only 16B of physical memory or the full
  // prototype with 512B of physical memory. The memsize localparam is
  // units of 4B words so these are the two options:

  localparam mini = 4;   // mini has 4*4B = 16B physical memory
  localparam full = 128; // full has 128*4B = 512B physical memory

  // To choose the memory size simply set the memsize localparam to be
  // either "mini" or "full".

  localparam memsize = full;

  //----------------------------------------------------------------------
  // Do not make any changes below this line
  //----------------------------------------------------------------------

  logic [31:0] mem [memsize];

  // Unused address bits

  logic [31-$clog2(memsize)-2:0] mem0_addr0_unused;
  assign mem0_addr0_unused = mem0_addr[31:$clog2(memsize)+2];

  logic [1:0] mem0_addr1_unused;
  assign mem0_addr1_unused = mem0_addr[1:0];

  logic [31-$clog2(memsize)-2:0] mem1_addr0_unused;
  assign mem1_addr0_unused = mem1_addr[31:$clog2(memsize)+2];

  logic [1:0] mem1_addr1_unused;
  assign mem1_addr1_unused = mem1_addr[1:0];

  // Write port

  always_ff @(posedge clk) begin

    if ( rst ) begin

      mem[   0] <= 32'h00200093;  //00000000 addi x1, x0, 2
      mem[   1] <= 32'h00208113;  //00000004 addi x2, x1, 2
      mem[   2] <= 32'h20202823;  //00000008 sw   x2, 0x210(x0)
      mem[   3] <= 32'h0000006F;  //0000000c jal  x0, 0x00c

    end
    else begin

      if ( mem0_val && (mem0_type == 1) && (mem0_addr[31:$clog2(memsize)+2] == '0)) begin
        mem[mem0_addr[$clog2(memsize)+1:2]] <= mem0_wdata;
      end
      else if ( mem1_val && (mem1_type == 1) && (mem1_addr[31:$clog2(memsize)+2] == '0)) begin
        mem[mem1_addr[$clog2(memsize)+1:2]] <= mem1_wdata;
      end

    end

  end

  // Read port

  always_comb begin

    if ( mem0_val && (mem0_type == 0) && (mem0_addr[31:$clog2(memsize)+2] == '0))
      mem0_rdata = mem[mem0_addr[$clog2(memsize)+1:2]];
    else
      mem0_rdata = 32'bx;

    if ( mem1_val && (mem1_type == 0) && (mem1_addr[31:$clog2(memsize)+2] == '0))
      mem1_rdata = mem[mem1_addr[$clog2(memsize)+1:2]];
    else
      mem1_rdata = 32'bx;

  end

  // Wait signals are unused in the synthesized memory

  assign mem0_wait = 1'b0;
  assign mem1_wait = 1'b0;

endmodule

`endif /* MEMORY_V */
