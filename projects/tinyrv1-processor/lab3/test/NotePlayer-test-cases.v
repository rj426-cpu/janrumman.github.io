//========================================================================
// NotePlayer-test-cases
//========================================================================
// This file is meant to be included in a test bench.

//------------------------------------------------------------------------
// check
//------------------------------------------------------------------------
// The ECE 2300 test framework adds a 1 tau delay with respect to the
// rising clock edge at the very beginning of the test bench. So if we
// immediately set the inputs this will take effect 1 tau after the clock
// edge. Then we wait 8 tau, check the outputs, and wait 2 tau which
// means the next check will again start 1 tau after the rising clock
// edge.

localparam STATE_LOAD_HIGH = 2'b00;
localparam STATE_WAIT_HIGH = 2'b01;
localparam STATE_LOAD_LOW  = 2'b10;
localparam STATE_WAIT_LOW  = 2'b11;

string state_str;

task check
(
  input logic       rst_,
  input logic [7:0] period_,
  input logic [1:0] state_,
  input logic       note_
);
  if ( !t.failed ) begin
    t.num_checks += 1;

    rst    = rst_;
    period = period_;

    #8;

    if ( t.n != 0 ) begin

      case ( state )
        STATE_LOAD_HIGH: state_str = "LOAD_HIGH";
        STATE_WAIT_HIGH: state_str = "WAIT_HIGH";
        STATE_LOAD_LOW:  state_str = "LOAD_LOW ";
        STATE_WAIT_LOW:  state_str = "WAIT_LOW ";
        default:         state_str = "?        ";
      endcase

      $display( "%3d: %b %b > %b (%s) %b", t.cycles,
                rst, period, state, state_str, note );

    end

    `ECE2300_CHECK_EQ( state, state_ );
    `ECE2300_CHECK_EQ( note,  note_  );

    #2;

  end
endtask

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  //    rst period state  note
  check( 0, 8'd05, 2'b00, 1 ); // LOAD_HIGH
  check( 0, 8'd05, 2'b01, 1 ); // WAIT_HIGH (0)
  check( 0, 8'd05, 2'b01, 1 ); // WAIT_HIGH (1)
  check( 0, 8'd05, 2'b01, 1 ); // WAIT_HIGH (2)
  check( 0, 8'd05, 2'b01, 1 ); // WAIT_HIGH (3)
  check( 0, 8'd05, 2'b01, 1 ); // WAIT_HIGH (4)
  check( 0, 8'd05, 2'b01, 1 ); // WAIT_HIGH (5)
  check( 0, 8'd05, 2'b10, 0 ); // LOAD_LOW
  check( 0, 8'd05, 2'b11, 0 ); // WAIT_LOW (0)
  check( 0, 8'd05, 2'b11, 0 ); // WAIT_LOW (1)
  check( 0, 8'd05, 2'b11, 0 ); // WAIT_LOW (2)
  check( 0, 8'd05, 2'b11, 0 ); // WAIT_LOW (3)
  check( 0, 8'd05, 2'b11, 0 ); // WAIT_LOW (4)
  check( 0, 8'd05, 2'b11, 0 ); // WAIT_LOW (5)
  check( 0, 8'd05, 2'b00, 1 ); // LOAD_HIGH again

  t.test_case_end();
endtask

//''' LAB ASSIGNMENT '''''''''''''''''''''''''''''''''''''''''''''''''''''
// Add directed and random test cases (no xprop)
//''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
//------------------------------------------------------------------------
// Directed Test Cases
//------------------------------------------------------------------------
task test_case_2_directed_period_zero();
  t.test_case_begin( "test_case_2_directed_period_zero" );

  //    rst period state  note
  check( 0, 8'd00, 2'b00, 1 ); // LOAD_HIGH
  check( 0, 8'd00, 2'b01, 1 ); // WAIT_LOW
  
  t.test_case_end();
endtask

task test_case_3_directed_period_short();
  t.test_case_begin( "test_case_3_directed_period_short" );

  //    rst period state  note
  check( 0, 8'd01, 2'b00, 1 ); // LOAD_HIGH
  check( 0, 8'd01, 2'b01, 1 ); // WAIT_HIGH (0)
  check( 0, 8'd01, 2'b01, 1 ); // WAIT_HIGH (1)

  check( 0, 8'd01, 2'b10, 0 ); // LOAD_LOW
  check( 0, 8'd01, 2'b11, 0 ); // WAIT_LOW  (0)
  check( 0, 8'd01, 2'b11, 0 ); // WAIT_LOW  (1)

  check( 0, 8'd01, 2'b00, 1 ); // LOAD_HIGH again
  check( 0, 8'd01, 2'b01, 1 ); // WAIT_HIGH (0)
  check( 0, 8'd01, 2'b01, 1 ); // WAIT_HIGH (1)

  check( 0, 8'd01, 2'b10, 0 ); // LOAD_LOW
  check( 0, 8'd01, 2'b11, 0 ); // WAIT_LOW  (0)
  check( 0, 8'd01, 2'b11, 0 ); // WAIT_LOW  (1)

  check( 0, 8'd01, 2'b00, 1 ); // LOAD_HIGH again
  
  t.test_case_end();
endtask

task test_case_4_directed_period_long();
  t.test_case_begin( "test_case_4_directed_period_long");

  //    rst period state  note
  check( 0, 8'd50, 2'b00, 1 ); // LOAD_HIGH

  for (int i = 0; i < 51; i += 1 ) begin
    check( 0, 8'd50, 2'b01, 1); // WAIT_HIGH
  end
  
  check( 0, 8'd50, 2'b10, 0 ); // LOAD_LOW

  for (int i = 0; i < 51; i += 1 ) begin
    check( 0, 8'd50, 2'b11, 0); // WAIT_LOW
  end

  check( 0, 8'd50, 2'b00, 1 ); // LOAD_HIGH again
  
  t.test_case_end();
endtask

task test_case_5_directed_reset();
  t.test_case_begin( "test_case_5_directed_reset");

  //    rst period state  note
  check( 0, 8'd03, 2'b00, 1 ); // LOAD_HIGH
  check( 0, 8'd03, 2'b01, 1 ); // WAIT_HIGH (0)
  check( 0, 8'd03, 2'b01, 1 ); // WAIT_HIGH (1)
  check( 0, 8'd03, 2'b01, 1 ); // WAIT_HIGH (2)
  check( 0, 8'd03, 2'b01, 1 ); // WAIT_HIGH (3)

  check( 0, 8'd03, 2'b10, 0 ); // LOAD_LOW
  check( 0, 8'd03, 2'b11, 0 ); // WAIT_LOW (0)
  check( 0, 8'd03, 2'b11, 0 ); // WAIT_LOW (1)
  check( 0, 8'd03, 2'b11, 0 ); // WAIT_LOW (2)
  check( 0, 8'd03, 2'b11, 0 ); // WAIT_LOW (3)

  check( 1, 8'd04, 2'b00, 1 ); // RESET values
  check( 0, 8'd04, 2'b00, 1 ); // LOAD_HIGH
  check( 0, 8'd04, 2'b01, 1 ); // WAIT_HIGH (0)
  check( 0, 8'd04, 2'b01, 1 ); // WAIT_HIGH (1)
  check( 0, 8'd04, 2'b01, 1 ); // WAIT_HIGH (2)
  check( 0, 8'd04, 2'b01, 1 ); // WAIT_HIGH (3)
  check( 0, 8'd04, 2'b01, 1 ); // WAIT_HIGH (4)

  check( 0, 8'd04, 2'b10, 0 ); // LOAD_LOW
  check( 0, 8'd04, 2'b11, 0 ); // WAIT_LOW (0)
  check( 0, 8'd04, 2'b11, 0 ); // WAIT_LOW (1)
  check( 0, 8'd04, 2'b11, 0 ); // WAIT_LOW (2)

  check( 1, 8'd02, 2'b11, 0 ); // Reset midway
  check( 0, 8'd02, 2'b00, 1 ); // LOAD_HIGH
  check( 0, 8'd02, 2'b01, 1 ); // WAIT_HIGH (0)
  check( 0, 8'd02, 2'b01, 1 ); // WAIT_HIGH (1)

  check( 1, 8'd05, 2'b01, 1 ); // Reset midway
  check( 0, 8'd05, 2'b00, 1 ); // LOAD_HIGH
  check( 0, 8'd05, 2'b01, 1 ); // LOAD_HIGH (0)
  check( 0, 8'd05, 2'b01, 1 ); // LOAD_HIGH (1)
  check( 0, 8'd05, 2'b01, 1 ); // LOAD_HIGH (2)
  check( 0, 8'd05, 2'b01, 1 ); // LOAD_HIGH (3)
  check( 0, 8'd05, 2'b01, 1 ); // LOAD_HIGH (4)
  check( 0, 8'd05, 2'b01, 1 ); // LOAD_HIGH (5)

  check( 0, 8'd05, 2'b10, 0 ); // LOAD_LOW
  check( 0, 8'd05, 2'b11, 0 ); // WAIT_LOW (0)
  check( 0, 8'd05, 2'b11, 0 ); // WAIT_LOW (1)
  check( 0, 8'd05, 2'b11, 0 ); // WAIT_LOW (2)
  check( 0, 8'd05, 2'b11, 0 ); // WAIT_LOW (3)
  check( 0, 8'd05, 2'b11, 0 ); // WAIT_LOW (4)
  check( 0, 8'd05, 2'b11, 0 ); // WAIT_LOW (5)
  check( 0, 8'd05, 2'b00, 1 ); // LOAD_HIGH again
  
  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_6_random
//------------------------------------------------------------------------

logic [7:0]  rand_period;
int           wait_cycle;
task test_case_6_random();

  t.test_case_begin( "test_case_6_random" );

  // Generate 50 randomized test cases
  for (int i = 0; i < 50; i++) begin

    rand_period = 8'($urandom(t.seed) % 20) + 1; 
    wait_cycle = int'(rand_period) + 1;

    check( 0, rand_period, 2'b00, 1); // LOAD_HIGH

    for (int j = 0; j < wait_cycle; j += 1) begin
      check( 0, rand_period, 2'b01, 1); // WAIT_HIGH
    end

    check( 0, rand_period, 2'b10, 0); // LOAD_LOW

    for (int k = 0; k < wait_cycle; k += 1) begin
      check( 0, rand_period, 2'b11, 0); // WAIT_LOW
    end

    check( 0, rand_period, 2'b00, 1); // LOAD_HIGH again
    check( 1, rand_period, 2'b01, 1); // Reset

    end

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

initial begin
  t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1))                 test_case_1_basic();
  if ((t.n <= 0) || (t.n == 2))  test_case_2_directed_period_zero();
  if ((t.n <= 0) || (t.n == 3)) test_case_3_directed_period_short();
  if ((t.n <= 0) || (t.n == 4))  test_case_4_directed_period_long();
  if ((t.n <= 0) || (t.n == 5))        test_case_5_directed_reset();
  if ((t.n <= 0) || (t.n == 6))                test_case_6_random();


  t.test_bench_end();
end

