//=========================================================================
// Integer Multiplier Variable-Latency Implementation
//=========================================================================

`ifndef LAB1_IMUL_INT_MUL_ALT_V
`define LAB1_IMUL_INT_MUL_ALT_V

`include "vc/trace.v"
`include "vc/regs.v"
`include "vc/muxes.v"
`include "vc/arithmetic.v"
`include "lab1_imul/IntMulAltDetector.v"

//=========================================================================
// Integer Multiplier Variable-Latency Implementation
//=========================================================================

module lab1_imul_IntMulAlt
(
  input  logic        clk,
  input  logic        reset,

  input  logic        istream_val,
  output logic        istream_rdy,
  input  logic [63:0] istream_msg,

  output logic        ostream_val,
  input  logic        ostream_rdy,
  output logic [31:0] ostream_msg
);
  //----------------------------------------------------------------------
  // Datapath
  //----------------------------------------------------------------------

  // Datapath intermediate signals
  logic [31:0] a_mux_out;
  logic [31:0] b_mux_out;
  logic [31:0] result_mux_out;
  logic [31:0] add_mux_out;

  logic [31:0] a_reg_out;
  logic [31:0] b_reg_out;
  logic [31:0] result_reg_out;
  logic [31:0] adder_out;
  logic [31:0] a_shift;
  logic [31:0] b_shift;
 
// control logic 
  logic a_mux_sel;
  logic b_mux_sel;
  logic result_mux_sel;
  logic add_mux_sel;
  logic b_lsb;
  logic result_en;
  
// shift amount 
  logic [3:0] shift_amt;

// Muxes
  vc_Mux2#(32) a_mux 
  (
    .in0  (a_shift),
    .in1  (istream_msg[31:0]),
    .sel  (a_mux_sel),
    .out  (a_mux_out)
  );

  vc_Mux2#(32) b_mux 
  (
    .in0  (b_shift),
    .in1  (istream_msg[63:32]),
    .sel  (b_mux_sel),
    .out  (b_mux_out)
  );

  vc_Mux2#(32) result_mux 
  (
    .in0  (add_mux_out),
    .in1  ('0),
    .sel  (result_mux_sel),
    .out  (result_mux_out)
  );

  vc_Mux2#(32) add_mux 
  (
    .in0  (adder_out),
    .in1  (result_reg_out),
    .sel  (add_mux_sel),
    .out  (add_mux_out)
  );

  // Registers
  vc_Reg#(32) a_reg 
  (
    .clk  (clk),
    .q    (a_reg_out),
    .d    (a_mux_out)
  );

  vc_Reg#(32) b_reg 
  (
    .clk  (clk),
    .q    (b_reg_out),
    .d    (b_mux_out)
  );
  
  vc_EnReg#(32) result_reg 
  (
    .clk    (clk),
    .reset  (reset),
    .q      (result_reg_out),
    .d      (result_mux_out),
    .en     (result_en)
  );

  // ALU
  vc_SimpleAdder#(32) adder
  (
    .in0  (a_reg_out),
    .in1  (result_reg_out),
    .out  (adder_out)
  );

  // shifting unit
  lab1_imul_IntMulAltDetector shift_amt_unit
  (
    .b         (b_reg_out),
    .shift_amt (shift_amt)
  );

  assign ostream_msg = result_reg_out;
  assign a_shift = a_reg_out << shift_amt;
  assign b_shift = b_reg_out >> shift_amt;
  assign b_lsb = b_reg_out[0];

  //----------------------------------------------------------------------
  // Control Unit
  //----------------------------------------------------------------------

  // State parameters
  typedef enum logic [$clog2(3)-1:0] {
    STATE_IDLE,
    STATE_CALC,
    STATE_DONE
  } state_t;

  state_t state;
  state_t next_state;

  always_ff @( posedge clk ) begin
    if ( reset ) begin
      state <= STATE_IDLE;
    end
    else begin
      state <= next_state;
    end
  end

  // Counter
  logic [5:0] counter;
  logic [5:0] next_counter;

  always_ff @( posedge clk ) begin
    if ( reset ) begin
      counter <= 6'b0;
    end
    else begin
      counter <= next_counter;
    end
  end

  // Next state logic

  always_comb begin
    case ( state )
    
    STATE_IDLE: begin
      next_state = ( istream_val && istream_rdy )
           ? STATE_CALC
           : STATE_IDLE;
      next_counter = 6'd0;
    end
    STATE_CALC: begin
      next_counter = counter + shift_amt;
      next_state = ( next_counter >= 6'd32 )  ? STATE_DONE : STATE_CALC;
    end
    STATE_DONE: begin
      next_state = ( ostream_rdy )  ? STATE_IDLE  : STATE_DONE;
      next_counter = 6'd0;
    end

    default: begin
      next_state = state;
      next_counter = counter;
    end
    endcase
  end

  // Output logic
  always_comb begin
    case ( state )
    STATE_IDLE: begin
      a_mux_sel          = 1'b1;
      b_mux_sel          = 1'b1;
      result_mux_sel     = 1'b1;
      add_mux_sel        = 1'bx;  
      result_en          = 1'b1;
      istream_rdy        = 1'b1;
      ostream_val        = 1'b0;
    end

    STATE_CALC: begin
      a_mux_sel          = 1'b0;
      b_mux_sel          = 1'b0;
      result_mux_sel     = 1'b0;
      add_mux_sel        = ~b_lsb;
      result_en          = 1'b1;
      istream_rdy        = 1'b0;
      ostream_val        = 1'b0;
    end

    STATE_DONE: begin
      a_mux_sel          = 1'bx;
      b_mux_sel          = 1'bx;
      result_mux_sel     = 1'bx;
      add_mux_sel        = 1'bx; 
      result_en          = 1'bx; 
      istream_rdy        = 1'b0;
      ostream_val        = 1'b1;
    end

    default: begin
      a_mux_sel          = 1'b1;
      b_mux_sel          = 1'b1;
      result_mux_sel     = 1'b1;
      add_mux_sel        = 1'b0;
      result_en          = 1'b1;
      istream_rdy        = 1'b1;
      ostream_val        = 1'b0;
    end
  endcase
end
  
  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `ifndef SYNTHESIS

  logic [`VC_TRACE_NBITS-1:0] str;
  `VC_TRACE_BEGIN
  begin

    $sformat( str, "%x", istream_msg );
    vc_trace.append_val_rdy_str( trace_str, istream_val, istream_rdy, str );

    vc_trace.append_str( trace_str, "(" );
    
    // Show current FSM state as a letter
    case ( state )
      STATE_IDLE: vc_trace.append_str( trace_str, "I" );
      STATE_CALC: vc_trace.append_str( trace_str, "C" );
      STATE_DONE: vc_trace.append_str( trace_str, "D" );
      default:    vc_trace.append_str( trace_str, "?" );
    endcase

    vc_trace.append_str( trace_str, " a=" );
    $sformat( str, "%x", a_reg_out );
    vc_trace.append_str( trace_str, str );

    vc_trace.append_str( trace_str, " b=" );
    $sformat( str, "%x", b_reg_out );
    vc_trace.append_str( trace_str, str );

    vc_trace.append_str( trace_str, " r=" );
    $sformat( str, "%x", result_reg_out );
    vc_trace.append_str( trace_str, str );

    vc_trace.append_str( trace_str, ")" );

    $sformat( str, "%x", ostream_msg );
    vc_trace.append_val_rdy_str( trace_str, ostream_val, ostream_rdy, str );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

`endif /* LAB1_IMUL_INT_MUL_ALT_V */

