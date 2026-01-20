//========================================================================
// NotePlayerCtrl_GL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab3/NotePlayerCtrl_GL.v"

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

  logic [1:0] state;
  logic       note;
  logic       load;
  logic       done;

  NotePlayerCtrl_GL ctrl
  (
    .clk        (clk),
    .rst        (rst),
    .count_done (done),
    .count_load (load),
    .state      (state),
    .note       (note)
  );

  //----------------------------------------------------------------------
  // Include test cases
  //----------------------------------------------------------------------

  `include "lab3/test/NotePlayerCtrl-test-cases.v"

endmodule
