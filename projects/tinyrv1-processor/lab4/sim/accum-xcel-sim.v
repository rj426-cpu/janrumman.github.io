//========================================================================
// accum-xcel-sim +switches=00000
//========================================================================
// Author : Christopher Batten (Cornell)
// Date   : September 7, 2024

`define CYCLE_TIME 10

`include "ece2300/SevenSegFL.v"
`include "lab1/DisplayOpt_GL.v"
`include "lab4/AccumXcel.v"
`include "lab4/test/TestMemory.v"

module Top();

  //----------------------------------------------------------------------
  // Clock/Reset
  //----------------------------------------------------------------------

  // verilator lint_off BLKSEQ
  logic clk;
  initial clk = 1'b1;
  always #(`CYCLE_TIME/2) clk = ~clk;
  // verilator lint_on BLKSEQ

  logic rst;

  //----------------------------------------------------------------------
  // Instantiate accelerator, test memory, displays
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

  logic [6:0] size_seg_tens;
  logic [6:0] size_seg_ones;

  DisplayOpt_GL display_size
  (
    .in       (in_size[4:0]),
    .seg_tens (size_seg_tens),
    .seg_ones (size_seg_ones)
  );

  logic [6:0] result_seg_tens;
  logic [6:0] result_seg_ones;

  DisplayOpt_GL display_result
  (
    .in       (result[4:0]),
    .seg_tens (result_seg_tens),
    .seg_ones (result_seg_ones)
  );

  //----------------------------------------------------------------------
  // Instantiate seven-segment FL models
  //----------------------------------------------------------------------

  SevenSegFL size_seg_tens_fl
  (
    .in (size_seg_tens)
  );

  SevenSegFL size_seg_ones_fl
  (
    .in (size_seg_ones)
  );

  SevenSegFL result_seg_tens_fl
  (
    .in (result_seg_tens)
  );

  SevenSegFL result_seg_ones_fl
  (
    .in (result_seg_ones)
  );

  //----------------------------------------------------------------------
  // Simulate one cycle
  //----------------------------------------------------------------------

  int total_cycles = 0;
  int stat_cycles = 0;

  task tick();

    #8;

    $write( "%3d: ", total_cycles );

    if      (  in_val &&  in_rdy ) $write( "%d", in_size );
    else if (  in_val && !in_rdy ) $write( "  #" );
    else if ( !in_val &&  in_rdy ) $write( "   " );
    else if ( !in_val && !in_rdy ) $write( "  ." );
    else                           $write( "xxx" );

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

    total_cycles = total_cycles + 1;

    if ( !in_rdy )
      stat_cycles = stat_cycles + 1;

    #2;

  endtask

  //----------------------------------------------------------------------
  // Perform the simulation
  //----------------------------------------------------------------------

  logic [4:0] switches;
  string vcd_filename;

  initial begin

    // Process command line arguments

    if ( $test$plusargs( "help" ) ) begin
      $display("");
      $display(" accum-xcel-sim +switches=00000");
      $display("");
      $finish;
    end

    if ( !$value$plusargs( "switches=%b", switches ) )
      switches = 5'b00000;

    if ( $value$plusargs( "dump-vcd=%s", vcd_filename ) ) begin
      $dumpfile(vcd_filename);
      $dumpvars();
    end

    // Initialize memory

                            //       result result   seven
                            //  size  (dec)  (hex) segment
                            // ----------------------------
    mem.write( 'h000, 36 ); //     1     36  0x024    4
    mem.write( 'h004, 26 ); //     2     62  0x03e   30
    mem.write( 'h008, 69 ); //     3    131  0x083    3
    mem.write( 'h00c, 57 ); //     4    188  0x0bc   28
    mem.write( 'h010, 11 ); //     5    199  0x0c7    7
    mem.write( 'h014, 68 ); //     6    267  0x10b   11
    mem.write( 'h018, 41 ); //     7    308  0x134   20
    mem.write( 'h01c, 90 ); //     8    398  0x18e   14

    mem.write( 'h020, 32 ); //     9    430  0x1ae   14
    mem.write( 'h024, 76 ); //    10    506  0x1fa   26
    mem.write( 'h028, 44 ); //    11    550  0x226    6
    mem.write( 'h02c, 19 ); //    12    569  0x239   25
    mem.write( 'h030, 17 ); //    13    586  0x24a   10
    mem.write( 'h034, 59 ); //    14    645  0x285    5
    mem.write( 'h038, 99 ); //    15    744  0x2e8    8
    mem.write( 'h03c, 49 ); //    16    793  0x319   25

    mem.write( 'h040, 65 ); //    17    858  0x35a   26
    mem.write( 'h044, 12 ); //    18    870  0x366    6
    mem.write( 'h048, 55 ); //    19    925  0x39d   29
    mem.write( 'h04c,  0 ); //    20    925  0x39d   29
    mem.write( 'h050, 51 ); //    21    976  0x3d0   16
    mem.write( 'h054, 42 ); //    22   1018  0x3fa   26
    mem.write( 'h058, 82 ); //    23   1100  0x44c   12
    mem.write( 'h05c, 23 ); //    24   1123  0x463    3

    mem.write( 'h060, 21 ); //    25   1144  0x478   24
    mem.write( 'h064, 54 ); //    26   1198  0x4ae   14
    mem.write( 'h068, 83 ); //    27   1281  0x501    1
    mem.write( 'h06c, 31 ); //    28   1312  0x520    0
    mem.write( 'h070, 16 ); //    29   1328  0x530   16
    mem.write( 'h074, 76 ); //    30   1404  0x57c   28
    mem.write( 'h078, 21 ); //    31   1425  0x591   17
    mem.write( 'h07c,  4 ); //    32   1429  0x595   21

    // Initial values

    total_cycles = 0;
    stat_cycles  = 0;
    in_val  = 0;
    in_size = { 2'b0, switches };

    // Advance time

    #1;

    // Reset sequence

    $display("");

    rst = 1;
    tick();
    tick();
    tick();
    rst = 0;

    // Send input message

    in_val = 1;
    tick();
    in_val = 0;

    // Simulate 1000 cycles or until done

    while ( !in_rdy && (total_cycles < 1000) )
      tick();

    // Simulate a few more cycles

    for ( int i = 0; i < 5; i++ )
      tick();

    // Display output

    $write( "\n" );
    for ( int i = 0; i < 7; i++ ) begin

      $write( "  " );
      size_seg_tens_fl.write_row( i );
      $write( "  " );
      size_seg_ones_fl.write_row( i );

      $write( "    " );
      result_seg_tens_fl.write_row( i );
      $write( "  " );
      result_seg_ones_fl.write_row( i );

      $write( "\n" );
    end
    $write( "\n" );

    $display( "" );
    $display( "total_cycles = %-0d", total_cycles );
    $display( "stat_cycles  = %-0d", stat_cycles );

    $display( "" );

    $finish;
  end

endmodule

