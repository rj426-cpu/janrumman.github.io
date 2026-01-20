//========================================================================
// AccumXcel-test.v
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/AccumXcel.v"
`include "lab4/test/TestMemory.v"

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

  logic        mem_val;
  logic [31:0] mem_addr;
  logic [31:0] mem_rdata;

  logic        in_val;
  logic        in_rdy;
  logic  [6:0] in_size;

  logic [31:0] result;

  AccumXcel dut
  (
    .*
  );

  logic        mem0_wait;
  logic [31:0] mem0_rdata;
  logic        mem1_wait;

  TestMemory mem
  (
    .clk        (clk),
    .rst        (rst),

    .mem0_val   ('0),
    .mem0_wait  (mem0_wait),
    .mem0_type  ('x),
    .mem0_addr  ('x),
    .mem0_wdata ('x),
    .mem0_rdata (mem0_rdata),

    .mem1_val   (mem_val),
    .mem1_wait  (mem1_wait),
    .mem1_type  (1'b0),
    .mem1_addr  (mem_addr),
    .mem1_wdata ('x),
    .mem1_rdata (mem_rdata)
  );

  `ECE2300_UNUSED( mem0_wait );
  `ECE2300_UNUSED( mem0_rdata );
  `ECE2300_UNUSED( mem1_wait );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // The ECE 2300 test framework adds a 1 tau delay with respect to the
  // rising clock edge at the very beginning of the test bench. So if we
  // immediately set the inputs this will take effect 1 tau after the clock
  // edge. Then we wait 8 tau, check the outputs, and wait 2 tau which
  // means the next check will again start 1 tau after the rising clock
  // edge.

  localparam IGNORE_OUTPUTS = 1;

  task check
  (
    input logic        in_val_,
    input logic        in_rdy_,
    input logic  [6:0] in_size_,
    input logic [31:0] result_,
    input logic        ignore_outputs = 0
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in_val  = in_val_;
      in_size = in_size_;

      #8

      if ( t.n != 0 ) begin

        $write( "%3d: ", t.cycles );

        if      (  in_val &&  in_rdy ) $write( "%d", in_size );
        else if (  in_val && !in_rdy ) $write( "  #" );
        else if ( !in_val &&  in_rdy ) $write( "   " );
        else if ( !in_val && !in_rdy ) $write( "  ." );

        $write( " (" );

        $write( ") " );

        if ( in_rdy )
          $write( "%x", result );
        else
          $write( "        " );

        $write( " | " );

        if ( mem_val )
          $write( "rd:%x:%x", mem_addr, mem_rdata );

        $write( "\n" );

      end

      if ( !ignore_outputs ) begin
        `ECE2300_CHECK_EQ( in_rdy, in_rdy_ );
        `ECE2300_CHECK_EQ( result, result_ );
      end

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // data
  //----------------------------------------------------------------------

  logic [31:0] data_addr_unused;

  task data
  (
    input logic [31:0] addr,
    input logic [31:0] data_
  );
    mem.write( addr, data_ );
    data_addr_unused = addr;
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    // Load test data into test memory (remember, accelerator always
    // starts accumulating from address 0x000!)

    data( 'h000, 1 );
    data( 'h004, 2 );
    data( 'h008, 3 );
    data( 'h00c, 4 );

    // Send message to accumulate 4 elements

    //     ---- in ----
    //     val rdy size result
    check( 1,  1,  4,   0 );

    // Simulate for 20 cycles

    for ( int i = 0; i < 20; i = i+1 )
      check( 0, 0, 0, 0, IGNORE_OUTPUTS );

    // Check result is correct

    //     ---- in ----
    //     val rdy size result
    check( 0,  1,  0,   10 );

    t.test_case_end();
  endtask

  task test_case_2_size1();
    t.test_case_begin( "test_case_2_size1" );

    data( 'h000, 32'd7   );
    data( 'h004, 32'd999 );

    //     ---- in ----
    //     val rdy size result
    check( 1,  1,  1,   0 );

    // Simulate for 20 cycles

    for ( int i = 0; i < 20; i = i+1 )
      check( 0, 0, 0, 0, IGNORE_OUTPUTS );

    // Check result is correct

    //     ---- in ----
    //     val rdy size result
    check( 0,  1,  0,   32'd7 );

    t.test_case_end();
  endtask  

  task test_case_3_size0();
    t.test_case_begin( "test_case_3_size0" );

    data( 'h000, 32'd5   );
    data( 'h004, 32'd6   );

    //     ---- in ----
    //     val rdy size result
    check( 1,  1,  0,   0 );

    // Simulate for 20 cycles

    for ( int i = 0; i < 20; i = i+1 )
      check( 0, 0, 0, 0, IGNORE_OUTPUTS );

    // Check result is correct

    //     ---- in ----
    //     val rdy size result
    check( 0,  1,  0,   32'd0 );

    t.test_case_end();
  endtask    

  task test_case_4_longer_size();
    t.test_case_begin( "test_case_4_longer_size" );

    data( 'h000, 1 );
    data( 'h004, 1 );
    data( 'h008, 2 );
    data( 'h00c, 3 );
    data( 'h010, 5 );
    data( 'h014, 8 );

    //     ---- in ----
    //     val rdy size result
    check( 1, 1, 6, 0 );
    
    // Simulate for 20 cycles

    for ( int i = 0; i < 25; i = i+1 )
      check( 0, 0, 0, 0, IGNORE_OUTPUTS );

    check( 0, 1, 0, 32'd20 );

    // Check result is correct

    //     ---- in ----
    //     val rdy size result
    check( 0,  1,  0,   32'd20 );

    t.test_case_end();
  endtask  

  task test_case_5_alternating_zeros();
    t.test_case_begin( "test_case_5_alternating_zeros" );

    data( 'h000, 5 );
    data( 'h004, 0 );
    data( 'h008, 5 );
    data( 'h00c, 0 );

    // sum = 10
    check( 1, 1, 4, 0 );

    for ( int i = 0; i < 20; i++ )
      check( 0, 0, 0, 0, IGNORE_OUTPUTS );

    check( 0, 1, 0, 32'd10 );

    t.test_case_end();
  endtask

  task test_case_6_all_zeros();
    t.test_case_begin( "test_case_6_all_zeros" );

    data( 'h000, 0 );
    data( 'h004, 0 );
    data( 'h008, 0 );
    data( 'h00c, 0 );

    check( 1, 1, 4, 0 );

    for ( int i = 0; i < 20; i++ )
      check( 0, 0, 0, 0, IGNORE_OUTPUTS );

    check( 0, 1, 0, 32'd0 );

    t.test_case_end();
  endtask

  task test_case_7_two_messages();
    t.test_case_begin( "test_case_7_two_messages" );

    data( 'h000, 1 );
    data( 'h004, 2 );
    data( 'h008, 3 );
    data( 'h00c, 4 );

    check( 1, 1, 4, 0 );

    for ( int i = 0; i < 20; i++ )
      check( 0, 0, 0, 0, IGNORE_OUTPUTS );

    check( 0, 1, 0, 10 );

    data( 'h000, 5 );
    data( 'h004, 6 );
    data( 'h008, 7 );

    check( 1, 1, 3, 10 );

    for ( int i = 0; i < 20; i++ )
      check( 0, 0, 0, 0, IGNORE_OUTPUTS );

    check( 0, 1, 0, 18 );

    t.test_case_end();
  endtask

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_size1();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_size0();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_longer_size();
    if ((t.n <= 0) || (t.n == 5)) test_case_5_alternating_zeros();
    if ((t.n <= 0) || (t.n == 6)) test_case_6_all_zeros();
    if ((t.n <= 0) || (t.n == 7)) test_case_7_two_messages();

    t.test_bench_end();
  end

endmodule
