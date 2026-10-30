//=========================================================================
// Alt Blocking Cache Control
//=========================================================================

`ifndef LAB3_MEM_CACHE_ALT_CTRL_V
`define LAB3_MEM_CACHE_ALT_CTRL_V

`include "vc/mem-msgs.v"
`include "vc/regfiles.v"
`include "vc/counters.v"

module lab3_mem_CacheAltCtrl
#(
  parameter p_num_banks = 1
)
(
  input  logic        clk,
  input  logic        reset,

  // Processor <-> Cache Interface

  input  logic        proc2cache_reqstream_val,
  output logic        proc2cache_reqstream_rdy,

  output logic        proc2cache_respstream_val,
  input  logic        proc2cache_respstream_rdy,

  // Cache <-> Memory Interface

  output logic        cache2mem_reqstream_val,
  input  logic        cache2mem_reqstream_rdy,

  input  logic        cache2mem_respstream_val,
  output logic        cache2mem_respstream_rdy,

  //-------------------------------------------------------------------------
  // Datapath -> Control Ports
  //-------------------------------------------------------------------------
 
  // Saved request type
  input logic [ 2:0] cachereq_type,
  // Saved request address
  input logic [31:0] cachereq_addr,
  // Tag-match result
  input logic        tag_match_way0,
  input logic        tag_match_way1,

  //-------------------------------------------------------------------------
  // Control -> Datapath Ports
  //-------------------------------------------------------------------------

  // Request-register enable
  output logic       cachereq_en,
  // Memory-response-register enable
  output logic       memresp_en,
  // Tag-array read/write enables
  output logic       tag_array_ren,
  output logic       tag_array_wen,
  // Data-array read/write enables
  output logic       data_array_ren,
  output logic       data_array_wen,
  // Write-data mux select
  output logic       write_data_mux_sel,
  // Write-byte-enable mux select
  output logic       wben_mux_sel,
  // Read-data/zero mux select
  output logic       read_data_zero_mux_sel,
  // Read-data-register enable
  output logic       read_data_reg_en,
  // Eviction-address-register enable
  output logic       evict_addr_reg_en,
  // Memory-request-address mux select
  output logic       memreq_addr_mux_sel,
  // Cache-response type and hit/miss value
  output logic [2:0] cacheresp_type,
  output logic       hit,

  // Memory-request type
  output logic [2:0] memreq_type,
  // Way Select
  output logic       way_sel,

  //----------------------------------------------------------------------
  // Counter Checks
  //----------------------------------------------------------------------
 
  output logic [31:0] total_accesses,
  output logic [31:0] cache_hits,
  output logic [31:0] cache_misses,
  output logic [31:0] dirty_evictions
);

  //----------------------------------------------------------------------
  // State Definitions
  //----------------------------------------------------------------------

  localparam STATE_IDLE              = 5'd0;
  localparam STATE_TAG_CHECK         = 5'd1;
  localparam STATE_INIT_DATA_ACCESS  = 5'd2;
  localparam STATE_READ_DATA_ACCESS  = 5'd3;
  localparam STATE_WRITE_DATA_ACCESS = 5'd4;
  localparam STATE_REFILL_REQUEST    = 5'd5;
  localparam STATE_REFILL_WAIT       = 5'd6;
  localparam STATE_REFILL_UPDATE     = 5'd7;
  localparam STATE_EVICT_PREPARE     = 5'd8;
  localparam STATE_EVICT_REQUEST     = 5'd9;
  localparam STATE_EVICT_WAIT        = 5'd10;
  localparam STATE_WAIT              = 5'd11;

  //----------------------------------------------------------------------
  // FSM State Registers
  //----------------------------------------------------------------------

  logic [4:0] state;
  logic [4:0] next_state;

  always_ff @(posedge clk) begin
    if (reset)
    state <= STATE_IDLE;
    else
    state <= next_state;
  end

  //----------------------------------------------------------------------
  // Valid and Dirty regfiles
  //----------------------------------------------------------------------

  logic [2:0] index;
  assign index = (p_num_banks == 1) ? cachereq_addr[6:4] : cachereq_addr[8:6];

  logic valid_bits_way0;
  logic valid_bits_way1;
  logic dirty_bits_way0;
  logic dirty_bits_way1;

  logic valid_write_en;
  logic valid_write_data;

  logic dirty_write_en;
  logic dirty_write_data;

  // Valid bit register file
  // way 0
  vc_ResetRegfile_1r1w
  #(
    .p_data_nbits  (1),
    .p_num_entries (8),
    .p_reset_value (0)
  )
  valid_bits_way0_reg
  (
    .clk        (clk),
    .reset      (reset),
    .read_addr  (index),
    .read_data  (valid_bits_way0),
    .write_en   (valid_write_en && !way_sel),
    .write_addr (index),
    .write_data (valid_write_data)
  );

  // way 1
  vc_ResetRegfile_1r1w
  #(
    .p_data_nbits  (1),
    .p_num_entries (8),
    .p_reset_value (0)
  )
  valid_bits_way1_reg
  (
    .clk        (clk),
    .reset      (reset),
    .read_addr  (index),
    .read_data  (valid_bits_way1),
    .write_en   (valid_write_en && way_sel),
    .write_addr (index),
    .write_data (valid_write_data)
  );

  // Dirty bit register file
  // way 0
  vc_ResetRegfile_1r1w
  #(
    .p_data_nbits  (1),
    .p_num_entries (8),
    .p_reset_value (0)
  )
  dirty_bits_way0_reg
  (
    .clk        (clk),
    .reset      (reset),
    .read_addr  (index),
    .read_data  (dirty_bits_way0),
    .write_en   (dirty_write_en && !way_sel),
    .write_addr (index),
    .write_data (dirty_write_data)
  );
  
  // way 1
  vc_ResetRegfile_1r1w
  #(
    .p_data_nbits  (1),
    .p_num_entries (8),
    .p_reset_value (0)
  )
  dirty_bits_way1_reg
  (
    .clk        (clk),
    .reset      (reset),
    .read_addr  (index),
    .read_data  (dirty_bits_way1),
    .write_en   (dirty_write_en && way_sel),
    .write_addr (index),
    .write_data (dirty_write_data)
  );

  // Register file write controls

  always_comb begin
    case (state)

      STATE_WRITE_DATA_ACCESS: begin
        valid_write_en   = 1'b1;
        dirty_write_en   = 1'b1;
        valid_write_data = 1'b1;
        dirty_write_data = 1'b1;
      end

      STATE_INIT_DATA_ACCESS: begin
        valid_write_en   = 1'b1;
        dirty_write_en   = 1'b1;
        valid_write_data = 1'b1;
        dirty_write_data = 1'b0;
      end

      STATE_REFILL_UPDATE: begin
        valid_write_en   = 1'b1;
        dirty_write_en   = 1'b1;
        valid_write_data = 1'b1;
        dirty_write_data = 1'b0;        
      end

      default: begin
        valid_write_en   = 1'b0;
        dirty_write_en   = 1'b0;
        valid_write_data = 1'b1;
        dirty_write_data = 1'b0;
      end
    endcase
  end

  //----------------------------------------------------------------------
  // Two Way Hit
  //----------------------------------------------------------------------
  logic hit_way0;
  logic hit_way1;
  logic cache_hit;

  assign hit_way0 = valid_bits_way0 && tag_match_way0;
  assign hit_way1 = valid_bits_way1 && tag_match_way1;

  assign cache_hit = hit_way0 || hit_way1;

  //----------------------------------------------------------------------
  // LRU & Way Selection
  //----------------------------------------------------------------------
  logic [7:0] lru_bits;

  logic sel_way;
  logic sel_valid;
  logic sel_dirty;

  always_comb begin
    if (hit_way0)
    sel_way = 1'b0;
    else if (hit_way1)
    sel_way = 1'b1;
    else if (!valid_bits_way0)
    sel_way = 1'b0;
    else if (!valid_bits_way1)
    sel_way = 1'b1;
    else
    sel_way = lru_bits[index];
  end

  assign sel_valid = sel_way ? valid_bits_way1 : valid_bits_way0;
  assign sel_dirty = sel_way ? dirty_bits_way1 : dirty_bits_way0;

  //----------------------------------------------------------------------
  // FSM Transition Logic
  //----------------------------------------------------------------------

  always_comb begin
    next_state = state;
    
    case (state)

    STATE_IDLE: begin
      next_state = (!(proc2cache_reqstream_val && proc2cache_reqstream_rdy)) ? 
      STATE_IDLE : STATE_TAG_CHECK;
    end

    STATE_TAG_CHECK: begin
      if (cachereq_type == 3'd0 && cache_hit) begin
        next_state = STATE_READ_DATA_ACCESS;
      end
      else if (cachereq_type == 3'd1 && cache_hit) begin
        next_state = STATE_WRITE_DATA_ACCESS;
      end
      else if (cachereq_type == 3'd2) begin
        next_state = STATE_INIT_DATA_ACCESS;
      end
      else if (sel_valid && sel_dirty) begin
        next_state = STATE_EVICT_PREPARE;
      end
      else  begin
        next_state = STATE_REFILL_REQUEST;
      end
    end

    STATE_INIT_DATA_ACCESS: begin
      next_state = STATE_WAIT;
    end

    STATE_READ_DATA_ACCESS: begin
      next_state = STATE_WAIT;
    end

    STATE_WRITE_DATA_ACCESS: begin
      next_state = STATE_WAIT;
    end

    STATE_EVICT_PREPARE: begin
      next_state = STATE_EVICT_REQUEST;
    end 

    STATE_EVICT_REQUEST: begin
      next_state = (!cache2mem_reqstream_rdy) ? 
      STATE_EVICT_REQUEST : STATE_EVICT_WAIT;
    end 

    STATE_EVICT_WAIT: begin
      next_state = (!cache2mem_respstream_val) ? 
      STATE_EVICT_WAIT : STATE_REFILL_REQUEST;  
    end  

    STATE_REFILL_REQUEST: begin
      next_state = (!cache2mem_reqstream_rdy) ? 
      STATE_REFILL_REQUEST : STATE_REFILL_WAIT;
    end  

    STATE_REFILL_WAIT: begin
      next_state = (!(cache2mem_respstream_val && cache2mem_respstream_rdy)) ? 
      STATE_REFILL_WAIT : STATE_REFILL_UPDATE;
    end  

    STATE_REFILL_UPDATE: begin
      if (cachereq_type == 3'd0) begin
        next_state = STATE_READ_DATA_ACCESS;
      end
      else if (cachereq_type == 3'd1) begin
        next_state = STATE_WRITE_DATA_ACCESS;
      end
    end  

    STATE_WAIT: begin
      next_state = (!proc2cache_respstream_rdy) ? STATE_WAIT : STATE_IDLE;
    end 

    default: begin
    end  
    endcase
  end

  //----------------------------------------------------------------------
  // Selected Way Register
  //----------------------------------------------------------------------

  logic sel_way_reg;
  
  always_ff @(posedge clk) begin
    if (reset)
    sel_way_reg <= 1'b0;
    else if (state == STATE_TAG_CHECK)
    sel_way_reg <= sel_way;
  end

  assign way_sel = (state == STATE_TAG_CHECK) ? sel_way : sel_way_reg;

  //----------------------------------------------------------------------
  // LRU update logic
  //----------------------------------------------------------------------

  always_ff @(posedge clk) begin
    if (reset) begin
      lru_bits <= 8'b0;
    end
    else if (state == STATE_TAG_CHECK && cache_hit && cachereq_type != 3'd2) begin
      lru_bits[index] <= !sel_way;
    end
    else if (state == STATE_REFILL_UPDATE || state == STATE_INIT_DATA_ACCESS) begin
      lru_bits[index] <= !sel_way_reg;
    end
  end

  //----------------------------------------------------------------------
  // Cache Monitoring
  //----------------------------------------------------------------------
  // Counter for total_access
  vc_BasicCounter #(
    .p_count_nbits       (32),
    .p_count_clear_value (0),
    .p_count_max_value   (32'hFFFFFFFF)
  ) total_accesses_counter (
    .clk           (clk),
    .reset         (reset),
    .clear         (1'b0),
    .increment     (proc2cache_reqstream_val &&
                    proc2cache_reqstream_rdy),
    .decrement     (1'b0),
    .count         (total_accesses),
    .count_is_zero (),
    .count_is_max  ()
  );

  // Counter for cache hits
  vc_BasicCounter #(
    .p_count_nbits       (32),
    .p_count_clear_value (0),
    .p_count_max_value   (32'hFFFFFFFF)
  ) cache_hits_counter (
    .clk           (clk),
    .reset         (reset),
    .clear         (1'b0),
    .increment     (state == STATE_TAG_CHECK && 
                    cache_hit && 
                    cachereq_type != 3'd2),
    .decrement     (1'b0),
    .count         (cache_hits),
    .count_is_zero (),
    .count_is_max  ()
  );

  // Counter for cache misses
  vc_BasicCounter #(
    .p_count_nbits       (32),
    .p_count_clear_value (0),
    .p_count_max_value   (32'hFFFFFFFF)
  ) cache_misses_counter (
    .clk           (clk),
    .reset         (reset),
    .clear         (1'b0),
    .increment     (state == STATE_TAG_CHECK && 
                    !cache_hit && 
                    cachereq_type != 3'd2),
    .decrement     (1'b0),
    .count         (cache_misses),
    .count_is_zero (),
    .count_is_max  ()
  );

  // Counter for dirty evictions
  vc_BasicCounter #(
    .p_count_nbits       (32),
    .p_count_clear_value (0),
    .p_count_max_value   (32'hFFFFFFFF)
  ) dirty_evictions_counter (
    .clk           (clk),
    .reset         (reset),
    .clear         (1'b0),
    .increment     (state == STATE_EVICT_PREPARE),
    .decrement     (1'b0),
    .count         (dirty_evictions),
    .count_is_zero (),
    .count_is_max  ()
  );

  //----------------------------------------------------------------------
  // Output Logic
  //----------------------------------------------------------------------

  always_comb begin
      
      // default signals
      cachereq_en            = 1'b0;
      memresp_en             = 1'b0;
      tag_array_ren          = 1'b0;
      tag_array_wen          = 1'b0;
      data_array_ren         = 1'b0;
      data_array_wen         = 1'b0;
      write_data_mux_sel     = 1'b0;
      wben_mux_sel           = 1'b0;
      read_data_zero_mux_sel = 1'b0;
      read_data_reg_en       = 1'b0;
      evict_addr_reg_en      = 1'b0;
      memreq_addr_mux_sel    = 1'b0;
      cacheresp_type         = 3'd0;
      hit                    = 1'b0;
      memreq_type            = 3'd0;
      proc2cache_reqstream_rdy  = 1'b0;
      proc2cache_respstream_val = 1'b0;
      cache2mem_reqstream_val   = 1'b0;
      cache2mem_respstream_rdy  = 1'b0;

    case (state)
      STATE_IDLE: begin
        proc2cache_reqstream_rdy = 1'b1; 
        cachereq_en = proc2cache_reqstream_val && proc2cache_reqstream_rdy;     
      end

      STATE_TAG_CHECK: begin
        tag_array_ren = 1'b1;
      end

      STATE_INIT_DATA_ACCESS: begin
        tag_array_wen          = 1'b1;
        data_array_wen         = 1'b1;
        read_data_zero_mux_sel = 1'b1;
        read_data_reg_en       = 1'b1;
      end

      STATE_READ_DATA_ACCESS: begin
        data_array_ren         = 1'b1;
        read_data_reg_en       = 1'b1;
      end

      STATE_WRITE_DATA_ACCESS: begin
        data_array_wen         = 1'b1;
        read_data_zero_mux_sel = 1'b1;
        read_data_reg_en       = 1'b1;
      end

      STATE_EVICT_PREPARE: begin
        tag_array_ren          = 1'b1;
        data_array_ren         = 1'b1;
        read_data_reg_en       = 1'b1;
        evict_addr_reg_en      = 1'b1;
      end

      STATE_EVICT_REQUEST: begin
        memreq_type              = 3'd1;
        cache2mem_reqstream_val  = 1'b1;
      end

      STATE_EVICT_WAIT: begin
        cache2mem_respstream_rdy = 1'b1;
      end

      STATE_REFILL_REQUEST: begin
        memreq_addr_mux_sel      = 1'b1;
        cache2mem_reqstream_val  = 1'b1;
      end

      STATE_REFILL_WAIT: begin
        memresp_en = cache2mem_respstream_val;
        cache2mem_respstream_rdy = 1'b1;
      end

      STATE_REFILL_UPDATE: begin
        tag_array_wen          = 1'b1;
        data_array_wen         = 1'b1;
        write_data_mux_sel     = 1'b1;
        wben_mux_sel           = 1'b1;
      end

      STATE_WAIT: begin
        hit                       = hit_reg;
        proc2cache_respstream_val = 1'b1;
        cacheresp_type            = cachereq_type;
      end

      default: begin
      end
    endcase
  end
  logic hit_reg;

  always_ff @(posedge clk) begin
      if (reset)
          hit_reg <= 1'b0;
      else if (state == STATE_TAG_CHECK)
          hit_reg <= !(cachereq_type == 3'd2) && cache_hit;
  end

  endmodule

  `endif
