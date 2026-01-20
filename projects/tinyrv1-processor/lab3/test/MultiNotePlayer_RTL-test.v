//========================================================================
// MultiNotePlayer_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab3/MultiNotePlayer_RTL.v"
`include "lab3/NotePlayer_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  logic clk;
  logic rst;

  TestUtilsClkRst t
  (
    .clk (clk),
    .rst (rst)
  );

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic        play_note_val;
  logic        play_note_rdy;
  logic  [2:0] play_note_num;
  logic  [2:0] note_sel;
  logic        note;

  MultiNotePlayer_RTL dut
  (
    .clk           (clk),
    .rst           (rst),

    .note_duration (16'd4),
    .note1_period  (8'd1),
    .note2_period  (8'd2),
    .note3_period  (8'd3),
    .note4_period  (8'd4),
    .note5_period  (8'd5),
    .note6_period  (8'd6),
    .note7_period  (8'd7),

    .play_note_val (play_note_val),
    .play_note_rdy (play_note_rdy),
    .play_note_num (play_note_num),

    .note_sel      (note_sel),
    .note          (note)
  );

  //----------------------------------------------------------------------
  // Instantiate already tested NotePlayers for reference
  //----------------------------------------------------------------------

  // Note Player 1

  logic [1:0] ref_note1_state;
  logic       ref_note1;

  NotePlayer_RTL ref_note1_player
  (
    .clk    (clk),
    .rst    (rst),
    .period (8'd1),
    .state  (ref_note1_state),
    .note   (ref_note1)
  );

  `ECE2300_UNUSED( ref_note1_state );

  // Note Player 2

  logic [1:0] ref_note2_state;
  logic       ref_note2;

  NotePlayer_RTL ref_note2_player
  (
    .clk    (clk),
    .rst    (rst),
    .period (8'd2),
    .state  (ref_note2_state),
    .note   (ref_note2)
  );

  `ECE2300_UNUSED( ref_note2_state );

  // Note Player 3

  logic [1:0] ref_note3_state;
  logic       ref_note3;

  NotePlayer_RTL ref_note3_player
  (
    .clk    (clk),
    .rst    (rst),
    .period (8'd3),
    .state  (ref_note3_state),
    .note   (ref_note3)
  );

  `ECE2300_UNUSED( ref_note3_state );

  // Note Player 4

  logic [1:0] ref_note4_state;
  logic       ref_note4;

  NotePlayer_RTL ref_note4_player
  (
    .clk    (clk),
    .rst    (rst),
    .period (8'd4),
    .state  (ref_note4_state),
    .note   (ref_note4)
  );

  `ECE2300_UNUSED( ref_note4_state );

  // Note Player 5

  logic [1:0] ref_note5_state;
  logic       ref_note5;

  NotePlayer_RTL ref_note5_player
  (
    .clk    (clk),
    .rst    (rst),
    .period (8'd5),
    .state  (ref_note5_state),
    .note   (ref_note5)
  );

  `ECE2300_UNUSED( ref_note5_state );

  // Note Player 6

  logic [1:0] ref_note6_state;
  logic       ref_note6;

  NotePlayer_RTL ref_note6_player
  (
    .clk    (clk),
    .rst    (rst),
    .period (8'd6),
    .state  (ref_note6_state),
    .note   (ref_note6)
  );

  `ECE2300_UNUSED( ref_note6_state );

  // Note Player 7

  logic [1:0] ref_note7_state;
  logic       ref_note7;

  NotePlayer_RTL ref_note7_player
  (
    .clk    (clk),
    .rst    (rst),
    .period (8'd7),
    .state  (ref_note7_state),
    .note   (ref_note7)
  );

  `ECE2300_UNUSED( ref_note7_state );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // The ECE 2300 test framework adds a 1 tau delay with respect to the
  // rising clock edge at the very beginning of the test bench. So if we
  // immediately set the inputs this will take effect 1 tau after the
  // clock edge. Then we wait 8 tau, check the outputs, and wait 2 tau
  // which means the next check will again start 1 tau after the rising
  // clock edge.

  logic ref_note;

  task check
  (
    input logic        play_note_val_,
    input logic        play_note_rdy_,
    input logic  [2:0] play_note_num_,
    input logic  [2:0] note_sel_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      play_note_val = play_note_val_;
      play_note_num = play_note_num_;

      case ( note_sel )
        3'd0 : ref_note = 1'b0;
        3'd1 : ref_note = ref_note1;
        3'd2 : ref_note = ref_note2;
        3'd3 : ref_note = ref_note3;
        3'd4 : ref_note = ref_note4;
        3'd5 : ref_note = ref_note5;
        3'd6 : ref_note = ref_note6;
        3'd7 : ref_note = ref_note7;
        default: ref_note = 'x;
      endcase

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b %b %b > %b %b", t.cycles,
                  play_note_val, play_note_rdy, play_note_num,
                  note_sel, note );

      `ECE2300_CHECK_EQ( play_note_rdy, play_note_rdy_ );
      `ECE2300_CHECK_EQ( note_sel, note_sel_ );
      `ECE2300_CHECK_EQ( note, ref_note );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     play play play    note
    //     val  rdy  note    sel
    check( 1,   1,   3'b001, 3'd0 );
    check( 0,   0,   3'b000, 3'd1 );
    check( 0,   0,   3'b000, 3'd1 );
    check( 0,   0,   3'b000, 3'd1 );
    check( 0,   0,   3'b000, 3'd1 );
    check( 0,   1,   3'b000, 3'd1 );
    check( 0,   1,   3'b000, 3'd0 );
    check( 0,   1,   3'b000, 3'd0 );
    check( 0,   1,   3'b000, 3'd0 );

    t.test_case_end();
  endtask

  //''' LAB ASSIGNMENT '''''''''''''''''''''''''''''''''''''''''''''''''''
  // Add directed and xprop test cases
  //>'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  //----------------------------------------------------------------------
  // test_case_2_directed
  //----------------------------------------------------------------------

  task test_case_2_directed();
    t.test_case_begin( "test_case_2_directed" );

    //     play play play    note
    //     val  rdy  note    sel
    check( 0,   1,   3'b000, 3'd0 );
    check( 0,   1,   3'b000, 3'd0 );
    check( 0,   1,   3'b000, 3'd0 );
    check( 1,   1,   3'b111, 3'd0 );
    check( 0,   0,   3'b000, 3'd7 );
    check( 0,   0,   3'b000, 3'd7 );
    check( 0,   0,   3'b000, 3'd7 );
    check( 0,   0,   3'b000, 3'd7 );
    check( 0,   1,   3'b000, 3'd7 );
    check( 0,   1,   3'b000, 3'd0 );

    t.test_case_end();
  endtask

  task test_case_3_xprop();
    t.test_case_begin( "test_case_3_xprop" );

    //     play play play note
    //     val  rdy  note sel
    check( 'x,  1,   'x,  3'd0 );
    check( 'x,  'x,  'x,  'x   );
    check( 'x,  'x,  'x,  'x   );

    t.test_case_end();
  endtask

  //<'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();

    //''' LAB ASSIGNMENT '''''''''''''''''''''''''''''''''''''''''''''''''
    // Add calls to new test cases here
    //>'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

    if ((t.n <= 0) || (t.n == 2)) test_case_2_directed();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_xprop();

    //<'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

    t.test_bench_end();
  end

endmodule
