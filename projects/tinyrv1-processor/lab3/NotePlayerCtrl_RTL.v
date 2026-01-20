//=======================================================================
// NotePlayerCtrl_RTL
//=======================================================================

`ifndef NOTE_PLAYER_CTRL_RTL_V
`define NOTE_PLAYER_CTRL_RTL_V

`include "ece2300/ece2300-misc.v"
`include "lab3/DFFR_RTL.v"

module NotePlayerCtrl_RTL
(
  (* keep=1 *) input  logic       clk,
  (* keep=1 *) input  logic       rst,
  (* keep=1 *) input  logic       count_done,
  (* keep=1 *) output logic       count_load,
  (* keep=1 *) output logic [1:0] state,
  (* keep=1 *) output logic       note
);

  // verilator lint_off UNUSEDPARAM
  localparam STATE_LOAD_HIGH = 2'b00;
  localparam STATE_WAIT_HIGH = 2'b01;
  localparam STATE_LOAD_LOW  = 2'b10;
  localparam STATE_WAIT_LOW  = 2'b11;
  // verilator lint_on UNUSEDPARAM

  // Sequential: State Register
  logic [1:0] state_next;

  DFFR_RTL reg0
  (
    .clk ( clk ),
    .rst ( rst ),
    .d   ( state_next[0] ),
    .q   ( state[0] )
  );
  DFFR_RTL reg1
  (
    .clk ( clk ),
    .rst ( rst ),
    .d   ( state_next[1] ),
    .q   ( state[1] )
  );

  // Combination: next state logic
  // When LOAD_HIGH, go to WAIT_HIGH regardless of count_done
  // When WAIT_HIGH, go to LOAD_LOW when done, and stay if not done
  // When LOAD_LOW, go to WAIT_LOW regardless of count_done
  // When WAIT_LOW, go to LOAD_HIGH when done, and stay if not done
  always_comb begin
    case (state)
      STATE_LOAD_HIGH: state_next = STATE_WAIT_HIGH;
      STATE_WAIT_HIGH: state_next = ( count_done ) ? STATE_LOAD_LOW : STATE_WAIT_HIGH;
      STATE_LOAD_LOW: state_next = STATE_WAIT_LOW;
      STATE_WAIT_LOW: state_next = ( count_done ) ? STATE_LOAD_HIGH : STATE_WAIT_LOW;
      default: state_next = 'x;
    endcase
  end

  // Combinational: output logic
  always_comb begin
    case (state)
      STATE_LOAD_HIGH: begin count_load = 1; note = 1; end 
      STATE_WAIT_HIGH: begin count_load = 0; note = 1; end 
      STATE_LOAD_LOW:  begin count_load = 1; note = 0; end 
      STATE_WAIT_LOW:  begin count_load = 0; note = 0; end 
      default: begin count_load = 'x; note = 'x; end
    endcase
  end 

endmodule

`endif /* NOTE_PLAYER_CTRL_RTL_V */
