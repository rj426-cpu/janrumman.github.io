//=========================================================================
// Base Blocking Cache Datapath
//=========================================================================

`ifndef LAB3_MEM_CACHE_BASE_DPATH_V
`define LAB3_MEM_CACHE_BASE_DPATH_V

`include "vc/regs.v"
`include "vc/muxes.v"
`include "vc/srams.v"
`include "lab3_mem/CacheWben.v"

module lab3_mem_CacheBaseDpath
#(
  parameter p_num_banks = 1
)
(
  input  logic         clk,
  input  logic         reset,

  // Processor <-> Cache Interface

  input  mem_req_4B_t   proc2cache_reqstream_msg,
  output mem_resp_4B_t  proc2cache_respstream_msg,

  // Cache <-> Memory Interface

  output mem_req_16B_t  cache2mem_reqstream_msg,
  input  mem_resp_16B_t cache2mem_respstream_msg,

  //-------------------------------------------------------------------------
  // Control -> Datapath Ports
  //-------------------------------------------------------------------------

  // Request-register enable
  input logic       cachereq_en,
  // Memory-response-register enable
  input logic       memresp_en,
  // Tag-array read/write enables
  input logic       tag_array_ren,
  input logic       tag_array_wen,
  // Data-array read/write enables
  input logic       data_array_ren,
  input logic       data_array_wen,
  // Write-data mux select
  input logic       write_data_mux_sel,
  // Write-byte-enable mux select
  input logic       wben_mux_sel,
  // Read-data/zero mux select
  input logic       read_data_zero_mux_sel,
  // Read-data-register enable
  input logic       read_data_reg_en,
  // Eviction-address-register enable
  input logic       evict_addr_reg_en,
  // Memory-request-address mux select
  input logic       memreq_addr_mux_sel,
  // Cache-response type and hit/miss value
  input logic [2:0] cacheresp_type,
  input logic       hit,
  // Memory-request type
  input logic [2:0] memreq_type,

  //-------------------------------------------------------------------------
  // Datapath -> Control Ports
  //-------------------------------------------------------------------------
  // Saved request type
  output logic [ 2:0] cachereq_type,
  // Saved request address
  output logic [31:0] cachereq_addr,
  // Tag-match result
  output logic        tag_match
);

  //=========================================================================
  // 1. Internal Signal Declarations
  //=========================================================================

  // Saved request fields
  logic   [ 7:0]  cachereq_opaque;
  logic   [31:0]  cachereq_data;

  // Address fields: tag, index, word offset
  logic   [23:0]  addr_tag;
  logic   [ 3:0]  addr_idx;
  logic   [ 3:0]  addr_offset;

  // Tag-array output
  logic   [23:0]  tag_array_read_data;

  // Data-array input/output
  logic   [127:0] data_array_write_data;
  logic   [127:0] data_array_read_data;
  logic   [ 15:0] data_array_byte_en;

  // Replicated write data and byte-enable masks
  logic   [127:0] req_data_repl;
  logic   [ 15:0] word_byte_en;

  // Saved memory response
  logic   [127:0] memresp_data;

  // Saved read/eviction data
  logic   [127:0] read_data_reg_input;
  logic   [127:0] read_data_reg_output;

  // Refill and eviction addresses
  logic   [ 31:0] refill_addr;
  logic   [ 31:0] evict_addr;
  logic   [ 31:0] evict_addr_reg_out;

  // Selected response word

  //=========================================================================
  // 2. Incoming Request Registers
  //=========================================================================

  // cachereq_opaque_reg
  vc_EnReg#(8) cachereq_opaque_reg
  (
    .clk    (clk),
    .reset  (reset),
    .q      (cachereq_opaque),
    .d      (proc2cache_reqstream_msg.opaque),  // mem-msgs.v allows for this 
    .en     (cachereq_en)
  );

  // cachereq_type_reg
  vc_EnReg#(3) cachereq_type_reg
  (
    .clk    (clk),
    .reset  (reset),
    .q      (cachereq_type),
    .d      (proc2cache_reqstream_msg.type_),  
    .en     (cachereq_en)
  );

  // achereq_addr_reg
  vc_EnReg#(32) cachereq_addr_reg
  (
    .clk    (clk),
    .reset  (reset),
    .q      (cachereq_addr),
    .d      (proc2cache_reqstream_msg.addr),  
    .en     (cachereq_en)
  );

  // Diagram: cachereq_data_reg
  vc_EnReg#(32) cachereq_data_reg
  (
    .clk    (clk),
    .reset  (reset),
    .q      (cachereq_data),
    .d      (proc2cache_reqstream_msg.data),  
    .en     (cachereq_en)
  );

  //=========================================================================
  // 3. Address Fields and Status Outputs
  //=========================================================================

  assign addr_tag = (p_num_banks == 1) ? cachereq_addr[31:8]
                  : {2'b00, cachereq_addr[31:10]};

  assign addr_idx = (p_num_banks == 1) ? cachereq_addr[7:4]
                  : cachereq_addr[9:6];

  assign addr_offset = cachereq_addr[3:0];

  //=========================================================================
  // 4. Tag Array and Tag Comparison
  //=========================================================================

  // Tag Array
  vc_CombinationalBitSRAM_1rw #(
    .p_data_nbits  (24),
    .p_num_entries (16)
  ) tag_array
  (
    .clk            (clk),
    .reset          (reset),
    .read_en        (tag_array_ren),
    .read_addr      (addr_idx),
    .read_data      (tag_array_read_data),
    .write_en       (tag_array_wen),
    .write_addr     (addr_idx),
    .write_data     (addr_tag)
  );

  // Diagram: cmp
  assign tag_match = (addr_tag == tag_array_read_data);

  //=========================================================================
  // 5. Incoming Memory-Response Register
  //=========================================================================

  // memresp_data_reg
  vc_EnReg#(128) memresp_data_reg
  (
    .clk   (clk),
    .reset (reset),
    .q     (memresp_data),
    .d     (cache2mem_respstream_msg.data),
    .en    (memresp_en)
  );

  //=========================================================================
  // 6. Data-Array Write Inputs
  //=========================================================================

  // repl
  // takes a 32b value and simply replicates it four times to create a 128b value. 
  assign req_data_repl[31:0]   = cachereq_data;
  assign req_data_repl[63:32]  = cachereq_data;
  assign req_data_repl[95:64]  = cachereq_data;
  assign req_data_repl[127:96] = cachereq_data;

  // write_data mux
  vc_Mux2#(128) write_data_mux
  (
    .in0  (req_data_repl),
    .in1  (memresp_data),
    .sel  (write_data_mux_sel),
    .out  (data_array_write_data)
  );

  // Wben Dec
  lab3_mem_CacheWben wben_decoder
  (
    .word_offset (addr_offset[3:2]),
    .byte_en     (word_byte_en)
  );

  // wben mux
  vc_Mux2#(16) wben_mux
  (
    .in0  (word_byte_en),
    .in1  (16'hffff),
    .sel  (wben_mux_sel),
    .out  (data_array_byte_en)
  );

  //=========================================================================
  // 7. Data Array
  //=========================================================================

  vc_CombinationalSRAM_1rw #(
    .p_data_nbits  (128),
    .p_num_entries (16)
  ) 
  data_array
  (
    .clk            (clk),
    .reset          (reset),
    .read_en        (data_array_ren),
    .read_addr      (addr_idx),
    .read_data      (data_array_read_data),
    .write_en       (data_array_wen),
    .write_byte_en  (data_array_byte_en),
    .write_addr     (addr_idx),
    .write_data     (data_array_write_data)
  );

  //=========================================================================
  // 8. Saved Read Data and Response Word Selection
  //=========================================================================

  // read_data_zero mux
  vc_Mux2#(128) read_data_zero_mux
  (
    .in0  (data_array_read_data),
    .in1  (128'b0),  // for a write/init response
    .sel  (read_data_zero_mux_sel),
    .out  (read_data_reg_input) 
  );

  // read_data_reg
  vc_EnReg#(128) read_data_reg
  (
    .clk    (clk),
    .reset  (reset),
    .q      (read_data_reg_output),
    .d      (read_data_reg_input), 
    .en     (read_data_reg_en)
  );

  // Diagram: four-input word mux
  vc_Mux4#(32) word_mux
  (
    .in0 (read_data_reg_output[31:0]),
    .in1 (read_data_reg_output[63:32]),
    .in2 (read_data_reg_output[95:64]),
    .in3 (read_data_reg_output[127:96]),
    .sel (addr_offset[3:2]),
    .out (proc2cache_respstream_msg.data)
  );

  //=========================================================================
  // 9. Memory-Request Address Path
  //=========================================================================

  // refill mkaddr
  // start address of the requested line
  assign refill_addr = {cachereq_addr[31:4], 4'b0000};

  // eviction mkaddr
  // start address of the old cached line
  assign evict_addr = (p_num_banks == 1) ? {tag_array_read_data, addr_idx, 4'b0000}
                  : {tag_array_read_data[21:0], addr_idx, cachereq_addr[5:4], 4'b0000};

  // evict_addr_reg
  vc_EnReg#(32) evict_addr_reg
  (
    .clk    (clk),
    .reset  (reset),
    .q      (evict_addr_reg_out),
    .d      (evict_addr), 
    .en     (evict_addr_reg_en)
  );

  // memreq_addr mux
  vc_Mux2#(32) memreq_addr_mux
  (
    .in0  (evict_addr_reg_out),
    .in1  (refill_addr), 
    .sel  (memreq_addr_mux_sel),
    .out  (cache2mem_reqstream_msg.addr) 
  );

  //=========================================================================
  // 10. Outgoing Message Assembly
  //=========================================================================

  // cacheresp_msg block
  assign proc2cache_respstream_msg.opaque = cachereq_opaque;
  assign proc2cache_respstream_msg.type_  = cacheresp_type;
  assign proc2cache_respstream_msg.len    = 2'b0;
  assign proc2cache_respstream_msg.test   = {1'b0, hit};
  // no need to assign data as it was taken from the word_mux

  // memreq_msg block
  assign cache2mem_reqstream_msg.opaque   = 8'b0;
  assign cache2mem_reqstream_msg.type_    = memreq_type;
  assign cache2mem_reqstream_msg.len      = 4'b0;
  // no need to assign data as it was taken from the memreq_addr_mux
  assign cache2mem_reqstream_msg.data     = read_data_reg_output;

endmodule

`endif