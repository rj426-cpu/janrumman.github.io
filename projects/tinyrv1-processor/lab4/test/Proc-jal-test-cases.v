//========================================================================
// Proc-jal-test-cases
//========================================================================

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 1" );
  asm( 'h004, "jal  x2, 0x00c" );
  asm( 'h008, "addi x1, x0, 2" );
  asm( 'h00c, "addi x1, x0, 3" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0001 ); // addi x1, x0, 1
  check_trace( 'h004, 1, 5'd2, 32'h0000_0008 ); // jal  x2, 0x00c
  check_trace( 'h00c, 1, 5'd1, 32'h0000_0003 ); // addi x1, x0, 3

  t.test_case_end();
endtask

task test_case_2_forward_and_back();
  t.test_case_begin( "test_case_2_forward_and_back" );

  // Write assembly program into memory

  asm( 'h000, "jal  x1,  0x010" ); 
  asm( 'h004, "addi x2, x0, 99" ); // skipped 
  asm( 'h008, "jal  x3,  0x014" ); 
  asm( 'h00c, "addi x4, x0, 32" ); // skipped
  asm( 'h010, "jal  x5,  0x008" );
  asm( 'h014, "addi x4, x0, 32" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0004 ); // x1 = return addr from jal x1
  check_trace( 'h010, 1, 5'd5, 32'h0000_0014 ); // x5 = return addr from jal x5
  check_trace( 'h008, 1, 5'd3, 32'h0000_000c ); // x3 = return addr from jal x3
  check_trace( 'h014, 1, 5'd4, 32'h0000_0020 ); // x4 = 32 + 0

  t.test_case_end();
endtask

task test_case_3_self();
  t.test_case_begin( "test_case_3_self" );

  // Write assembly program into memory

  asm( 'h000, "jal x1, 0x000" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0004 ); // x1 = return addr

  t.test_case_end();
endtask

task test_case_4_multiple_jumps();
  t.test_case_begin( "test_case_4_multiple_jumps" );

  // Write assembly program into memory
  asm( 'h000, "jal  x1,  0x010" ); // jump to 0x010
  asm( 'h004, "addi x2, x0, 99" ); // skipped
  asm( 'h008, "jal  x3,  0x014" ); // jump to 0x014
  asm( 'h00c, "addi x4, x0, 88" ); // skipped
  asm( 'h010, "addi x5, x0, 55" ); // executed
  asm( 'h014, "addi x6, x0, 66" ); // executed

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0004 );
  check_trace( 'h010, 1, 5'd5, 32'h0000_0037 );
  check_trace( 'h014, 1, 5'd6, 32'h0000_0042 );

  t.test_case_end();
endtask

task test_case_5_overwrite();
  t.test_case_begin( "test_case_5_overwrite" );

  asm( 'h000, "addi x1, x0, 16" ); 
  asm( 'h004, "jal  x1,  0x010" ); // overwrite x1
  asm( 'h008, "addi x2, x0, 52" );
  asm( 'h010, "addi x2, x0, 8"  ); 

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0010 ); // x1 = 16 + 0 
  check_trace( 'h004, 1, 5'd1, 32'h0000_0008 ); // x1 overwritten
  check_trace( 'h010, 1, 5'd2, 32'h0000_0008 ); // x2 = 8

  t.test_case_end();
endtask

// Jump immediately to PC+4
task test_case_6_jumptonext();
  t.test_case_begin( "test_case_5_overwrite" );

  asm( 'h000, "addi x1, x0,  1" ); 
  asm( 'h004, "jal  x2,  0x008" );
  asm( 'h008, "jal  x3,  0x00c" );
  asm( 'h00c, "jal  x4,  0x010" );
  asm( 'h010, "addi x5, x0, 16" ); 

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0001 ); // x1 = 1
  check_trace( 'h004, 1, 5'd2, 32'h0000_0008 ); // x2 = pc+4 -> 4+4 = 8
  check_trace( 'h008, 1, 5'd3, 32'h0000_000c ); // x3 = pc+4 -> 8+4 = 12 (c)
  check_trace( 'h00c, 1, 5'd4, 32'h0000_0010 ); // x4 = pc+4 -> 12+4 = 16 (10)
  check_trace( 'h010, 1, 5'd5, 32'h0000_0010 ); // x5 = 16+0

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

initial begin
  t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
  if ((t.n <= 0) || (t.n == 2)) test_case_2_forward_and_back();
  if ((t.n <= 0) || (t.n == 3)) test_case_3_self();
  if ((t.n <= 0) || (t.n == 4)) test_case_4_multiple_jumps();
  if ((t.n <= 0) || (t.n == 5)) test_case_5_overwrite();
  if ((t.n <= 0) || (t.n == 6)) test_case_6_jumptonext();

  t.test_bench_end();
end
