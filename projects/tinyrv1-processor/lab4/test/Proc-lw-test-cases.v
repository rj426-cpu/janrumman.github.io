//========================================================================
// Proc-lw-test-cases
//========================================================================

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x100" );
  asm( 'h004, "lw   x2, 0(x1)"     );

  // Write data into memory

  data( 'h100, 'hdead_beef );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0100 ); // addi x1, x0, 0x100
  check_trace( 'h004, 1, 5'd2, 32'hdead_beef ); // lw   x2, 0(x1)

  t.test_case_end();
endtask

task test_case_2_directed_zero();
  t.test_case_begin( "test_case_2_directed_zero" );

  // Write assembly program into memory

  asm( 'h000, "lw   x1, 0x100(x0)" );

  // Write data into memory

  data( 'h100, 'hca11_3e );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'hca11_3e); // lw   x1, 0(x1) 

  t.test_case_end();
endtask

task test_case_3_directed_multiple();
  t.test_case_begin( "test_case_3_directed_multiple" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x100" );
  asm( 'h004, "addi x2, x0, 0x104" );
  asm( 'h008, "lw   x3, 0(x1)"     );
  asm( 'h00c, "lw   x4, 0(x2)"     );

  // Write data into memory

  data( 'h100, 'h1111_2222 );
  data( 'h104, 'h3333_4444 );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0100); // addi x1, x0, 0x100
  check_trace( 'h004, 1, 5'd2, 32'h0000_0104); // addi x2, x0, 0x104
  check_trace( 'h008, 1, 5'd3, 32'h1111_2222); // lw   x3, 0(x1)
  check_trace( 'h00c, 1, 5'd4, 32'h3333_4444); // lw   x4, 0(x2)

  t.test_case_end();
endtask

task test_case_4_directed_dependent();
  t.test_case_begin( "test_case_4_directed_dependent" );

  // Testing load dependency
  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x100" );
  asm( 'h004, "lw   x2, 0(x1)"     );
  asm( 'h008, "addi x3, x2, 1" );

  // Write data into memory

  data( 'h100, 'h0000_0001 );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0100); // addi x1, x0, 0x100
  check_trace( 'h004, 1, 5'd2, 32'h0000_0001); // lw   x2, 0(x1)
  check_trace( 'h008, 1, 5'd3, 32'h0000_0002); // addi x3, x2, 1
  
  t.test_case_end();
endtask

task test_case_5_directed_offset();
  t.test_case_begin( "test_case_5_directed_offset" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x100" );
  asm( 'h004, "lw   x2, 4(x1)"     );

  // Write data into memory

  data( 'h104, 'h1212_3434 );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0100); // addi x1, x0, 0x100
  check_trace( 'h004, 1, 5'd2, 32'h1212_3434); // lw   x2, 4(x1)
  
  t.test_case_end();
endtask

task test_case_6_directed_neg_offset();
  t.test_case_begin( "test_case_6_directed_neg_offset" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x104" );
  asm( 'h004, "lw   x2, -4(x1)"     );

  // Write data into memory

  data( 'h100, 'hdead_face );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0104); // addi x1, x0, 0x104
  check_trace( 'h004, 1, 5'd2, 32'hdead_face); // lw   x2, -4(x1)
  
  t.test_case_end();
endtask

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

initial begin
  t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1))               test_case_1_basic();
  if ((t.n <= 0) || (t.n == 2))       test_case_2_directed_zero();
  if ((t.n <= 0) || (t.n == 3))   test_case_3_directed_multiple();
  if ((t.n <= 0) || (t.n == 4))  test_case_4_directed_dependent();
  if ((t.n <= 0) || (t.n == 5))     test_case_5_directed_offset();
  if ((t.n <= 0) || (t.n == 6)) test_case_6_directed_neg_offset();

  t.test_bench_end();
end

