//========================================================================
// proc-isa-sim
//========================================================================
// Author : Christopher Batten (Cornell)
// Date   : November 17, 2025

`define CYCLE_TIME 10

`include "ece2300/ece2300-misc.v"
`include "lab4/tinyrv1.v"
`include "lab4/test/ProcFL.v"

module Top();

  TinyRV1 tinyrv1();

  //----------------------------------------------------------------------
  // Clock/Reset
  //----------------------------------------------------------------------

  // verilator lint_off BLKSEQ
  logic clk;
  initial clk = 1'b1;
  always #5 clk = ~clk;
  // verilator lint_on BLKSEQ

  logic rst;

  //----------------------------------------------------------------------
  // Instantiate modules
  //----------------------------------------------------------------------

  // Processor

  logic [31:0] in0;
  logic [31:0] in1;
  logic [31:0] in2;
  logic [31:0] in3;

  logic [31:0] out0;
  logic [31:0] out1;
  logic [31:0] out2;
  logic [31:0] out3;

  logic        trace_val;
  logic [31:0] trace_addr;
  logic [31:0] trace_inst;
  logic        trace_wen;
  logic [4:0]  trace_wreg;
  logic [31:0] trace_wdata;

  ProcFL proc(.*);

  `ECE2300_UNUSED( trace_val );

  //----------------------------------------------------------------------
  // Perform the simulation
  //----------------------------------------------------------------------

  logic step;
  logic tui;
  logic tui_tall;

  int c;
  int total_cycles = 0;
  int stat_cycles = 0;
  string vcd_filename;
  string bin_filename;

  int run_cycles = 0;
  logic [31:0] value;
  string cmd;

  initial begin

    // Default values for in0, in1, in2, in3

    in0 = 0;
    if ( !$value$plusargs( "in0=0x%x", in0 ) ) begin
      if ( !$value$plusargs( "in0=0b%b", in0 ) ) begin
        if ( !$value$plusargs( "in0=%d", in0 ) )
          in0 = 0;
      end
    end

    in1 = 0;
    if ( !$value$plusargs( "in1=0x%x", in1 ) ) begin
      if ( !$value$plusargs( "in1=0b%b", in1 ) ) begin
        if ( !$value$plusargs( "in1=%d", in1 ) )
          in1 = 0;
      end
    end

    in2 = 0;
    if ( !$value$plusargs( "in2=0x%x", in2 ) ) begin
      if ( !$value$plusargs( "in2=0b%b", in2 ) ) begin
        if ( !$value$plusargs( "in2=%d", in2 ) )
          in2 = 0;
      end
    end

    in3 = 0;
    if ( !$value$plusargs( "in3=0x%x", in3 ) ) begin
      if ( !$value$plusargs( "in3=0b%b", in3 ) ) begin
        if ( !$value$plusargs( "in3=%d", in3 ) )
          in3 = 0;
      end
    end

    // Process command line arguments

    step = 0;
    if ( $test$plusargs( "step" ) )
      step = 1;

    tui = 0;
    tui_tall = 0;
    if ( $test$plusargs( "tui-tall" ) )
      tui_tall = 1;
    else if ( $test$plusargs( "tui" ) )
      tui = 1;

    if ( $value$plusargs( "dump-vcd=%s", vcd_filename ) ) begin
      $dumpfile(vcd_filename);
      $dumpvars();
    end

    if ( !$value$plusargs( "bin=%s", bin_filename ) ) begin
      $display("");
      $display(" ERROR: Must specify binary file with +bin=filename");
      $display("");
      $finish;
    end

    $readmemb( bin_filename, proc.M );

    #1;

    // Reset sequence

    rst = 1;
    #(3*`CYCLE_TIME);
    rst = 0;

    // Simulate loop

    if ( step ) begin
      $display("");
      $display("Press enter to execute next instruction.");
      $display("Enter r then press enter to finish the program without stepping.");
      $display("Enter q then press enter to quit.\n");
      $display("cycle pc         inst                 wreg wdata      ");
      $display("------------------------------------------------------");
    end

    if ( tui || tui_tall ) begin
      $display("");
    end

    for ( int i = 0; i < 10000; i++ ) begin

      if ( tui ) begin

        for ( int i = 0; i < 22; i++ ) begin

          // Column 1

          if ( i <= 15 ) begin
            if ( proc.pc == i*4 )
              $write( ">" );
            else
              $write( " " );
            $write( "%-s ", tinyrv1.disasm( i*4, proc.M[i] ) );
          end
          else if ( i == 16 ) $write( "                      " );
          else if ( i == 17 ) $write( "    Prog Counter      " );
          else if ( i == 18 ) $write( "   .------------.     " );
          else if ( i == 19 ) $write( "   | 0x%x |     ", proc.pc );
          else if ( i == 20 ) $write( "   '------------'     " );

          // Column 2

          if ( i == 0 )       $write( "      Registers  " );
          else if ( i ==  1 ) $write( "    .----------. " );
          else if ( i ==  2 ) $write( "x31 | %x | ", proc.R[31] );
          else if ( i ==  3 ) $write( "... |   ....   | " );
          else if ( i <=  9 ) $write( "x%-0d | %x | ", 19-i, proc.R[19-i] );
          else if ( i <= 19 ) $write( " x%-0d | %x | ", 19-i, proc.R[19-i] );
          else if ( i == 20 ) $write( "    '----------' " );

          // Column 3

          if ( i == 0 )       $write("       Memory   ");
          else if ( i == 1 )  $write("    .----------. ");
          else if ( i == 2 )  $write("1fc | %x | ", proc.M[127] );
          else if ( i == 3 )  $write("... |   ....   | ");
          else if ( i <= 14 ) $write("%x | %x | ", 9'(256+((14-i)*4)), proc.M[(256+((14-i)*4))>>2] );
          else if ( i == 15 ) $write("... |   ....   | ");
          else if ( i <= 19 ) $write("%x | %x | ", 9'((19-i)*4), proc.M[((19-i)*4)>>2] );
          else if ( i == 20 ) $write("    '----------' ");

          // Column 4

          if ( i == 0 )       $write("      MemMapped IO");
          else if ( i == 1 )  $write("     .----------.");
          else if ( i == 2 )  $write("out3 | %x |", out3 );
          else if ( i == 3 )  $write("out2 | %x |", out2 );
          else if ( i == 4 )  $write("out1 | %x |", out1 );
          else if ( i == 5 )  $write("out0 | %x |", out0 );
          else if ( i == 6 )  $write(" in3 | %x |", in3 );
          else if ( i == 7 )  $write(" in2 | %x |", in2 );
          else if ( i == 8 )  $write(" in1 | %x |", in1 );
          else if ( i == 9 )  $write(" in0 | %x |", in0 );
          else if ( i == 10 ) $write("     '----------'");
          else if ( i == 12 ) $write("enter to execute");
          else if ( i == 13 ) $write("current inst");
          else if ( i == 14 ) $write("/quit : quit");
          else if ( i == 15 ) $write("/run : run");
          else if ( i == 16 ) $write("/N : sim N cycs");
          else if ( i == 17 ) $write("/inN=M : set in");
          else if ( i == 19 ) $write("cycles = %-d",total_cycles);
          else if ( i == 20 ) $write("stats  = %-d",stat_cycles);

          $write("\n");

        end

      end

      if ( tui_tall ) begin

        for ( int i = 0; i < 36; i++ ) begin

          // Column 1

          if ( i <= 29 ) begin
            if ( proc.pc == i*4 )
              $write( ">" );
            else
              $write( " " );
            $write( "%-s ", tinyrv1.disasm( i*4, proc.M[i] ) );
          end
          else if ( i == 30 ) $write( "                      " );
          else if ( i == 31 ) $write( "    Prog Counter      " );
          else if ( i == 32 ) $write( "   .------------.     " );
          else if ( i == 33 ) $write( "   | 0x%x |     ", proc.pc );
          else if ( i == 34 ) $write( "   '------------'     " );

          // Column 2

          if ( i == 0 )       $write( "      Registers  " );
          else if ( i ==  1 ) $write( "    .----------. " );
          else if ( i <= 23 ) $write( "x%-0d | %x | ", 33-i, proc.R[33-i] );
          else if ( i <= 33 ) $write( " x%-0d | %x | ", 33-i, proc.R[33-i] );
          else if ( i == 34 ) $write( "    '----------' " );

          // Column 3

          if ( i == 0 )       $write("       Memory   ");
          else if ( i == 1 )  $write("    .----------. ");
          else if ( i == 2 )  $write("1fc | %x | ", proc.M[127] );
          else if ( i == 3 )  $write("... |   ....   | ");
          else if ( i <= 28 ) $write("%x | %x | ", 9'(256+((28-i)*4)), proc.M[(256+((28-i)*4))>>2] );
          else if ( i == 29 ) $write("... |   ....   | ");
          else if ( i <= 33 ) $write("%x | %x | ", 9'((33-i)*4), proc.M[((33-i)*4)>>2] );
          else if ( i == 34 ) $write("    '----------' ");

          // Column 4

          if ( i == 0 )       $write("      MemMapped IO");
          else if ( i == 1 )  $write("     .----------.");
          else if ( i == 2 )  $write("out3 | %x |", out3 );
          else if ( i == 3 )  $write("out2 | %x |", out2 );
          else if ( i == 4 )  $write("out1 | %x |", out1 );
          else if ( i == 5 )  $write("out0 | %x |", out0 );
          else if ( i == 6 )  $write(" in3 | %x |", in3 );
          else if ( i == 7 )  $write(" in2 | %x |", in2 );
          else if ( i == 8 )  $write(" in1 | %x |", in1 );
          else if ( i == 9 )  $write(" in0 | %x |", in0 );
          else if ( i == 10 ) $write("     '----------'");
          else if ( i == 24 ) $write("enter to execute");
          else if ( i == 25 ) $write("current inst");
          else if ( i == 27 ) $write("/quit : quit");
          else if ( i == 28 ) $write("/run : run");
          else if ( i == 29 ) $write("/N : sim N cycs");
          else if ( i == 30 ) $write("/inN=M : set in");
          else if ( i == 32 ) $write("cycles = %-d",total_cycles);
          else if ( i == 33 ) $write("stats  = %-d",stat_cycles);

          $write("\n");

        end

      end

      // $fscanf( 'h8000_0000, "%s", cmd );
      // if ( cmd == "q" )
      //   $finish;

      if ( tui || tui_tall ) begin

        $display("                               ");
        $write("\x1b[A");
        $write("(tui) ");

        if ( run_cycles > 0 ) begin
          run_cycles = run_cycles - 1;

          if ( tui ) begin
            for ( int i = 0; i < 22; i++ )
              $write("\x1b[A");
          end
          else begin
            for ( int i = 0; i < 36; i++ )
              $write("\x1b[A");
          end

          $write("\x1b[1G");

        end
        else begin
          c = $fgetc( 'h8000_0000 );
          if ( c == "q" )
             $finish;
          if ( c == "/" ) begin

            if ( $fscanf( 'h8000_0000, "%s", cmd ) == -1 ) begin
              $display("ERROR with parsing tui command line");
              $finish;
            end

            if ( cmd == "quit" )
              $finish;
            else if ( cmd == "run" ) begin
              tui = 0;
              tui_tall = 0;
            end
            else if ( $sscanf( cmd, "%d",       value ) == 1 ) run_cycles = value - 1;
            else if ( $sscanf( cmd, "in0=0x%x", value ) == 1 ) in0 = value;
            else if ( $sscanf( cmd, "in0=0b%b", value ) == 1 ) in0 = value;
            else if ( $sscanf( cmd, "in0=%d",   value ) == 1 ) in0 = value;
            else if ( $sscanf( cmd, "in1=0x%x", value ) == 1 ) in1 = value;
            else if ( $sscanf( cmd, "in1=0b%b", value ) == 1 ) in1 = value;
            else if ( $sscanf( cmd, "in1=%d",   value ) == 1 ) in1 = value;
            else if ( $sscanf( cmd, "in2=0x%x", value ) == 1 ) in2 = value;
            else if ( $sscanf( cmd, "in2=0b%b", value ) == 1 ) in2 = value;
            else if ( $sscanf( cmd, "in2=%d",   value ) == 1 ) in2 = value;
            else if ( $sscanf( cmd, "in3=0x%x", value ) == 1 ) in3 = value;
            else if ( $sscanf( cmd, "in3=0b%b", value ) == 1 ) in3 = value;
            else if ( $sscanf( cmd, "in3=%d",   value ) == 1 ) in3 = value;

            // consume newline
            c = $fgetc( 'h8000_0000 );
          end

          if ( tui ) begin
            for ( int i = 0; i < 23; i++ )
              $write("\x1b[A");
            $write("\x1b[1G");
          end
          else if ( tui_tall )begin
            for ( int i = 0; i < 37; i++ )
              $write("\x1b[A");
            $write("\x1b[1G");
          end

        end
      end

      #`CYCLE_TIME;

      if ( step ) begin
        $write( "%4d: 0x%x %-s ", total_cycles, trace_addr,
                tinyrv1.disasm(trace_addr,trace_inst) );

        if ( trace_wen )
          $write( "%d 0x%x  ", trace_wreg, trace_wdata );
        else
          $write( "               " );

        c = $fgetc( 'h8000_0000 );
        if ( c == "q" )
          $finish;
        if ( c == "r" )
          step = 0;
      end

      total_cycles = total_cycles + 1;
      if ( out3[0] )
        stat_cycles = stat_cycles + 1;

    end

    // Finish

    $display( "" );
    $display( "in0  = %x", in0 );
    $display( "in1  = %x", in1 );
    $display( "in2  = %x", in2 );
    $display( "in3  = %x", in3 );

    $display( "" );
    $display( "out0 = %x", out0 );
    $display( "out1 = %x", out1 );
    $display( "out2 = %x", out2 );
    $display( "out3 = %x", out3 );

    $display( "" );
    $display( "total_cycles = %-0d", total_cycles );
    $display( "stat_cycles  = %-0d", stat_cycles );

    $display( "" );
    $finish;

  end

endmodule
