//========================================================================
// Counter_16b_GL
//========================================================================
// When load is high, the counter should register the start and finish
// values at the end of the cycle. If start or finish change while load
// is low, then these changes should be ignored.
//
// When enable is high, the counter increments from the registered start
// value up to the registered finish value in incr steps, checking for
// equality on each cycle. Once the finish value is reached the counter
// holds at the finish value. When enable is low, the counter holds its
// current value and should not increment.
//
// The count output should always reflect the current count (i.e., it
// should not reflect the next count).
//
// The done signal should always reflect whether or not the current count
// and the registered finish values are equal. If they are equal then the
// done signal should be high. If they are not equal then the done signal
// should be low. If start == finish, the counter immediately asserts
// done after loading, since the initial count matches finish
//
// The counter assumes the following about the inputs; behavior is
// undefined if any of these conditions is not satisfied.
//
//  - incr must not change while the counter is counting
//  - start, finish, and incr are 16-bit unsigned binary values
//  - start must be less than or equal to finish
//  - difference between finish and start must be divisible by incr

`ifndef COUNTER_16B_GL_V
`define COUNTER_16B_GL_V

`include "ece2300/ece2300-misc.v"
`include "lab2/AdderRippleCarry_16b_GL.v"
`include "lab2/Mux2_16b_GL.v"
`include "lab3/Register_16b_GL.v"
`include "lab3/EqComparator_16b_GL.v"

module Counter_16b_GL
(
  (* keep=1 *) input  wire        clk,
  (* keep=1 *) input  wire        rst,
  (* keep=1 *) input  wire        en,
  (* keep=1 *) input  wire        load,
  (* keep=1 *) input  wire [15:0] start,
  (* keep=1 *) input  wire [15:0] incr,
  (* keep=1 *) input  wire [15:0] finish,
  (* keep=1 *) output wire [15:0] count,
  (* keep=1 *) output wire        done
);

  wire cout;            // carry-out from adder (unused)
  wire [15:0] count_d;  // next value to load into count register
  wire [15:0] sum;      // output of adder (count + incr or count + 0)
  wire [15:0] finish_q; // registerd version of finish input
  wire [15:0] sum_in;   // input to adder (either incr or 0 depending on done)
  
  // reset start and finish, even when en = 0
  wire enable_reg;
  or (enable_reg, en, load); 

  // Adder: adds the current count and sum_in to produce the next sum
  // If done is high, 16'b0 is selected as sum_in so count stops increasing
  // Else, sum_in is incr.
  AdderRippleCarry_16b_GL adder 
  (
    .in0  (sum_in),
    .in1  (count),
    .cin  (1'b0),
    .cout (cout),
    .sum  (sum)
  );

  // Count register: stores the current count value.
  // Enabled only when en is high or when loading a new start value.
  // Takes in count_d, which is selected between sum and start.
  Register_16b_GL reg_count
  (
    .clk (clk),
    .rst (rst),
    .en  (enable_reg),
    .d   (count_d),
    .q   (count)
  );

  // Register for finish: captures the finish value during a load cycle.
  // Keeps finish stable while counting. This prevents external changes to 
  // the finish input from affecting the counter mid-count.
  Register_16b_GL reg_finish
  (
    .clk (clk),
    .rst (rst),
    .en  (load),
    .d   (finish),
    .q   (finish_q)
  );

  // Chooses between loading start or using the previous sum. 
  // When load = 1, that means there is a new start value, so start
  // is used. Else, keep counting by the previous sum.
  Mux2_16b_GL mux_next
  (
    .in0  (sum),
    .in1  (start),
    .sel  (load),
    .out  (count_d)
  );

  // Checks if the current count equals the registered finish
  // Sets done to high when count == finish.
  EqComparator_16b_GL comp 
  (
    .in0  (count),
    .in1  (finish_q),
    .eq   (done)
  );

  // When done=1, replace incr with 0 
  Mux2_16b_GL mux_sum
  (
    .in0  (incr),
    .in1  (16'b0),
    .sel  (done),
    .out  (sum_in)
  );

  `ECE2300_UNUSED( cout );

endmodule

`endif /* COUNTER_16B_GL_V */
