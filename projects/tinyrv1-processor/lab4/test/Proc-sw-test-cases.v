//========================================================================
// Proc-sw-test-cases
//========================================================================

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x100" );
  asm( 'h004, "addi x2, x0, 0x42"  );
  asm( 'h008, "sw   x2, 0(x1)"     );
  asm( 'h00c, "lw   x3, 0(x1)"     );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0100 ); // addi x1, x0, 0x100
  check_trace( 'h004, 1, 5'd2, 32'h0000_0042 ); // addi x2, x0, 0x42
  check_trace( 'h008, 0, 5'dx, 32'hxxxx_xxxx ); // sw   x2, 0(x1)
  check_trace( 'h00c, 1, 5'd3, 32'h0000_0042 ); // lw   x3, 0(x1)

  t.test_case_end();
endtask

task test_case_2_directed_zero();
  t.test_case_begin( "test_case_2_directed_zero" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x100" );
  asm( 'h004, "sw   x0, 0(x1)" );
  asm( 'h008, "lw   x2, 0(x1)" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0100); // addi x1, x0, 0x100
  check_trace( 'h004, 0, 5'dx, 32'hxxxx_xxxx); // sw   x0, 0(x1)
  check_trace( 'h008, 1, 5'd2, 32'h0000_0000); // lw   x2, 0(x1)

  t.test_case_end();
endtask

task test_case_3_directed_multiple();
  t.test_case_begin( "test_case_3_directed_multiple" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x100" );
  asm( 'h004, "addi x2, x0, 0x104" );
  asm( 'h008, "sw   x1, 0(x1)"     );
  asm( 'h00c, "sw   x2, 0(x1)"     );
  asm( 'h010, "lw   x3, 0(x1)"     );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0100); // addi x1, x0, 0x100
  check_trace( 'h004, 1, 5'd2, 32'h0000_0104); // addi x2, x0, 0x104
  check_trace( 'h008, 0, 5'dx, 32'hxxxx_xxxx); // sw   x1, 0(x1)
  check_trace( 'h00c, 0, 5'dx, 32'hxxxx_xxxx); // sw   x2, 0(x1)
  check_trace( 'h010, 1, 5'd3, 32'h0000_0104); // lw   x3, 0(x1)

  t.test_case_end();
endtask

task test_case_4_directed_dependent();
  t.test_case_begin( "test_case_4_directed_dependent" );

  // Testing load dependency
  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x100" );
  asm( 'h004, "addi x2, x0, 0x024" );
  asm( 'h008, "add  x3, x2, x1"    );
  asm( 'h00c, "sw   x3, 0(x3)"     );
  asm( 'h010, "lw   x4, 0(x3)"     );
  
  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0100); // addi x1, x0, 0x100
  check_trace( 'h004, 1, 5'd2, 32'h0000_0024); // addi x2, x0, 0x024
  check_trace( 'h008, 1, 5'd3, 32'h0000_0124); // add  x3, x2, x1 (x3 = x2 + x1)
  check_trace( 'h00c, 0, 5'dx, 32'hxxxx_xxxx); // sw   x4, 0(x3)
  check_trace( 'h010, 1, 5'd4, 32'h0000_0124); // lw   x5, 0(x3)
  
  t.test_case_end();
endtask

task test_case_5_directed_offset();
  t.test_case_begin( "test_case_5_directed_offset" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x100" );
  asm( 'h004, "addi x2, x0, 0x111");
  asm( 'h008, "sw   x2, 4(x1)"     );
  asm( 'h00c, "lw   x3, 4(x1)"     );
  asm( 'h010, "lw   x4, 0(x1)"     );

  // Write data into memory

  data( 'h100, 'hcafe_babe );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0100); // addi x1, x0, 0x100
  check_trace( 'h004, 1, 5'd2, 32'h0000_0111); // addi x2, x0, 0x111
  check_trace( 'h008, 0, 5'dx, 32'hxxxx_xxxx); // sw   x2, 4(x1)
  check_trace( 'h00c, 1, 5'd3, 32'h0000_0111); // lw   x3, 4(x1)
  check_trace( 'h010, 1, 5'd4, 32'hcafe_babe); // lw   x4, 0(x1)
  
  t.test_case_end();
endtask

task test_case_6_directed_neg_offset();
  t.test_case_begin( "test_case_6_directed_neg_offset" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x104" );
  asm( 'h004, "addi x2, x0, 0x108" );
  asm( 'h008, "sw   x2, -4(x1)"    );
  asm( 'h00c, "lw   x3, -4(x1)"    );
  asm( 'h010, "lw   x4,  0(x1)"    );

  // Write data into memory

  data( 'h104, 'hdead_babe );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0104); // addi x1, x0, 0x104
  check_trace( 'h004, 1, 5'd2, 32'h0000_0108); // addi x2, x0, 0x108
  check_trace( 'h008, 0, 5'dx, 32'hxxxx_xxxx); // sw   x2, -4(x1)
  check_trace( 'h00c, 1, 5'd3, 32'h0000_0108); // lw   x3, -4(x1)
  check_trace( 'h010, 1, 5'd4, 32'hdead_babe); // lw   x4,  0(x1)
  
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
