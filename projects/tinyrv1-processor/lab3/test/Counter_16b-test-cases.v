//=======================================================================
// Counter_16b Test Cases
//=======================================================================
// This file is meant to be included in a testbench.

//------------------------------------------------------------------------
// check
//------------------------------------------------------------------------
// The ECE 2300 test framework adds a 1 tau delay with respect to the
// rising clock edge at the very beginning of the test bench. So if we
// immediately set the inputs this will take effect 1 tau after the clock
// edge. Then we wait 8 tau, check the outputs, and wait 2 tau which
// means the next check will again start 1 tau after the rising clock
// edge.

task check
(
  input logic        en_,
  input logic        load_,
  input logic [15:0] start_,
  input logic [15:0] incr_,
  input logic [15:0] finish_,
  input logic [15:0] count_,
  input logic        done_,
  input logic        ignore_done = 0
);
  if ( !t.failed ) begin
    t.num_checks += 1;

    en     = en_;
    load   = load_;
    start  = start_;
    incr   = incr_;
    finish = finish_;

    #8

    if ( t.n != 0 )
      $display( "%3d: %b %b (%4h, +%4h -> %4h) > %4h %b", t.cycles,
                en, load, start, incr, finish, count, done );

    `ECE2300_CHECK_EQ( count, count_ );

    if ( !ignore_done )
      `ECE2300_CHECK_EQ( done, done_ );

    #2;

  end
endtask

//-----------------------------------------------------------------------
// test_case_1_basic_v1
//-----------------------------------------------------------------------
// This basic test case should pass even for an incomplete counter where
// the counter is reset to zero and then simply counts up forever. This
// incomplete counter can ignore the start, finish, load, and en inputs
// and leave the done output undriven. The test case makes sure that
// after we reset the counter it counts up from 0 to 4. This test should
// also pass for a complete counter.

task test_case_1_basic_v1();
  t.test_case_begin( "test_case_1_basic_v1" );

  //     en ld start   incr    finish  count   done ignore_done?
  check( 1, 1, 16'd01, 16'd01, 16'd99, 16'd00, 'x,  1 );

  for( int i = 1; i < 5; i = i+1 )
    check( 1, 0, 16'd01, 16'd01, 16'd99, 16'(i), 'x, 1 );

  t.test_case_end();
endtask

//-----------------------------------------------------------------------
// test_case_2_basic_v2
//-----------------------------------------------------------------------
// This basic test case should pass even for an incomplete counter which
// supports loading in a new start value but ignores the finish and en
// inputs and leaves the done output undriven. The test case makes sure
// that we can load in a new start value of 2 and then the counter will
// count from 2 to 4. This test should also pass for a complete counter.

task test_case_2_basic_v2();
  t.test_case_begin( "test_case_2_basic_v2" );

  //     en ld start   incr    finish  count   done ignore_done?
  check( 1, 1, 16'd02, 16'd01, 16'd99, 16'd00, 'x,  1 );

  for( int i = 2; i < 5; i = i+1 )
    check( 1, 0, 16'd02, 16'd01, 16'd99, 16'(i), 'x, 1 );

  t.test_case_end();
endtask

//-----------------------------------------------------------------------
// test_case_3_basic_v3
//-----------------------------------------------------------------------
// This basic test case should pass even for an incomplete counter which
// supports loading in a new start and finish value but ignores the en
// input. The incomplete counter should set the done output correctly,
// but does not need to stop when done. The test case just makes sure
// that we can load in a new start value of 2 and then the counter will
// count from 2 to 4 and set the done signal high on the last cycle. This
// test should also pass for a complete counter.

task test_case_3_basic_v3();
  t.test_case_begin( "test_case_3_basic_v3" );

  //     en ld start   incr    finish  count   done
  check( 1, 1, 16'd02, 16'd01, 16'd04, 16'd00, 1 );
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd02, 0 );
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd03, 0 );
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd04, 1 );

  t.test_case_end();
endtask

//-----------------------------------------------------------------------
// test_case_4_basic_v4
//-----------------------------------------------------------------------
// This basic test case should pass even for an incomplete counter which
// supports loading in a new start and finish value but ignores the en
// input. The incomplete counter should set the done output correctly and
// also should stop when done. The test case makes sure that we can load
// in a new start value of 1 and then the counter will count from 1 to 4
// and set the done signal high on the last cycle; then the test case
// goes through the whole process a second time. This test should also
// pass for a complete counter.

task test_case_4_basic_v4();
  t.test_case_begin( "test_case_4_basic_v4" );

  //     en ld start   incr    finish  count   done
  check( 1, 1, 16'd02, 16'd01, 16'd04, 16'd00, 1 );
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd02, 0 );
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd03, 0 );
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd04, 1 );

  //     en ld start   incr    finish  count   done
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd04, 1 );
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd04, 1 );

  //     en ld start   incr    finish  count   done
  check( 1, 1, 16'd02, 16'd01, 16'd04, 16'd04, 1 );
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd02, 0 );
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd03, 0 );
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd04, 1 );

  t.test_case_end();
endtask

//-----------------------------------------------------------------------
// test_case_5_basic_v5
//-----------------------------------------------------------------------
// This basic test case should pass for the complete counter which
// supports loading in a new start and finish value, sets the done output
// correctly, stops when done, and also holds when the en input is 0. The
// test case makes sure that we can load in a new start value of 1 and
// then the counter will count from 1 to 4 with en=0 for a few cycles and
// set the done signal high on the last cycle; then the test case goes
// through the whole process a second time.

task test_case_5_basic_v5();
  t.test_case_begin( "test_case_5_basic_v5" );

  //     en ld start   incr    finish  count   done
  check( 1, 1, 16'd02, 16'd01, 16'd04, 16'd00, 1 );
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd02, 0 ); // count=2
  check( 0, 0, 16'd02, 16'd01, 16'd04, 16'd03, 0 ); // en=0
  check( 0, 0, 16'd02, 16'd01, 16'd04, 16'd03, 0 ); // en=0
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd03, 0 ); // count=3
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd04, 1 ); // count=4, done

  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd04, 1 ); // count=4, done
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd04, 1 ); // count=4, done

  check( 1, 1, 16'd02, 16'd01, 16'd04, 16'd04, 1 );
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd02, 0 ); // count=2
  check( 0, 0, 16'd02, 16'd01, 16'd04, 16'd03, 0 ); // en=0
  check( 0, 0, 16'd02, 16'd01, 16'd04, 16'd03, 0 ); // en=0
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd03, 0 ); // count=3
  check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd04, 1 ); // count=4, done

  t.test_case_end();
endtask

  //----------------------------------------------------------------------
  // Directed Cases
  //----------------------------------------------------------------------

  // Checking the counter when load changes
  task test_case_6_directed_load();
    t.test_case_begin( "test_case_6_directed_load" );

   //     en ld start   incr    finish  count   done
   check( 1, 1, 16'd00, 16'd01, 16'd04, 16'd00, 1 );
   check( 1, 0, 16'd00, 16'd01, 16'd04, 16'd00, 0 );
   check( 1, 0, 16'd00, 16'd01, 16'd04, 16'd01, 0 );
   check( 1, 0, 16'd00, 16'd01, 16'd04, 16'd02, 0 );
   check( 1, 0, 16'd00, 16'd01, 16'd04, 16'd03, 0 );
   check( 1, 0, 16'd00, 16'd01, 16'd04, 16'd04, 1 );

   // reloadin after done = 1
   check( 1, 1, 16'd02, 16'd01, 16'd04, 16'd04, 1 ); 
   check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd02, 0 );
   check( 1, 0, 16'd02, 16'd01, 16'd04, 16'd03, 0 );

  // reloading without done = 1
   check( 1, 1, 16'd01, 16'd01, 16'd03, 16'd04, 1 );
   check( 1, 0, 16'd01, 16'd01, 16'd03, 16'd01, 0 );
   check( 1, 0, 16'd01, 16'd01, 16'd03, 16'd02, 0 );
   check( 1, 0, 16'd01, 16'd01, 16'd03, 16'd03, 1 );

  // reloading consecutively
   check( 1, 1, 16'd02, 16'd01, 16'd08, 16'd03, 1 );
   check( 1, 0, 16'd02, 16'd01, 16'd08, 16'd02, 0 );
   check( 1, 1, 16'd00, 16'd01, 16'd15, 16'd03, 0 );
   check( 1, 0, 16'd00, 16'd01, 16'd15, 16'd00, 0 );
   check( 1, 1, 16'd01, 16'd01, 16'd02, 16'd01, 0 );
   check( 1, 0, 16'd01, 16'd01, 16'd02, 16'd01, 0 );
   check( 1, 0, 16'd01, 16'd01, 16'd02, 16'd02, 1 );
  
    t.test_case_end();
  endtask  

  // Checking increments
  task test_case_7_directed_increments();
    t.test_case_begin( "test_case_7_directed_incremements" );

   //     en ld start   incr    finish  count   done
   check( 1, 1, 16'd01, 16'd01, 16'd04, 16'd00, 1 ); 
   check( 1, 0, 16'd01, 16'd01, 16'd04, 16'd01, 0 ); // incr stays same
   check( 1, 0, 16'd01, 16'd01, 16'd04, 16'd02, 0 );
   check( 1, 0, 16'd01, 16'd01, 16'd04, 16'd03, 0 );
   check( 1, 0, 16'd01, 16'd01, 16'd04, 16'd04, 1 );

  // reloading with new increment
   check( 1, 1, 16'd00, 16'd15, 16'd30, 16'd04, 1 ); 
   check( 1, 0, 16'd00, 16'd15, 16'd30, 16'd00, 0 ); 
   check( 1, 0, 16'd00, 16'd15, 16'd30, 16'd15, 0 );
   check( 1, 0, 16'd00, 16'd15, 16'd30, 16'd30, 1 ); 

  // reloading with no increment
   check( 1, 1, 16'd00, 16'd00, 16'd00, 16'd30, 1 ); 
   check( 1, 0, 16'd00, 16'd00, 16'd00, 16'd00, 1 );

  // reloading with maxvalue increment
   check( 1, 1, 16'd60000, 16'd5000, 16'd65000,    16'd00, 1 ); 
   check( 1, 0, 16'd60000, 16'd5000, 16'd65000, 16'd60000, 0 );
   check( 1, 0, 16'd60000, 16'd5000, 16'd65000, 16'd65000, 1 );

  // reloading with single step increment
   check( 1, 1, 16'd10, 16'd07, 16'd17, 16'd65000, 1 ); 
   check( 1, 0, 16'd10, 16'd07, 16'd17,    16'd10, 0 );
   check( 1, 0, 16'd10, 16'd07, 16'd17,    16'd17, 1 );
   check( 1, 0, 16'd10, 16'd07, 16'd17,    16'd17, 1 ); // stays the same
   check( 1, 0, 16'd10, 16'd07, 16'd17,    16'd17, 1 );
   check( 1, 0, 16'd10, 16'd07, 16'd17,    16'd17, 1 );

    t.test_case_end();
  endtask  

  task test_case_8_directed_start_finish();
    t.test_case_begin( "test_case_8_directed_start_finish" );

   //     en ld start   incr    finish  count   done
   check( 1, 1, 16'd00, 16'd01, 16'd02, 16'd00, 1 );
   check( 1, 0, 16'd00, 16'd01, 16'd02, 16'd00, 0 );
   check( 1, 0, 16'd00, 16'd01, 16'd02, 16'd01, 0 );
   check( 1, 0, 16'd00, 16'd01, 16'd02, 16'd02, 1 );
   
   // large start and finish values
   check( 1, 1, 16'd100, 16'd01, 16'd200,  16'd02,  1 );
   check( 1, 0, 16'd100, 16'd01, 16'd200, 16'd100,  0 );
   for( logic[15:0] i = 101; i < 200; i = i + 1       )
    check( 1, 0, 16'd100, 16'd01, 16'd200, i, 0       );
   check( 1, 0, 16'd100, 16'd01, 16'd200, 16'd200,  1 );

   // larger start and finish values
   check( 1, 1, 16'd1000, 16'd01, 16'd1500,  16'd200,  1 );
   check( 1, 0, 16'd1000, 16'd01, 16'd1500, 16'd1000,  0 );
   for( logic[15:0] i = 1001; i < 1500; i = i + 1        )
    check( 1, 0, 16'd1000, 16'd01, 16'd1500, i, 0        );
   check( 1, 0, 16'd1000, 16'd01, 16'd1500, 16'd1500,  1 );
   
   // start = finish values cases
   check( 1, 1, 16'd100, 16'd01, 16'd100,  16'd1500,   1 );
   check( 1, 1, 16'd100, 16'd01, 16'd100,   16'd100,   1 );

   // Maximum boundary values
   check( 1, 1, 16'd65530, 16'd01, 16'd65535,   16'd100, 1 );
   check( 1, 0, 16'd65530, 16'd01, 16'd65535, 16'd65530, 0 );
   check( 1, 0, 16'd65530, 16'd01, 16'd65535, 16'd65531, 0 );
   check( 1, 0, 16'd65530, 16'd01, 16'd65535, 16'd65532, 0 );
   check( 1, 0, 16'd65530, 16'd01, 16'd65535, 16'd65533, 0 );
   check( 1, 0, 16'd65530, 16'd01, 16'd65535, 16'd65534, 0 );
   check( 1, 0, 16'd65530, 16'd01, 16'd65535, 16'd65535, 1 );
   check( 1, 0, 16'd65530, 16'd01, 16'd65535, 16'd65535, 1 );

    t.test_case_end();
  endtask  

  task test_case_9_directed_enable();
    t.test_case_begin( "test_case_9_directed_enable" );

   // enable holding cases
   //     en ld start   incr    finish  count   done
   check( 1, 1, 16'd02, 16'd01, 16'd08, 16'd00, 1 );
   check( 1, 0, 16'd02, 16'd01, 16'd08, 16'd02, 0 );
   check( 1, 0, 16'd02, 16'd01, 16'd08, 16'd03, 0 );
   check( 1, 0, 16'd02, 16'd01, 16'd08, 16'd04, 0 );
   check( 0, 0, 16'd02, 16'd01, 16'd08, 16'd05, 0 );
   check( 0, 0, 16'd02, 16'd01, 16'd08, 16'd05, 0 );
   check( 0, 0, 16'd02, 16'd01, 16'd08, 16'd05, 0 );
   check( 0, 0, 16'd02, 16'd01, 16'd08, 16'd05, 0 );
   check( 1, 0, 16'd02, 16'd01, 16'd08, 16'd05, 0 );
   check( 1, 0, 16'd02, 16'd01, 16'd08, 16'd06, 0 );
   check( 1, 0, 16'd02, 16'd01, 16'd08, 16'd07, 0 );
   check( 1, 0, 16'd02, 16'd01, 16'd08, 16'd08, 1 );
   
   // multiple enable cases
   //     en ld start   incr    finish  count   done
   check( 1, 1, 16'd01, 16'd01, 16'd05, 16'd08, 1 );
   check( 1, 0, 16'd01, 16'd01, 16'd05, 16'd01, 0 );
   check( 0, 0, 16'd01, 16'd01, 16'd05, 16'd02, 0 );
   check( 1, 0, 16'd01, 16'd01, 16'd05, 16'd02, 0 );
   check( 0, 0, 16'd01, 16'd01, 16'd05, 16'd03, 0 );
   check( 1, 0, 16'd01, 16'd01, 16'd05, 16'd03, 0 );
   check( 0, 0, 16'd01, 16'd01, 16'd05, 16'd04, 0 );
   check( 1, 0, 16'd01, 16'd01, 16'd05, 16'd04, 0 );
   check( 0, 0, 16'd01, 16'd01, 16'd05, 16'd05, 1 );
   check( 1, 0, 16'd01, 16'd01, 16'd05, 16'd05, 1 );

   // count holds at finish
   check( 0, 0, 16'd01, 16'd01, 16'd05, 16'd05, 1 );
   check( 0, 0, 16'd01, 16'd01, 16'd05, 16'd05, 1 );
   check( 0, 0, 16'd01, 16'd01, 16'd05, 16'd05, 1 );

   //disable from start
   check( 0, 1, 16'd00, 16'd01, 16'd04, 16'd05, 1 );
   check( 0, 0, 16'd00, 16'd01, 16'd04, 16'd00, 0 );
   check( 0, 0, 16'd00, 16'd01, 16'd04, 16'd00, 0 );
   check( 0, 0, 16'd00, 16'd01, 16'd04, 16'd00, 0 );
   check( 0, 0, 16'd00, 16'd01, 16'd04, 16'd00, 0 );
   check( 0, 0, 16'd00, 16'd01, 16'd04, 16'd00, 0 );
   check( 1, 0, 16'd00, 16'd01, 16'd04, 16'd00, 0 );
   check( 1, 0, 16'd00, 16'd01, 16'd04, 16'd01, 0 );
   check( 1, 0, 16'd00, 16'd01, 16'd04, 16'd02, 0 );
   check( 1, 0, 16'd00, 16'd01, 16'd04, 16'd03, 0 );
   check( 0, 0, 16'd00, 16'd01, 16'd04, 16'd04, 1 );
   check( 0, 0, 16'd00, 16'd01, 16'd04, 16'd04, 1 );
  
    t.test_case_end();
  endtask  


  //----------------------------------------------------------------------
  // test_case_10_random
  //----------------------------------------------------------------------

  //declaring variables for input and output
  logic [15:0] random_start;
  logic [15:0] random_finish;
  logic [15:0] new_count;
  logic        curr_done;

  task test_case_10_random();
    t.test_case_begin( "test_case_10_random" );
    // Run 50 iterations / perform 50 randomized tests
    for ( int i = 0; i < 50; i = i+1 ) begin

      // Generate random valuea for start and finish
      random_start = 16'($urandom(t.seed));
      random_finish = random_start + 16'($urandom(t.seed)%10);

      // Initialize a basic state for first cycle
      if (i == 0) begin
        check( 1'd01, 1'd01, random_start, 16'd01, random_finish, 16'd00, 1'd01 );
      end

      // State for rest of the cycle
      else begin
        check( 1'd01, 1'd01, random_start, 16'd01, random_finish, new_count, 1'd01 );
      end

      // As long as finish value is less than count, we keep incrementing
      new_count = random_start;
      curr_done = 0;
      while (new_count < random_finish) begin
        check( 1'd01, 1'd00, random_start, 16'd01, random_finish, new_count, curr_done );
        new_count += 16'd01;
        if (new_count >= random_finish) begin
          curr_done = 1;
        end
      end

    end
  t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_11_xprop
  //----------------------------------------------------------------------

  task test_case_11_xprop();
    t.test_case_begin( "test_case_11_xprop" );

   //     en ld start   incr    finish  count   done
    check(  1, 1, 16'dx, 16'dx, 16'dx, 16'd0,   1 );
    check(  1, 0, 16'dx, 16'dx, 16'dx, 16'dx,  'x );
    check(  0, 0, 16'dx, 16'dx, 16'dx, 16'dx,  'x );
    check(  0, 1, 16'dx, 16'dx, 16'dx, 16'dx,  'x );
    t.test_case_end();
  endtask

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

initial begin
  t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1))               test_case_1_basic_v1();
  if ((t.n <= 0) || (t.n == 2))               test_case_2_basic_v2();
  if ((t.n <= 0) || (t.n == 3))               test_case_3_basic_v3();
  if ((t.n <= 0) || (t.n == 4))               test_case_4_basic_v4();
  if ((t.n <= 0) || (t.n == 5))               test_case_5_basic_v5();
  if ((t.n <= 0) || (t.n == 6))          test_case_6_directed_load();
  if ((t.n <= 0) || (t.n == 7))    test_case_7_directed_increments();
  if ((t.n <= 0) || (t.n == 8))  test_case_8_directed_start_finish();
  if ((t.n <= 0) || (t.n == 9))        test_case_9_directed_enable();
  if ((t.n <= 0) || (t.n == 10))               test_case_10_random();
  if ((t.n <= 0) || (t.n == 11))                test_case_11_xprop();

  t.test_bench_end();
end
