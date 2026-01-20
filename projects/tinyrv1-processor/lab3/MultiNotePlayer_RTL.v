//========================================================================
// MultiNotePlayer_RTL
//========================================================================

`ifndef MULTI_NOTE_PLAYER_RTL_V
`define MULTI_NOTE_PLAYER_RTL_V

`include "ece2300/ece2300-misc.v"
`include "lab3/Mux2_3b_RTL.v"
`include "lab3/Mux8_1b_RTL.v"
`include "lab3/Counter_16b_RTL.v"
`include "lab3/NotePlayer_RTL.v"

module MultiNotePlayer_RTL
(
  // Clock/Reset

  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Note Parameters

  (* keep=1 *) input  logic [15:0] note_duration,
  (* keep=1 *) input  logic  [7:0] note1_period,
  (* keep=1 *) input  logic  [7:0] note2_period,
  (* keep=1 *) input  logic  [7:0] note3_period,
  (* keep=1 *) input  logic  [7:0] note4_period,
  (* keep=1 *) input  logic  [7:0] note5_period,
  (* keep=1 *) input  logic  [7:0] note6_period,
  (* keep=1 *) input  logic  [7:0] note7_period,

  // Play Note Interface

  (* keep=1 *) input  logic        play_note_val,
  (* keep=1 *) output logic        play_note_rdy,
  (* keep=1 *) input  logic  [2:0] play_note_num,

  // Note Interface

  (* keep=1 *) output logic  [2:0] note_sel,
  (* keep=1 *) output logic        note
);
  // Internal Signals
  logic [15:0]         count;
  logic [1:0 ]        state1;
  logic [1:0 ]        state2;
  logic [1:0 ]        state3;
  logic [1:0 ]        state4;
  logic [1:0 ]        state5;
  logic [1:0 ]        state6;
  logic [1:0 ]        state7;
  logic [6:0 ]      note_out;
  logic [15:0]         reg_d;
  logic [15:0]         reg_q;
  logic [2:0 ]       mux_out;
  
  // Connect mux output to register, register to note_sel
  assign reg_d[2:0] = mux_out;
  assign reg_d[15:3] = 13'b0;
  assign  note_sel = reg_q[2:0];
        
  // Counter tracks note duration      
  Counter_16b_RTL counter
  (
    .clk    (clk),
    .rst    (rst),
    .en     (1'b1),
    .load   (play_note_val),
    .start  (16'd0),
    .incr   (16'd1),
    .finish (note_duration),
    .count  (count),
    .done   (play_note_rdy)
  );
  
  // Seven note players
  NotePlayer_RTL note1
  (
    .clk    (clk),
    .rst    (rst),
    .period (note1_period),
    .state  (state1),
    .note   (note_out[0])
  );

  NotePlayer_RTL note2
  (
    .clk    (clk),
    .rst    (rst),
    .period (note2_period),
    .state  (state2),
    .note   (note_out[1])   
  );

  NotePlayer_RTL note3
  (
    .clk    (clk),
    .rst    (rst),
    .period (note3_period),
    .state  (state3),
    .note   (note_out[2])   
  );

  NotePlayer_RTL note4
  (
    .clk    (clk),
    .rst    (rst),
    .period (note4_period),
    .state  (state4),
    .note   (note_out[3])    
  );

  NotePlayer_RTL note5
  (
    .clk    (clk),
    .rst    (rst),
    .period (note5_period),
    .state  (state5),
    .note   (note_out[4])  
  );


  NotePlayer_RTL note6
  (
    .clk    (clk),
    .rst    (rst),
    .period (note6_period),
    .state  (state6),
    .note   (note_out[5])   
  );


  NotePlayer_RTL note7
  (
    .clk    (clk),
    .rst    (rst),
    .period (note7_period),
    .state  (state7),
    .note   (note_out[6])
  );
 
  // Mux selects note number when val is high
  Mux2_3b_RTL mux1
  (
    .in0 (3'b0),
    .in1 (play_note_num),
    .sel (play_note_val),
    .out (mux_out)
  );
 
  // Register stores current note selection
  Register_16b_RTL reg0
  (
    .clk (clk),
    .rst (rst),
    .en  (play_note_rdy),
    .d   (reg_d),
    .q   (reg_q)  
  );

  // Mux selects which note player output to use
  Mux8_1b_RTL mux2
  (
    .in0(1'b0),
    .in1(note_out[0]),
    .in2(note_out[1]),
    .in3(note_out[2]),
    .in4(note_out[3]),
    .in5(note_out[4]),
    .in6(note_out[5]),
    .in7(note_out[6]),
    .sel(note_sel),
    .out(note)    
  );
   
   // Unused Signals
  `ECE2300_UNUSED(count );
  `ECE2300_UNUSED(state1);
  `ECE2300_UNUSED(state2);
  `ECE2300_UNUSED(state3);
  `ECE2300_UNUSED(state4);
  `ECE2300_UNUSED(state5);
  `ECE2300_UNUSED(state6);
  `ECE2300_UNUSED(state7);
  `ECE2300_UNUSED(reg_q[15:3]);

endmodule

`endif /* MULTI_NOTE_PLAYER_RTL_V */
