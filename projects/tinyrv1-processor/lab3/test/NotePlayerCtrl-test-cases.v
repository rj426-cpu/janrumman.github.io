//========================================================================
// NotePlayerCtrl-test-cases
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
  input logic       done_,
  input logic [1:0] state_,
  input logic       note_,
  input logic       load_
);
  if ( !t.failed ) begin
    t.num_checks += 1;

    done = done_;

    #8;

    if ( t.n != 0 ) begin

      case ( state )
        STATE_LOAD_HIGH: state_str = "LOAD_HIGH";
        STATE_WAIT_HIGH: state_str = "WAIT_HIGH";
        STATE_LOAD_LOW : state_str = "LOAD_LOW ";
        STATE_WAIT_LOW : state_str = "WAIT_LOW ";
        default        : state_str = "?        ";
      endcase

      $display( "%3d: %b > %b (%s) %b %b", t.cycles,
                done, state, state_str, note, load );

    end

    `ECE2300_CHECK_EQ( state, state_ );
    `ECE2300_CHECK_EQ( note,  note_  );
    `ECE2300_CHECK_EQ( load,  load_  );

    #2;

  end
endtask

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  //     done state  note  load
  check( 0,   2'b00, 1,    1 ); // LOAD_HIGH
  check( 0,   2'b01, 1,    0 ); // WAIT_HIGH
  check( 0,   2'b01, 1,    0 );
  check( 1,   2'b01, 1,    0 );
  check( 1,   2'b10, 0,    1 ); // LOAD_LOW
  check( 0,   2'b11, 0,    0 ); // WAIT_LOW
  check( 0,   2'b11, 0,    0 );
  check( 0,   2'b11, 0,    0 );
  check( 1,   2'b11, 0,    0 );
  check( 0,   2'b00, 1,    1 ); // back to LOAD_HIGH

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// Directed Test Cases
//------------------------------------------------------------------------

// Test how the FSM handles a done signal immediately after reset
// Confirm only transitions once per done pulse
task test_case_2_done_immediate();
  t.test_case_begin( "test_case_2_done_immediate" );

  //     done state  note  load
  check( 1,   2'b00, 1,    1 ); // Should transition to WAIT_HIGH
  check( 1,   2'b01, 1,    0 ); // Should transition to LOAD_LOW
  check( 1,   2'b10, 0,    1 ); // Should transition to WAIT_LOW
  check( 1,   2'b11, 0,    0 ); // Should transition back to LOAD_HIGH
  check( 1,   2'b00, 1,    1 ); // Should transition back to LOAD_HIGH

  t.test_case_end();
endtask

// Ensures it holds in WAIT_HIGH until done is asserted
task test_case_3_wait_high_hold();
  t.test_case_begin( "test_case_3_wait_high_hold" );

  //     done state  note  load
  check( 0,   2'b00, 1,    1 ); // LOAD_HIGH
  check( 0,   2'b01, 1,    0 ); // WAIT_HIGH
  check( 0,   2'b01, 1,    0 );
  check( 0,   2'b01, 1,    0 );
  check( 0,   2'b01, 1,    0 );

  t.test_case_end();
endtask

// Ensures it holds in WAIT_LOW until done is asserted
task test_case_4_wait_low_hold();
  t.test_case_begin( "test_case_4_wait_low_hold" );

  //     done state  note  load
  check( 1,   2'b00, 1,    1 ); 
  check( 1,   2'b01, 1,    0 ); // Should transition to LOAD_LOW
  check( 1,   2'b10, 0,    1 ); // Should transition to WAIT_LOW
  check( 0,   2'b11, 0,    0 ); // Hold placed as done = 0
  check( 0,   2'b11, 0,    0 );
  check( 0,   2'b11, 0,    0 );
  check( 0,   2'b11, 0,    0 );
  check( 0,   2'b11, 0,    0 );
  check( 0,   2'b11, 0,    0 );

  t.test_case_end();
endtask

// Simulate realistic delays between transitions.
task test_case_5_delayed_done();
  t.test_case_begin( "test_case_5_delayed_done" );

  //     done state  note  load
  check( 0,   2'b00, 1,    1 ); // LOAD_HIGH
  check( 0,   2'b01, 1,    0 ); // WAIT_HIGH
  check( 0,   2'b01, 1,    0 );
  check( 1,   2'b01, 1,    0 ); // Transition to LOAD_LOW
  check( 0,   2'b10, 0,    1 ); // LOAD_LOW
  check( 0,   2'b11, 0,    0 ); // WAIT_LOW
  check( 0,   2'b11, 0,    0 );
  check( 1,   2'b11, 0,    0 ); // Back to LOAD_HIGH

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_6_xprop
//------------------------------------------------------------------------

task test_case_6_xprop();
  t.test_case_begin( "test_case_6_xprop" );

  //     done state note load
  check( 'x,  2'b00,  1,   1 ); // unknown d 
  check(  1,  2'b01,  1,   0 ); // LOAD_HIGH to WAIT_HIGH doesn't depend on d
  check( 'x,  2'b10,  0,   1 ); // unknown d
  check( 'x,  2'b11,  0,   0 ); // doesn't depend on d so state is known
  check(  1,  2'bxx, 'x,  'x ); // the next state is unknown even if d is known

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_7_random
//------------------------------------------------------------------------
logic [1:0] curr_state;
logic [1:0] next_state;
logic       rand_done;
logic       expected_note;
logic       expected_load;
task test_case_7_random();

  t.test_case_begin( "test_case_7_random" );

  // First cycle: initialize known starting state
  curr_state = 2'b00; 
  rand_done = 1'($urandom(t.seed)); 

  // Generate 50 randomized test cases
  for (int i = 0; i < 50; i++) begin

    rand_done = 1'($urandom(t.seed)); 

    // Determine outputs based on current state
    if ( curr_state == 2'b00 ) begin //LOAD_HIGH
      expected_note = 1; 
      expected_load = 1;
    end

    else if ( curr_state == 2'b01 ) begin // WAIT_HIGH
      expected_note = 1; 
      expected_load = 0;
    end 

    else if ( curr_state == 2'b10 ) begin // LOAD_LOW
      expected_note = 0; 
      expected_load = 1;
    end

    else if ( curr_state == 2'b11 ) begin // WAIT_LOW
      expected_note = 0; 
      expected_load = 0;
    end 

    // Determine next state based on previous done
    if ( curr_state == 2'b00 ) begin
      next_state = 2'b01; // LOAD_HIGH always goes to WAIT_HIGH regardless of D
    end 

    else if ( curr_state == 2'b01 ) begin
      if (rand_done)
        next_state = 2'b10; // Transition to LOAD_LOW next cycle
      else
      next_state = 2'b01; // Stay in WAIT_HIGH
    end 

    else if ( curr_state == 2'b10 ) begin
      next_state = 2'b11; // LOAD_LOW always goes to WAIT_LOW regardless of D
    end 

    else if ( curr_state == 2'b11 ) begin
      if (rand_done)
        next_state = 2'b00; // Transition to LOAD_HIGH next cycle
      else
      next_state = 2'b11; // Stay in WAIT_LOW
    end 
    check( rand_done, curr_state, expected_note, expected_load ); 
    
    curr_state = next_state;

  end
  t.test_case_end();
endtask

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

initial begin
  t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1))          test_case_1_basic();
  if ((t.n <= 0) || (t.n == 2)) test_case_2_done_immediate();
  if ((t.n <= 0) || (t.n == 3)) test_case_3_wait_high_hold(); 
  if ((t.n <= 0) || (t.n == 4))  test_case_4_wait_low_hold();
  if ((t.n <= 0) || (t.n == 5))   test_case_5_delayed_done();
  if ((t.n <= 0) || (t.n == 6))          test_case_6_xprop(); 
  if ((t.n <= 0) || (t.n == 7))         test_case_7_random();

  t.test_bench_end();
end
