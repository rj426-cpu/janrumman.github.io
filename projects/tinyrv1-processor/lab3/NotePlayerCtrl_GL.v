//=======================================================================
// NotePlayerCtrl_GL
//=======================================================================

`ifndef NOTE_PLAYER_CTRL_GL_V
`define NOTE_PLAYER_CTRL_GL_V

`include "ece2300/ece2300-misc.v"
`include "lab3/DFFR_GL.v"

module NotePlayerCtrl_GL
( 
  (* keep=1 *) input  wire       clk,
  (* keep=1 *) input  wire       rst,
  (* keep=1 *) input  wire       count_done,
  (* keep=1 *) output wire       count_load,
  (* keep=1 *) output wire [1:0] state,
  (* keep=1 *) output wire       note
);
  // verilator lint_off UNUSEDPARAM
  localparam STATE_LOAD_HIGH = 2'b00;
  localparam STATE_WAIT_HIGH = 2'b01;
  localparam STATE_LOAD_LOW  = 2'b10;
  localparam STATE_WAIT_LOW  = 2'b11;
  // verilator lint_on UNUSEDPARAM

  // declaring wire and generating inverted values
  wire next_state[1:0];
  wire n_state_0;
  wire n_state_1;
  wire n_done; 

  wire a, b, c; 

  not( n_done, count_done ); 
  not( n_state_0, state[0] );
  not( n_state_1, state[1] );

  //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // Instantiating two DFFR_GL flip-flops to hold current state
  //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  DFFR_GL current_state_0
  (
    .clk (clk),
    .rst (rst),
    .d   (next_state[0]),
    .q   (state[0])
  );

  DFFR_GL current_state_1
  (
    .clk (clk),
    .rst (rst),
    .d   (next_state[1]),
    .q   (state[1])
  );

  //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // Implementing the next-state combinational logic
  //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  
  and( a, n_state_1, state[0], count_done );
  and( b, state[1], n_done );
  and( c, state[1], n_state_0 );

  or ( next_state[1], a, b, c ); 

  or ( next_state[0], n_done, n_state_0 );

  //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // Implementing the output combinational logic for count_load and note
  //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  assign note = n_state_1;
  assign count_load = n_state_0;

endmodule

`endif /* NOTE_PLAYER_CTRL_GL_V */
