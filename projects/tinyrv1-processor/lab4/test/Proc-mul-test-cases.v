//========================================================================
// Proc-mul-test-cases
//========================================================================

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 2"  );
  asm( 'h004, "addi x2, x0, 3"  );
  asm( 'h008, "mul  x3, x1, x2" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0002 ); // addi x1, x0, 2
  check_trace( 'h004, 1, 5'd2, 32'h0000_0003 ); // addi x2, x0, 3
  check_trace( 'h008, 1, 5'd3, 32'h0000_0006 ); // mul  x3, x1, x2

  t.test_case_end();
endtask

task test_case_2_zero();
  t.test_case_begin( "test_case_2_zero" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 1"  );
  asm( 'h004, "addi x2, x0, 2"  );
  asm( 'h008, "addi x3, x0, 3"  );
  asm( 'h00c, "mul  x4, x1, x0" );
  asm( 'h010, "mul  x5, x2, x0" );
  asm( 'h014, "mul  x6, x3, x0" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0001 ); // addi x1, x0, 1
  check_trace( 'h004, 1, 5'd2, 32'h0000_0002 ); // addi x2, x0, 2
  check_trace( 'h008, 1, 5'd3, 32'h0000_0003 ); // addi x3, x0, 3
  check_trace( 'h00c, 1, 5'd4, 32'h0000_0000 ); // mul  x4, x1, x0 -> 1*0
  check_trace( 'h010, 1, 5'd5, 32'h0000_0000 ); // mul  x5, x2, x0 -> 2*0
  check_trace( 'h014, 1, 5'd6, 32'h0000_0000 ); // mul  x6, x3, x0 -> 3*0

  t.test_case_end();
endtask

task test_case_3_square();
  t.test_case_begin( "test_case_3_square" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 2"  );
  asm( 'h004, "mul  x2, x1, x1" ); // 2 * 2 = 4
  asm( 'h008, "mul  x3, x2, x2" ); // 4 * 4 = 16
  asm( 'h00c, "mul  x4, x3, x3" ); // 16 * 16 = 256
  asm( 'h010, "mul  x5, x4, x4" ); // 256 * 256 = 65536

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0002 ); // addi x1, x0, 2
  check_trace( 'h004, 1, 5'd2, 32'h0000_0004 ); // mul  x2, x1, x1
  check_trace( 'h008, 1, 5'd3, 32'h0000_0010 ); // mul  x3, x2, x2
  check_trace( 'h00c, 1, 5'd4, 32'h0000_0100 ); // mul  x3, x2, x2
  check_trace( 'h010, 1, 5'd5, 32'h0001_0000 ); // mul  x3, x2, x2

  t.test_case_end();
endtask

task test_case_4_factorial();
  t.test_case_begin( "test_case_4_factorial" );

  // Write assembly program into memory
  // Load input values into x1–x5
  asm( 'h000, "addi x1, x0, 1"  ); // x1 = 1
  asm( 'h004, "addi x2, x0, 2"  ); // x2 = 2
  asm( 'h008, "addi x3, x0, 3"  ); // x3 = 3
  asm( 'h00c, "addi x4, x0, 4"  ); // x4 = 4
  asm( 'h010, "addi x5, x0, 5"  ); // x5 = 5

  // Compute factorials and store in x10–x14
  asm( 'h014, "mul  x10, x1, x2" ); // x10 = 1 * 2 = 2
  asm( 'h018, "mul  x11, x10, x3" ); // x11 = 2 * 3 = 6
  asm( 'h01c, "mul  x12, x11, x4" ); // x12 = 6 * 4 = 24
  asm( 'h020, "mul  x13, x12, x5" ); // x13 = 24 * 5 = 120

  // Check each executed instruction

  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0001 ); // x1 = 1
  check_trace( 'h004, 1, 5'd2, 32'h0000_0002 ); // x2 = 2
  check_trace( 'h008, 1, 5'd3, 32'h0000_0003 ); // x3 = 3
  check_trace( 'h00c, 1, 5'd4, 32'h0000_0004 ); // x4 = 4
  check_trace( 'h010, 1, 5'd5, 32'h0000_0005 ); // x5 = 5

  check_trace( 'h014, 1, 5'd10, 32'h0000_0002 ); // x10 = 1 * 2
  check_trace( 'h018, 1, 5'd11, 32'h0000_0006 ); // x11 = 2 * 3
  check_trace( 'h01c, 1, 5'd12, 32'h0000_0018 ); // x12 = 6 * 4
  check_trace( 'h020, 1, 5'd13, 32'h0000_0078 ); // x13 = 24 * 5 = 120

  t.test_case_end();
endtask

task test_case_5_overwrite();
  t.test_case_begin( "test_case_5_overwrite" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 3"  );
  asm( 'h004, "mul  x1, x1, x1" );
  asm( 'h008, "mul  x1, x1, x1" );
  asm( 'h00c, "mul  x1, x1, x1" );
  asm( 'h010, "mul  x1, x1, x1" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0003 ); // addi x1, x0, 3
  check_trace( 'h004, 1, 5'd1, 32'h0000_0009 ); // mul  x1, x1, x1; 3*3 = 9 
  check_trace( 'h008, 1, 5'd1, 32'h0000_0051 ); // mul  x1, x1, x1; 9*9 = 81
  check_trace( 'h00c, 1, 5'd1, 32'h0000_19A1 ); // mul  x1, x1, x1; 81*81 = 6561
  check_trace( 'h010, 1, 5'd1, 32'h0290_D741 ); // mul  x1, x1, x1; 6561*6561 = 43046721

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

initial begin
  t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
  if ((t.n <= 0) || (t.n == 2)) test_case_2_zero();
  if ((t.n <= 0) || (t.n == 3)) test_case_3_square();
  if ((t.n <= 0) || (t.n == 4)) test_case_4_factorial();
  if ((t.n <= 0) || (t.n == 5)) test_case_5_overwrite();

  t.test_bench_end();
end
