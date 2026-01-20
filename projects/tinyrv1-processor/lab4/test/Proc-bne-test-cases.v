//========================================================================
// Proc-bne-test-cases
//========================================================================

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 1" );
  asm( 'h004, "bne  x1, x0, 0x00c" );
  asm( 'h008, "addi x1, x0, 2" );
  asm( 'h00c, "addi x1, x0, 3" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0001 ); // addi x1, x0, 1
  check_trace( 'h004, 0, 5'dx, 32'hxxxx_xxxx ); // bne  x1, x0, 0x00c
  check_trace( 'h00c, 1, 5'd1, 32'h0000_0003 ); // addi x1, x0, 3

  t.test_case_end();
endtask

task test_case_2_branch_equal();
  t.test_case_begin( "test_case_2_branch_equal" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0" );
  asm( 'h004, "bne  x1, x0, 0x00c" );
  asm( 'h008, "addi x1, x0, 2" );
  asm( 'h00c, "addi x2, x0, 3" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0000 ); // addi x1, x0, 1
  check_trace( 'h004, 0, 5'dx, 32'hxxxx_xxxx ); // bne  x1, x0, 0x00c
  check_trace( 'h008, 1, 5'd1, 32'h0000_0002 ); // addi x1, x0, 2
  check_trace( 'h00c, 1, 5'd2, 32'h0000_0003 ); // addi x1, x0, 2

  t.test_case_end();
endtask

task test_case_3_not_equal();
  t.test_case_begin( "test_case_3_not_equal" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 3" );     // x1  = 3
  asm( 'h004, "bne  x1, x0, 0x00c" ); // x1 != x0 
  asm( 'h008, "addi x2, x0, 3" );     // skipped
  asm( 'h00c, "addi x2, x0, 9" );     // run, x2 = 9
  asm( 'h010, "bne  x2, x0, 0x018" ); // x2 != x0
  asm( 'h014, "bne  x1, x0, 0x01c" ); // skipped  
  asm( 'h018, "addi x3, x0, 1" );     // x3 = 1
  asm( 'h01c, "addi x4, x0, 1" );     
  
  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0003 ); // addi x1, x0, 3
  check_trace( 'h004, 0, 5'dx, 32'hxxxx_xxxx ); // bne  x1, x0, 0x00c
  check_trace( 'h00c, 1, 5'd2, 32'h0000_0009 ); // addi x1, x0, 3
  check_trace( 'h010, 0, 5'dx, 32'hxxxx_xxxx ); // bne  x2, x0, 0x018
  check_trace( 'h018, 1, 5'd3, 32'h0000_0001 ); // addi x3, x0, 1
  check_trace( 'h01c, 1, 5'd4, 32'h0000_0001 ); // addi x4, x0, 1

  t.test_case_end();
endtask

task test_case_4_jumps();
  t.test_case_begin( "test_case_4_jumps" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 1"     );
  asm( 'h004, "bne  x1, x0, 0x00c" );
  asm( 'h008, "addi x2, x0, 1"     );
  asm( 'h00c, "bne  x1, x0, 0x014" );
  asm( 'h010, "addi x3, x0, 1"     );
  asm( 'h014, "bne  x1, x0, 0x01c" );
  asm( 'h018, "addi x4, x0, 1"     );
  asm( 'h01c, "bne  x1, x0, 0x024" );
  asm( 'h020, "addi x5, x0, 1"     );
  asm( 'h024, "bne  x1, x0, 0x028" );
  asm( 'h028, "addi x6, x0, 1"     );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0001 ); // addi x1, x0, 1
  check_trace( 'h004, 0, 5'dx, 32'hxxxx_xxxx ); // bne  x1, x0, 0x00c
  check_trace( 'h00c, 0, 5'dx, 32'hxxxx_xxxx ); // bne  x1, x0, 0x014
  check_trace( 'h014, 0, 5'dx, 32'hxxxx_xxxx ); // bne  x1, x0, 0x01c
  check_trace( 'h01c, 0, 5'dx, 32'hxxxx_xxxx ); // bne  x1, x0, 0x024
  check_trace( 'h024, 0, 5'dx, 32'hxxxx_xxxx ); // bne  x1, x0, 0x028
  check_trace( 'h028, 1, 5'd6, 32'h0000_0001 ); // addi x6, x0, 1

  t.test_case_end();
endtask

task test_case_5_branch_to_last();
  t.test_case_begin( "test_case_2_branch_to_last" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 1"     );
  asm( 'h004, "bne  x1, x0, 0x018" );
  asm( 'h008, "addi x2, x0, 2"     ); // skipped
  asm( 'h00c, "addi x3, x0, 3"     ); // skipped
  asm( 'h010, "addi x4, x0, 4"     ); // skipped
  asm( 'h014, "addi x5, x0, 5"     ); // skipped
  asm( 'h018, "addi x6, x0, 6"     ); // executed

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0001 );
  check_trace( 'h004, 0, 5'dx, 32'hxxxx_xxxx );
  check_trace( 'h018, 1, 5'd6, 32'h0000_0006 );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

initial begin
  t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
  if ((t.n <= 0) || (t.n == 2)) test_case_2_branch_equal();
  if ((t.n <= 0) || (t.n == 3)) test_case_3_not_equal();
  if ((t.n <= 0) || (t.n == 4)) test_case_4_jumps();
  if ((t.n <= 0) || (t.n == 5)) test_case_5_branch_to_last();

  t.test_bench_end();
end
