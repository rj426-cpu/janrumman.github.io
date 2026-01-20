//========================================================================
// Counter_16b_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab3/Counter_16b_RTL.v"

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

  logic        en;
  logic        load;
  logic [15:0] start;
  logic [15:0] incr;
  logic [15:0] finish;
  logic [15:0] count;
  logic        done;

  Counter_16b_RTL counter
  (
    .clk    (clk),
    .rst    (rst),
    .en     (en),
    .load   (load),
    .start  (start),
    .incr   (incr),
    .finish (finish),
    .count  (count),
    .done   (done)
  );

  //----------------------------------------------------------------------
  // Include test cases
  //----------------------------------------------------------------------

  `include "lab3/test/Counter_16b-test-cases.v"

endmodule
