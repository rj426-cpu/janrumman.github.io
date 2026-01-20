//========================================================================
// ClockDiv_RTL.v
//========================================================================
// A clock divider that divides the clock frequency based on the
// following table mapping the given divide selector to the clock
// frequency divsion factor.
//
//  divide  clock frequency
//  sel     division factor
//  -----------------------
//  0       2^(0+1)  = 2
//  1       2^(1+1)  = 4
//  2       2^(2+1)  = 8
//  3       2^(3+1)  = 16
//  -----------------------
//  4       2^(4+1)  = 32
//  5       2^(5+1)  = 64
//  6       2^(6+1)  = 128
//  7       2^(7x+1)  = 256
//  -----------------------
//  8       2^(8+1)  = 512
//  9       2^(9+1)  = 1024
//  10      2^(10+1) = 2048
//  11      2^(11+1) = 4096
//  -----------------------
//  12      2^(12+1) = 8192
//  13      2^(13+1) = 16,384
//  14      2^(14+1) = 32,768
//  15      2^(15+1) = 65,536
//
// Note the clock divider _cannot_ use a reset! This is because we are
// using synchronous reset. The output of the clock divider will be used
// as the internal clock signal; so if you use a reset signal then when
// the clock divider is in reset the clock output will be zero meaning
// that clock input to all of the registers in the design will not toggle
// meaning those registers will not be able to reset correctly.
//

`ifndef CLOCK_DIV_RTL_V
`define CLOCK_DIV_RTL_V

`include "lab3/Register_16b_RTL.v"

module ClockDiv_RTL
(
  (* keep=1 *) input  logic       clk_in,
  (* keep=1 *) input  logic [3:0] divide_sel,
  (* keep=1 *) output logic       clk_out
);

  //''' LAB ASSIGNMENT '''''''''''''''''''''''''''''''''''''''''''''''''''
  // Implement the clock divider using RTL modeling
  //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // Your implementation must be divided into three sections shown below.
  //>*''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  //:
  //: // remove these lines before starting your implementation
  //: `ECE2300_UNUSED( clk_in );
  //: `ECE2300_UNUSED( divide_sel );
  //: `ECE2300_UNDRIVEN( clk_out );
  //:

  //''' SECTION 1 ''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // Sequential Logic
  //>'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // Instantiate a Register_16b_RTL. You _must_ name your register
  // counter_reg since the provided test bench relies on this naming.
  //>*''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  logic [15:0] counter_next, counter;

  Register_16b_RTL counter_reg
  (
    .clk (clk_in),
    .rst (1'b0),
    .en  (1'b1),
    .d   (counter_next),
    .q   (counter)
  );

  //<'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  //''' SECTION 2 ''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // Combinational Logic
  //>'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // The combinational logic should either use assign statements or an
  // always_comb to increment the counter by one and also connect clk_out
  // to the appropriate bit of the counter.
  //>*''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  assign counter_next = counter + 16'b1;
  assign clk_out = counter[divide_sel];

  //<'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

endmodule

`endif /* CLOCK_DIV_RTL_V */

