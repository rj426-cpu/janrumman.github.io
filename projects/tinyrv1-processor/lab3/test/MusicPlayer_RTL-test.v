//========================================================================
// MusicPlayer_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"
`include "ece2300/TestReadOnlyMemory.v"

// ece2300-lint
`include "lab3/NotePlayer_RTL.v"
`include "lab3/MusicPlayer_RTL.v"

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

  logic        mem_val;
  logic [15:0] mem_addr;
  logic [31:0] mem_rdata;

  TestReadOnlyMemory mem
  (
    .mem_val   (mem_val),
    .mem_addr  (mem_addr),
    .mem_rdata (mem_rdata)
  );

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic        play_song_val;
  logic        play_song_rdy;
  logic  [4:0] play_song_num;
  logic  [2:0] note_sel;
  logic        note;
  logic  [1:0] state;

  MusicPlayer_RTL music_player
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

    .play_song_val (play_song_val),
    .play_song_rdy (play_song_rdy),
    .play_song_num (play_song_num),

    .mem_val       (mem_val),
    .mem_addr      (mem_addr),
    .mem_rdata     (mem_rdata),

    .note_sel      (note_sel),
    .note          (note),

    .state         (state)
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
  string state_str;
  string mem_str;

  localparam STATE_RESET     = 2'b00;
  localparam STATE_IDLE      = 2'b01;
  localparam STATE_PLAY_NOTE = 2'b10;
  localparam STATE_WAIT_NOTE = 2'b11;

  task check
  (
    input logic       play_song_val_,
    input logic       play_song_rdy_,
    input logic [4:0] play_song_num_,
    input logic [2:0] note_sel_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      play_song_val = play_song_val_;
      play_song_num = play_song_num_;

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

      if ( t.n != 0 ) begin

        case ( state )
          STATE_RESET:     state_str = "RESET    ";
          STATE_IDLE:      state_str = "IDLE     ";
          STATE_PLAY_NOTE: state_str = "PLAY_NOTE";
          STATE_WAIT_NOTE: state_str = "WAIT_NOTE";
          default:         state_str = "?        ";
        endcase

        if ( mem_val )
          $sformat( mem_str, "rd:%x:%x", mem_addr, mem_rdata );
        else
          mem_str = "                ";

        $display( "%3d: %b %b %b > %d (%s) %b | %s", t.cycles,
                  play_song_val, play_song_rdy, play_song_num,
                  note_sel, state_str, note, mem_str );

      end

      `ECE2300_CHECK_EQ( play_song_rdy, play_song_rdy_ );
      `ECE2300_CHECK_EQ( note_sel,      note_sel_ );
      `ECE2300_CHECK_EQ( note,          ref_note );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //        addr      data
    mem.init( 16'h0000, 32'h0000_0001 );
    mem.init( 16'h0004, 32'h0000_0002 );

    //     -play_song- note
    //     val rdy num sel
    check( 0,  0,  0,  0 ); // RESET
    check( 0,  1,  0,  0 ); // IDLE
    check( 0,  1,  0,  0 ); // IDLE
    check( 1,  1,  0,  0 ); // IDLE

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  0,  0,  1 ); // WAIT_NOTE (4)
    check( 0,  0,  0,  1 ); // WAIT_NOTE (3)
    check( 0,  0,  0,  1 ); // WAIT_NOTE (2)
    check( 0,  0,  0,  1 ); // WAIT_NOTE (1)
    check( 0,  0,  0,  1 ); // WAIT_NOTE (0)

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  0,  0,  2 ); // WAIT_NOTE (4)
    check( 0,  0,  0,  2 ); // WAIT_NOTE (3)
    check( 0,  0,  0,  2 ); // WAIT_NOTE (2)
    check( 0,  0,  0,  2 ); // WAIT_NOTE (1)
    check( 0,  0,  0,  2 ); // WAIT_NOTE (0)

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_2_song_end
  //----------------------------------------------------------------------

  task test_case_2_song_end();
    t.test_case_begin( "test_case_2_song_end" );

    //        addr      data
    mem.init( 16'h0000, 32'h0000_0003 );
    mem.init( 16'h0004, 32'h0000_0004 );
    mem.init( 16'h0008, 32'h0000_ffff );

    //     -play_song- note
    //     val rdy num sel
    check( 0,  0,  0,  0 ); // RESET
    check( 0,  1,  0,  0 ); // IDLE
    check( 0,  1,  0,  0 ); // IDLE
    check( 1,  1,  0,  0 ); // IDLE

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  0,  0,  3 ); // WAIT_NOTE (4)
    check( 0,  0,  0,  3 ); // WAIT_NOTE (3)
    check( 0,  0,  0,  3 ); // WAIT_NOTE (2)
    check( 0,  0,  0,  3 ); // WAIT_NOTE (1)
    check( 0,  0,  0,  3 ); // WAIT_NOTE (0)

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  0,  0,  4 ); // WAIT_NOTE (4)
    check( 0,  0,  0,  4 ); // WAIT_NOTE (3)
    check( 0,  0,  0,  4 ); // WAIT_NOTE (2)
    check( 0,  0,  0,  4 ); // WAIT_NOTE (1)
    check( 0,  0,  0,  4 ); // WAIT_NOTE (0)

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  1,  0,  0 ); // IDLE
    check( 0,  1,  0,  0 ); // IDLE
    check( 0,  1,  0,  0 ); // IDLE

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_two_songs
  //----------------------------------------------------------------------

  task test_case_3_two_songs();
    t.test_case_begin( "test_case_3_two_songs" );

    //        addr      data
    mem.init( 16'h0000, 32'h0000_0005 ); // start of song 0
    mem.init( 16'h0004, 32'h0000_0006 );
    mem.init( 16'h0008, 32'h0000_0007 );
    mem.init( 16'h000c, 32'h0000_ffff );
    mem.init( 16'h0200, 32'h0000_0000 ); // start of song 1
    mem.init( 16'h0204, 32'h0000_0001 );
    mem.init( 16'h0208, 32'h0000_0002 );
    mem.init( 16'h020c, 32'h0000_0003 );
    mem.init( 16'h0210, 32'h0000_0004 );
    mem.init( 16'h0214, 32'h0000_ffff );

    //     -play_song- note
    //     val rdy num sel
    check( 0,  0,  0,  0 ); // RESET
    check( 0,  1,  0,  0 ); // IDLE
    check( 0,  1,  0,  0 ); // IDLE
    check( 1,  1,  1,  0 ); // IDLE

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  0,  0,  0 ); // WAIT_NOTE (4)
    check( 0,  0,  0,  0 ); // WAIT_NOTE (3)
    check( 0,  0,  0,  0 ); // WAIT_NOTE (2)
    check( 0,  0,  0,  0 ); // WAIT_NOTE (1)
    check( 0,  0,  0,  0 ); // WAIT_NOTE (0)

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  0,  0,  1 ); // WAIT_NOTE (4)
    check( 0,  0,  0,  1 ); // WAIT_NOTE (3)
    check( 0,  0,  0,  1 ); // WAIT_NOTE (2)
    check( 0,  0,  0,  1 ); // WAIT_NOTE (1)
    check( 0,  0,  0,  1 ); // WAIT_NOTE (0)

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  0,  0,  2 ); // WAIT_NOTE (4)
    check( 0,  0,  0,  2 ); // WAIT_NOTE (3)
    check( 0,  0,  0,  2 ); // WAIT_NOTE (2)
    check( 0,  0,  0,  2 ); // WAIT_NOTE (1)
    check( 0,  0,  0,  2 ); // WAIT_NOTE (0)

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  0,  0,  3 ); // WAIT_NOTE (4)
    check( 0,  0,  0,  3 ); // WAIT_NOTE (3)
    check( 0,  0,  0,  3 ); // WAIT_NOTE (2)
    check( 0,  0,  0,  3 ); // WAIT_NOTE (1)
    check( 0,  0,  0,  3 ); // WAIT_NOTE (0)

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  0,  0,  4 ); // WAIT_NOTE (4)
    check( 0,  0,  0,  4 ); // WAIT_NOTE (3)
    check( 0,  0,  0,  4 ); // WAIT_NOTE (2)
    check( 0,  0,  0,  4 ); // WAIT_NOTE (1)
    check( 0,  0,  0,  4 ); // WAIT_NOTE (0)

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  1,  0,  0 ); // IDLE
    check( 0,  1,  0,  0 ); // IDLE
    check( 0,  1,  0,  0 ); // IDLE
    check( 1,  1,  0,  0 ); // IDLE

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  0,  0,  5 ); // WAIT_NOTE (4)
    check( 0,  0,  0,  5 ); // WAIT_NOTE (3)
    check( 0,  0,  0,  5 ); // WAIT_NOTE (2)
    check( 0,  0,  0,  5 ); // WAIT_NOTE (1)
    check( 0,  0,  0,  5 ); // WAIT_NOTE (0)

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  0,  0,  6 ); // WAIT_NOTE (4)
    check( 0,  0,  0,  6 ); // WAIT_NOTE (3)
    check( 0,  0,  0,  6 ); // WAIT_NOTE (2)
    check( 0,  0,  0,  6 ); // WAIT_NOTE (1)
    check( 0,  0,  0,  6 ); // WAIT_NOTE (0)

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  0,  0,  7 ); // WAIT_NOTE (4)
    check( 0,  0,  0,  7 ); // WAIT_NOTE (3)
    check( 0,  0,  0,  7 ); // WAIT_NOTE (2)
    check( 0,  0,  0,  7 ); // WAIT_NOTE (1)
    check( 0,  0,  0,  7 ); // WAIT_NOTE (0)

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  1,  0,  0 ); // IDLE
    check( 0,  1,  0,  0 ); // IDLE
    check( 0,  1,  0,  0 ); // IDLE
    check( 1,  1,  0,  0 ); // IDLE

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_4_val_not_rdy
  //----------------------------------------------------------------------

  task test_case_4_val_not_rdy();
    t.test_case_begin( "test_case_4_val_not_rdy" );

    //        addr      data
    mem.init( 16'h0000, 32'h0000_0001 ); // start of song 0
    mem.init( 16'h0004, 32'h0000_0002 );
    mem.init( 16'h0008, 32'h0000_ffff );
    mem.init( 16'h0400, 32'h0000_0003 ); // start of song 2
    mem.init( 16'h0404, 32'h0000_0004 );
    mem.init( 16'h0408, 32'h0000_ffff );

    //     -play_song-    note
    //     val rdy num    sel
    check( 0,  0,  0,  0 ); // RESET
    check( 0,  1,  0,  0 ); // IDLE
    check( 0,  1,  0,  0 ); // IDLE
    check( 1,  1,  0,  0 ); // IDLE

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  0,  0,  1 ); // WAIT_NOTE (4)
    check( 1,  0,  0,  1 ); // WAIT_NOTE (3)
    check( 1,  0,  0,  1 ); // WAIT_NOTE (2)
    check( 1,  0,  0,  1 ); // WAIT_NOTE (1)
    check( 0,  0,  0,  1 ); // WAIT_NOTE (0)

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 1,  0,  2,  2 ); // WAIT_NOTE (4)
    check( 0,  0,  2,  2 ); // WAIT_NOTE (3)
    check( 1,  0,  2,  2 ); // WAIT_NOTE (2)
    check( 0,  0,  2,  2 ); // WAIT_NOTE (1)
    check( 1,  0,  2,  2 ); // WAIT_NOTE (0)

    check( 1,  0,  2,  0 ); // PLAY_NOTE
    check( 1,  1,  2,  0 ); // IDLE

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  0,  0,  3 ); // WAIT_NOTE (4)
    check( 0,  0,  0,  3 ); // WAIT_NOTE (3)
    check( 0,  0,  0,  3 ); // WAIT_NOTE (2)
    check( 0,  0,  0,  3 ); // WAIT_NOTE (1)
    check( 0,  0,  0,  3 ); // WAIT_NOTE (0)

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  0,  0,  4 ); // WAIT_NOTE (4)
    check( 0,  0,  0,  4 ); // WAIT_NOTE (3)
    check( 0,  0,  0,  4 ); // WAIT_NOTE (2)
    check( 0,  0,  0,  4 ); // WAIT_NOTE (1)
    check( 0,  0,  0,  4 ); // WAIT_NOTE (0)

    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  1,  0,  0 ); // IDLE
    check( 0,  1,  0,  0 ); // IDLE
    check( 0,  1,  0,  0 ); // IDLE
    check( 1,  1,  0,  0 ); // IDLE

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_5_long_song_end
  //----------------------------------------------------------------------

  logic [15:0] long_song_end_addr;
  logic [31:0] long_song_end_data;

  task test_case_5_long_song_end();
    t.test_case_begin( "test_case_5_long_song_end" );

    // store a song with 127 notes + finish note
    for ( int i = 0; i <= 126; i = i + 1 ) begin
      long_song_end_addr = 16'(i*4);
      long_song_end_data = 32'(i%8);
      mem.init( long_song_end_addr, long_song_end_data );
    end
    mem.init( 16'd508, 32'h0000_ffff );

    //     -play_song- note
    //     val rdy num sel
    check( 0,  0,  0,  0 ); // RESET
    check( 0,  1,  0,  0 ); // IDLE
    check( 0,  1,  0,  0 ); // IDLE
    check( 1,  1,  0,  0 ); // IDLE

    for ( int i = 0; i <= 126; i = i + 1) begin
      long_song_end_data = 32'(i%8);
      //     -play_song- note
      //     val rdy num sel
      check( 0,  0,  0,  0                       ); // PLAY_NOTE
      check( 0,  0,  0,  long_song_end_data[2:0] ); // WAIT_NOTE (4)
      check( 0,  0,  0,  long_song_end_data[2:0] ); // WAIT_NOTE (3)
      check( 0,  0,  0,  long_song_end_data[2:0] ); // WAIT_NOTE (2)
      check( 0,  0,  0,  long_song_end_data[2:0] ); // WAIT_NOTE (1)
      check( 0,  0,  0,  long_song_end_data[2:0] ); // WAIT_NOTE (0)
    end

    //     -play_song- note
    //     val rdy num sel
    check( 0,  0,  0,  0 ); // PLAY_NOTE
    check( 0,  1,  0,  0 ); // IDLE
    check( 0,  1,  0,  0 ); // IDLE
    check( 0,  1,  0,  0 ); // IDLE

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_song_end();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_two_songs();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_val_not_rdy();
    if ((t.n <= 0) || (t.n == 5)) test_case_5_long_song_end();

    t.test_bench_end();
  end

endmodule
