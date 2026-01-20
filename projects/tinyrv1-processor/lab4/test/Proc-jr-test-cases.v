//========================================================================
// Proc-jr-test-cases
//========================================================================

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x00c" );
  asm( 'h004, "jr   x1"            );
  asm( 'h008, "addi x1, x0, 2"     );
  asm( 'h00c, "addi x1, x0, 3"     );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_000c ); // addi x1, x0, 0x00c
  check_trace( 'h004, 0, 5'dx, 32'hxxxx_xxxx ); // jr   x1
  check_trace( 'h00c, 1, 5'd1, 32'h0000_0003 ); // addi x1, x0, 3

  t.test_case_end();
endtask

task test_case_2_directed_backward();
  t.test_case_begin( "test_case_2_directed_backward" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x000" );
  asm( 'h004, "addi x2, x0, 1"     );
  asm( 'h008, "jr   x1"            );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0000 ); // addi x1, x0, 0x000
  check_trace( 'h004, 1, 5'd2, 32'h0000_0001 ); // addi x2, x0, 1
  check_trace( 'h008, 0, 5'dx, 32'hxxxx_xxxx ); // jr   x1
  check_trace( 'h000, 1, 5'd1, 32'h0000_0000 ); // addi x2, x0, 1

  t.test_case_end();
endtask

task test_case_3_directed_zeros();
  t.test_case_begin( "test_case_3_directed_zeros" );

  // Write assembly program into memory

  asm( 'h000, "jr   x0"        );
  asm( 'h004, "addi x2, x0, 1" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 0, 5'dx, 32'hxxxx_xxxx ); // addi x1, x0, 0x00c
  check_trace( 'h000, 0, 5'dx, 32'hxxxx_xxxx ); // addi x2, x0, 1

  t.test_case_end();
endtask

task test_case_4_directed_jumpchain();
  t.test_case_begin( "test_case_4_directed_jumpchain" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x010" );
  asm( 'h004, "addi x2, x0, 0x020" );
  asm( 'h008, "addi x3, x0, 0x030" );
  asm( 'h00c, "jr   x1"            );
  asm( 'h010, "jr   x2"            );
  asm( 'h014, "addi x4, x0, 1"     );
  asm( 'h020, "jr   x3"            );
  asm( 'h024, "addi x5, x0, 2"     );
  asm( 'h030, "addi x6, x0, 100"   );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0010 ); // addi x1, x0, 0x010
  check_trace( 'h004, 1, 5'd2, 32'h0000_0020 ); // addi x2, x0, 0x020
  check_trace( 'h008, 1, 5'd3, 32'h0000_0030 ); // addi x3, x0, 0x030
  check_trace( 'h00c, 0, 5'dx, 32'hxxxx_xxxx ); // jr   x1
  check_trace( 'h010, 0, 5'dx, 32'hxxxx_xxxx ); // jr   x2
  check_trace( 'h020, 0, 5'dx, 32'hxxxx_xxxx ); // jr   x3
  check_trace( 'h030, 1, 5'd6, 32'h0000_0064 ); // addi x3, x0, 0x030

  t.test_case_end();
endtask

task test_case_5_directed_dependent();
  t.test_case_begin( "test_case_5_directed_dependent" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x004" );
  asm( 'h004, "addi x2, x0, 0x005" );
  asm( 'h008, "mul  x3, x1, x2"    );
  asm( 'h00c, "addi x4, x0, 0x100" );
  asm( 'h010, "sw  x3, 0(x4)"      );
  asm( 'h014, "lw  x5, 0(x4)"      );
  asm( 'h018, "jr  x5"             );
  asm( 'h01c, "addi x6, x0, 99"    );
  
  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0004 ); // addi x1, x0, 0x004
  check_trace( 'h004, 1, 5'd2, 32'h0000_0005 ); // addi x2, x0, 0x005
  check_trace( 'h008, 1, 5'd3, 32'h0000_0014 ); // mul  x3, x1, x2
  check_trace( 'h00c, 1, 5'd4, 32'h0000_0100 ); // addi x4, x0, 0x100
  check_trace( 'h010, 0, 5'dx, 32'hxxxx_xxxx ); // sw  x3, 0(x4)
  check_trace( 'h014, 1, 5'd5, 32'h0000_0014 ); // lw  x5, 0(x4)
  check_trace( 'h018, 0, 5'dx, 32'hxxxx_xxxx ); // addi x6, x0, 99

  t.test_case_end();
endtask

task test_case_6_directed_loop();
  t.test_case_begin( "test_case_6_directed_loop" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x004" );
  asm( 'h004, "jr x1"              );
  asm( 'h008, "addi x2, x0, 99"    );
  
  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0004 ); // addi x1, x0, 0x004
  check_trace( 'h004, 0, 5'dx, 32'hxxxx_xxxx ); // jr x1
  check_trace( 'h004, 0, 5'dx, 32'hxxxx_xxxx ); // jr x1
  check_trace( 'h004, 0, 5'dx, 32'hxxxx_xxxx ); // jr x1
  check_trace( 'h004, 0, 5'dx, 32'hxxxx_xxxx ); // jr x1

  t.test_case_end();
endtask

task test_case_7_directed_skip();
  t.test_case_begin( "test_case_7_directed_skip" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x01c" );
  asm( 'h004, "jr x1"              );
  asm( 'h008, "addi x2, x0, 1"     );
  asm( 'h00c, "addi x3, x0, 2"     );
  asm( 'h010, "addi x4, x0, 3"     );
  asm( 'h014, "addi x5, x0, 4"     );
  asm( 'h018, "addi x6, x0, 5"     );
  asm( 'h01c, "addi x7, x0, 100"   );
  
  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_001c ); // addi x1, x0, 0x004
  check_trace( 'h004, 0, 5'dx, 32'hxxxx_xxxx ); // jr x1
  check_trace( 'h01c, 1, 5'd7, 32'h0000_0064 ); // addi x7, x0, 100

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

initial begin
  t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1))              test_case_1_basic();
  if ((t.n <= 0) || (t.n == 2))  test_case_2_directed_backward();
  if ((t.n <= 0) || (t.n == 3))     test_case_3_directed_zeros();
  if ((t.n <= 0) || (t.n == 4)) test_case_4_directed_jumpchain();
  if ((t.n <= 0) || (t.n == 5)) test_case_5_directed_dependent();
  if ((t.n <= 0) || (t.n == 6))      test_case_6_directed_loop();
  if ((t.n <= 0) || (t.n == 7))      test_case_7_directed_skip();
  
  t.test_bench_end();
end
