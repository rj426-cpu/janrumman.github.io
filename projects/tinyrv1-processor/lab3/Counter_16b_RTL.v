//========================================================================
// Counter_16b_RTL
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
//

`ifndef COUNTER_16B_RTL_V
`define COUNTER_16B_RTL_V

`include "ece2300/ece2300-misc.v"
`include "lab3/Register_16b_RTL.v"

module Counter_16b_RTL
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,
  (* keep=1 *) input  logic        en,
  (* keep=1 *) input  logic        load,
  (* keep=1 *) input  logic [15:0] start,
  (* keep=1 *) input  logic [15:0] incr,
  (* keep=1 *) input  logic [15:0] finish,
  (* keep=1 *) output logic [15:0] count,
  (* keep=1 *) output logic        done
);

  logic [15:0]  count_d;  // next value to load into count register
  logic [15:0]  finish_q; // registerd version of finish input
  logic [15:0]       sum; // sum based on increment values
  logic       enable_reg; // loads even when en = 0
  assign enable_reg = en | load; //implementation to load when en = 0 and ld =1

  //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  //  Registers
  //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
   
  // Instantiate a register for count values
  Register_16b_RTL count_reg
  (
    .clk (clk),
    .rst (rst),
    .en  (enable_reg),
    .d   (count_d),
    .q   (count)
  );

  // Instantiate a register for finish values
  Register_16b_RTL finish_reg
  (
    .clk (clk),
    .rst (rst),
    .en  (load),
    .d   (finish),
    .q   (finish_q)
  );

  //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  //  counter combinational logic 
  //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

  always_comb begin
    // Initialize default values 
    count_d = count; // the next count holds the current count
    sum     =  incr; // by default the sum is updated by incr value
    done    =     1; // done signal is high in our very first cycle

    // conditions for updates in done value
    if (count == finish_q) begin
      sum = 16'd0;
      done = 1;
    end
      else begin
        done = 0;
    end 
    
    // conditions for hold or start incrementing
    if (load == 1) begin
      count_d = start;
    end

     else if (en == 1 && done == 0) begin
      count_d = count + sum;
    end
     else begin
      count_d = count;
     end
    
  `ECE2300_XPROP( done, $isunknown(count) || $isunknown(finish_q) );
  `ECE2300_XPROP( sum, $isunknown(incr) || $isunknown(done));
  `ECE2300_XPROP( count_d, $isunknown(load) || $isunknown(en) || $isunknown(sum));

  end 

endmodule

`endif /* COUNTER_16B_RTL_V */
