//========================================================================
// NotePlayer_RTL
//========================================================================

`ifndef NOTE_PLAYER_RTL_V
`define NOTE_PLAYER_RTL_V

`include "ece2300/ece2300-misc.v"
`include "lab3/NotePlayerCtrl_RTL.v"
`include "lab3/Counter_16b_RTL.v"

module NotePlayer_RTL
(
  (* keep=1 *) input  logic       clk,
  (* keep=1 *) input  logic       rst,
  (* keep=1 *) input  logic [7:0] period,
  (* keep=1 *) output logic [1:0] state,
  (* keep=1 *) output logic       note
);

  wire d;
  wire l;
  wire [15:0] fin;
  wire [15:0] count;

  // make period a 16-bit input for our counter
  assign fin[7:0] = period;
  assign fin[15:8] = 8'b0;

  NotePlayerCtrl_RTL control
  (
    .clk        (   clk ),
    .rst        (   rst ),
    .count_done (     d ),
    .count_load (     l ),
    .state      ( state ),
    .note       (  note )
  );

  Counter_16b_RTL counter
  (
    .clk    (   clk ),
    .rst    (   rst ),
    .en     (  1'b1 ),
    .load   (     l ),
    .start  ( 16'd0 ),
    .incr   ( 16'd1 ),
    .finish (   fin ),
    .count  ( count ),
    .done   (     d )
  );

  `ECE2300_UNUSED(count);

endmodule

`endif /* NOTE_PLAYER_RTL_V */
