//========================================================================
// Proc-addi-test-cases
//========================================================================

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 2"   );
  asm( 'h004, "addi x2, x1, 2"   );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0002 ); // addi x1, x0, 2
  check_trace( 'h004, 1, 5'd2, 32'h0000_0004 ); // addi x2, x1, 2

  t.test_case_end();
endtask

task test_case_2_addx0();
  t.test_case_begin( "test_case_2_addx0" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 5"   );
  asm( 'h004, "addi x2, x0, 7"   );
  asm( 'h008, "addi x3, x0, 10"   );  

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0005 ); // addi x1, x0, 5
  check_trace( 'h004, 1, 5'd2, 32'h0000_0007 ); // addi x2, x0, 7
  check_trace( 'h008, 1, 5'd3, 32'h0000_000A ); // addi x3, x0, 10

  t.test_case_end();
endtask

task test_case_3_add16();
  t.test_case_begin( "test_case_3_add16" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 16"   );
  asm( 'h004, "addi x2, x1, 16"   );
  asm( 'h008, "addi x3, x2, 16"   );
  asm( 'h00C, "addi x4, x3, 16"   );
  asm( 'h010, "addi x5, x4, 16"   );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0010 ); // addi x1, x0, 16
  check_trace( 'h004, 1, 5'd2, 32'h0000_0020 ); // addi x2, x1, 16
  check_trace( 'h008, 1, 5'd3, 32'h0000_0030 ); 
  check_trace( 'h00C, 1, 5'd4, 32'h0000_0040 );
  check_trace( 'h010, 1, 5'd5, 32'h0000_0050 );

  t.test_case_end();
endtask

task test_case_4_repeat();
  t.test_case_begin( "test_case_4_repeat" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 1"   );
  asm( 'h004, "addi x2, x1, 1"   );
  asm( 'h008, "addi x2, x2, 1"   );
  asm( 'h00c, "addi x2, x2, 1"   );
  asm( 'h010, "addi x2, x2, 1"   );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0001 ); 
  check_trace( 'h004, 1, 5'd2, 32'h0000_0002 ); 
  check_trace( 'h008, 1, 5'd2, 32'h0000_0003 );
  check_trace( 'h00c, 1, 5'd2, 32'h0000_0004 );
  check_trace( 'h010, 1, 5'd2, 32'h0000_0005 );

  t.test_case_end();
endtask

task test_case_5_zero();
  t.test_case_begin( "test_case_5_zero" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0"   );
  asm( 'h004, "addi x2, x0, 0"   );
  asm( 'h008, "addi x3, x0, 0"   );
  asm( 'h00c, "addi x4, x0, 0"   );
  asm( 'h010, "addi x5, x0, 0"   );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0000 ); 
  check_trace( 'h004, 1, 5'd2, 32'h0000_0000 ); 
  check_trace( 'h008, 1, 5'd3, 32'h0000_0000 );
  check_trace( 'h00c, 1, 5'd4, 32'h0000_0000 );
  check_trace( 'h010, 1, 5'd5, 32'h0000_0000 );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

initial begin
  t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
  if ((t.n <= 0) || (t.n == 2)) test_case_2_addx0();
  if ((t.n <= 0) || (t.n == 3)) test_case_3_add16();
  if ((t.n <= 0) || (t.n == 4)) test_case_4_repeat();
  if ((t.n <= 0) || (t.n == 5)) test_case_5_zero();

  t.test_bench_end();
end

