//========================================================================
// Proc-add-test-cases
//========================================================================

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 2"  );
  asm( 'h004, "addi x2, x0, 3"  );
  asm( 'h008, "add  x3, x1, x2" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0002 ); // addi x1, x0, 2
  check_trace( 'h004, 1, 5'd2, 32'h0000_0003 ); // addi x2, x0, 3
  check_trace( 'h008, 1, 5'd3, 32'h0000_0005 ); // add  x3, x1, x2

  t.test_case_end();
endtask

task test_case_2_fib();
  t.test_case_begin( "test_case_2_fib" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 1"  );
  asm( 'h004, "addi x2, x0, 1"  );
  asm( 'h008, "add  x3, x1, x2" );
  asm( 'h00c, "add  x4, x3, x2" );
  asm( 'h010, "add  x5, x4, x3" );
  asm( 'h014, "add  x6, x5, x4" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0001 ); // addi x1, x0, 1
  check_trace( 'h004, 1, 5'd2, 32'h0000_0001 ); // addi x2, x0, 1
  check_trace( 'h008, 1, 5'd3, 32'h0000_0002 ); // add  x3, x1, x2
  check_trace( 'h00c, 1, 5'd4, 32'h0000_0003 ); // add  x4, x3, x2
  check_trace( 'h010, 1, 5'd5, 32'h0000_0005 ); // add  x5, x4, x3
  check_trace( 'h014, 1, 5'd6, 32'h0000_0008 ); // add  x6, x5, x4

  t.test_case_end();
endtask

task test_case_3_powersoftwo();
  t.test_case_begin( "test_case_3_powersoftwo" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 2"  );
  asm( 'h004, "add  x2, x1, x1"  );
  asm( 'h008, "add  x3, x2, x2" );
  asm( 'h00c, "add  x4, x3, x3" );
  asm( 'h010, "add  x5, x4, x4" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0002 ); // addi x1, x0, 2
  check_trace( 'h004, 1, 5'd2, 32'h0000_0004 ); // add  x2, x1, x1
  check_trace( 'h008, 1, 5'd3, 32'h0000_0008 ); // add  x3, x2, x2
  check_trace( 'h00c, 1, 5'd4, 32'h0000_0010 ); // add  x4, x3, x3
  check_trace( 'h010, 1, 5'd5, 32'h0000_0020 ); // add  x5, x4, x4

  t.test_case_end();
endtask

task test_case_4_zero();
  t.test_case_begin( "test_case_4_zero" );

  // Write assembly program into memory

  asm( 'h000, "add  x1, x0, x0" );
  asm( 'h004, "add  x2, x0, x0" );

  // Check each executed instruction
  //           addr   en reg   data  
  check_trace( 'h000, 1, 5'd1, 32'h0000_0000 ); // x1 = x0 + x0 = 0
  check_trace( 'h004, 1, 5'd2, 32'h0000_0000 ); // x2 = x0 + x0 = 0

  t.test_case_end();
endtask

task test_case_5_wraparound();
  t.test_case_begin( "test_case_5_wraparound" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 4294967295" ); 
  asm( 'h004, "addi x2, x0, 1"          ); 
  asm( 'h008, "add  x3, x2, x1"         ); 
  asm( 'h00c, "add  x4, x3, x2"         );

  // Check each executed instruction
  //           addr   en reg   data 
  check_trace( 'h000, 1, 5'd1, 32'hFFFF_FFFF ); // x1 = x0 + 4294967295 = FFFF_FFFF
  check_trace( 'h004, 1, 5'd2, 32'h0000_0001 ); // x2 = x0 + 1 = 1
  check_trace( 'h008, 1, 5'd3, 32'h0000_0000 ); // x3 = x2 + x1 = 1 + 0xFFFF_FFFF = 0 (wraparound)
  check_trace( 'h00c, 1, 5'd4, 32'h0000_0001 ); // x4 = x3 + x2 = 0 + 1 = 1

  t.test_case_end();
endtask

task test_case_6_x0();
  t.test_case_begin( "test_case_6_x0" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 1"  ); 
  asm( 'h004, "add  x0, x1, x1" ); 

  // Check each executed instruction
  //           addr   en reg   data 
  check_trace( 'h000, 1, 5'd1, 32'h0000_0001 ); // x1 = x0 + 1 = 1
  check_trace( 'h004, 1, 5'd0, 32'h0000_0000 ); // x0 is still zero

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

initial begin
  t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
  if ((t.n <= 0) || (t.n == 2)) test_case_2_fib();
  if ((t.n <= 0) || (t.n == 3)) test_case_3_powersoftwo();
  if ((t.n <= 0) || (t.n == 4)) test_case_4_zero();
  if ((t.n <= 0) || (t.n == 5)) test_case_5_wraparound();
  if ((t.n <= 0) || (t.n == 6)) test_case_6_x0();  

  t.test_bench_end();
end
