//========================================================================
// NotePlayer_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab3/NotePlayer_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  logic clk;
  logic test_utils_rst;

  TestUtilsClkRst t
  (
    .clk (clk),
    .rst (test_utils_rst)
  );

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic       rst;
  logic [7:0] period;
  logic [1:0] state;
  logic       note;

  NotePlayer_RTL note_player
  (
    .clk    (clk),
    .rst    (test_utils_rst | rst),
    .period (period),
    .state  (state),
    .note   (note)
  );

  //----------------------------------------------------------------------
  // Include test cases
  //----------------------------------------------------------------------

  `include "lab3/test/NotePlayer-test-cases.v"

endmodule

