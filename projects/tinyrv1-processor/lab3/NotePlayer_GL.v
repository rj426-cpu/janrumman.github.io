//========================================================================
// NotePlayer_GL
//========================================================================

`ifndef NOTE_PLAYER_GL_V
`define NOTE_PLAYER_GL_V

`include "ece2300/ece2300-misc.v"
`include "lab3/NotePlayerCtrl_GL.v"
`include "lab3/Counter_16b_GL.v"

module NotePlayer_GL
(
  (* keep=1 *) input  wire       clk,
  (* keep=1 *) input  wire       rst,
  (* keep=1 *) input  wire [7:0] period,
  (* keep=1 *) output wire [1:0] state,
  (* keep=1 *) output wire       note
);

  wire load, done;
  wire [15:0] fin, count;

  // make period a 16-bit input for our counter
  assign fin[7:0] = period;
  assign fin[15:8] = 8'b0;

  Counter_16b_GL counter 
  (
    .clk    ( clk ),
    .rst    ( rst ),
    .en     ( 1'b1 ),
    .load   ( load ), 
    .start  ( 16'b0 ),
    .incr   ( 16'b1 ),
    .finish ( fin ),
    .count  ( count ),
    .done   ( done )
  );

  NotePlayerCtrl_GL note_player_ctrl 
  (
    .clk        ( clk ),
    .rst        ( rst ), 
    .count_done ( done ),
    .count_load ( load ),
    .state      ( state ),
    .note       ( note )
  );

  `ECE2300_UNUSED(count);

endmodule

`endif /* NOTE_PLAYER_GL_V */

