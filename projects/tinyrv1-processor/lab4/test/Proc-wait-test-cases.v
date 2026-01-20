//========================================================================
// Proc-wait-test-cases
//========================================================================

string test_case_name;

//------------------------------------------------------------------------
// test_case_basic
//------------------------------------------------------------------------

task test_case_basic( int test_case_num, logic [31:0] random_wait );

  // Create a test case name based on given arguments

  $sformat( test_case_name, "test_case_%0d_basic_wait%0d",
            test_case_num, random_wait );

  t.test_case_begin( test_case_name );

  // Set the max memory delay (use test_case_num as seed, random_wait is
  // the probability of a memory interface waiting, 50 = 50%)

  set_random_wait( test_case_num, random_wait );

  // Write assembly program into memory

  asm( 'h000, "addi x1,  x0,  1"     );
  asm( 'h004, "addi x2,  x1,  2"    );
  asm( 'h008, "addi x3,  x2,  3"    );
  asm( 'h00c, "addi x4,  x3,  4"    );
  asm( 'h010, "addi x5,  x4,  5"    );
  asm( 'h014, "addi x6,  x5,  6"    );
  asm( 'h018, "addi x7,  x6,  7"    );
  asm( 'h01c, "addi x8,  x7,  8"    );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1,  1 ); // addi x1,  x0,  1
  check_trace( 'h004, 1, 5'd2,  3 ); // addi x2,  x1,  2
  check_trace( 'h008, 1, 5'd3,  6 ); // addi x3,  x2,  3
  check_trace( 'h00c, 1, 5'd4, 10 ); // addi x4,  x3,  4
  check_trace( 'h010, 1, 5'd5, 15 ); // addi x5,  x4,  5
  check_trace( 'h014, 1, 5'd6, 21 ); // addi x6,  x5,  6
  check_trace( 'h018, 1, 5'd7, 28 ); // addi x7,  x6,  7
  check_trace( 'h01c, 1, 5'd8, 36 ); // addi x8,  x7,  8

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_add
//------------------------------------------------------------------------

task test_case_add( int test_case_num, logic [31:0] random_wait );

  // Create a test case name based on given arguments

  $sformat( test_case_name, "test_case_%0d_add_wait%0d",
            test_case_num, random_wait );

  t.test_case_begin( test_case_name );

  // Set the max memory delay (use test_case_num as seed)

  set_random_wait( test_case_num, random_wait );

  // Write assembly program into memory

  asm( 'h000, "addi x1,  x0,  1"     );
  asm( 'h004, "add  x2,  x1,  x0"    );
  asm( 'h008, "add  x3,  x2,  x1"    );
  asm( 'h00c, "add  x4,  x3,  x2"    );
  asm( 'h010, "add  x5,  x4,  x3"    );
  asm( 'h014, "add  x6,  x5,  x4"    );
  asm( 'h018, "add  x7,  x6,  x5"    );
  asm( 'h01c, "add  x8,  x7,  x6"    );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1,  1 ); // addi x1,  x0,  1
  check_trace( 'h004, 1, 5'd2,  1 ); // add  x2,  x1,  x0
  check_trace( 'h008, 1, 5'd3,  2 ); // add  x3,  x2,  x1
  check_trace( 'h00c, 1, 5'd4,  3 ); // add  x4,  x3,  x2
  check_trace( 'h010, 1, 5'd5,  5 ); // add  x5,  x4,  x3
  check_trace( 'h014, 1, 5'd6,  8 ); // add  x6,  x5,  x4
  check_trace( 'h018, 1, 5'd7, 13 ); // add  x7,  x6,  x5
  check_trace( 'h01c, 1, 5'd8, 21 ); // add  x8,  x7,  x6

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_mul
//------------------------------------------------------------------------

task test_case_mul( int test_case_num, logic [31:0] random_wait );

  // Create a test case name based on given arguments

  $sformat( test_case_name, "test_case_%0d_mul_wait%0d",
            test_case_num, random_wait );

  t.test_case_begin( test_case_name );

  // Set the max memory delay (use test_case_num as seed)

  set_random_wait( test_case_num, random_wait );

  // Write assembly program into memory

  asm( 'h000, "addi x1,  x0,  1"    );
  asm( 'h004, "addi x2,  x0,  2"    );
  asm( 'h008, "mul  x3,  x1, x0"    );
  asm( 'h00c, "mul  x3,  x2, x1"    );
  asm( 'h010, "mul  x4,  x3, x3"    );
  asm( 'h014, "mul  x5,  x4, x4"    );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1,  1 ); // addi x1,  x0,  1
  check_trace( 'h004, 1, 5'd2,  2 ); // addi x2,  x0,  2
  check_trace( 'h008, 1, 5'd3,  0 ); // mul  x3,  x1, x0
  check_trace( 'h00c, 1, 5'd3,  2 ); // mul  x3,  x2, x1
  check_trace( 'h010, 1, 5'd4,  4 ); // mul  x4,  x3, x3
  check_trace( 'h014, 1, 5'd5, 16 ); // mul  x5,  x4, x4

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_lw
//------------------------------------------------------------------------

task test_case_lw( int test_case_num, logic [31:0] random_wait );

  // Create a test case name based on given arguments

  $sformat( test_case_name, "test_case_%0d_lw_wait%0d",
            test_case_num, random_wait );

  t.test_case_begin( test_case_name );

  // Set the max memory delay (use test_case_num as seed)

  set_random_wait( test_case_num, random_wait );

  // Write assembly program into memory

  asm( 'h000, "addi x1,  x0, 0x100" );
  asm( 'h004, "addi x2,  x0, 0x104" );
  asm( 'h008, "addi x3,  x0, 0x108" );
  asm( 'h00c, "addi x4,  x0, 0x10c" );

  asm( 'h010, "addi x28, x0, 0x110" );
  asm( 'h014, "addi x29, x0, 0x114" );
  asm( 'h018, "addi x30, x0, 0x118" );
  asm( 'h01c, "addi x31, x0, 0x11c" );

  asm( 'h020, "lw   x5, 0(x1)"     );
  asm( 'h024, "lw   x6, 0(x2)"     );
  asm( 'h028, "lw   x7, 0(x3)"     );
  asm( 'h02c, "lw   x8, 0(x4)"     );

  asm( 'h030, "lw   x5, 0(x28)"    );
  asm( 'h034, "lw   x6, 0(x29)"    );
  asm( 'h038, "lw   x7, 0(x30)"    );
  asm( 'h03c, "lw   x8, 0(x31)"    );

  // Write data into memory

  data( 'h100, 'h0101_0101 );
  data( 'h104, 'h0202_0202 );
  data( 'h108, 'h0303_0303 );
  data( 'h10c, 'h0404_0404 );

  data( 'h110, 'h0505_0505 );
  data( 'h114, 'h0606_0606 );
  data( 'h118, 'h0707_0707 );
  data( 'h11c, 'h0808_0808 );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1,  32'h0000_0100 ); // addi x1,  x0, 0x100
  check_trace( 'h004, 1, 5'd2,  32'h0000_0104 ); // addi x2,  x0, 0x104
  check_trace( 'h008, 1, 5'd3,  32'h0000_0108 ); // addi x3,  x0, 0x108
  check_trace( 'h00c, 1, 5'd4,  32'h0000_010c ); // addi x4,  x0, 0x10c

  check_trace( 'h010, 1, 5'd28, 32'h0000_0110 ); // addi x28, x0, 0x110
  check_trace( 'h014, 1, 5'd29, 32'h0000_0114 ); // addi x29, x0, 0x114
  check_trace( 'h018, 1, 5'd30, 32'h0000_0118 ); // addi x30, x0, 0x118
  check_trace( 'h01c, 1, 5'd31, 32'h0000_011c ); // addi x31, x0, 0x11c

  check_trace( 'h020, 1, 5'd5,  32'h0101_0101 ); // lw   x5, 0(x1)
  check_trace( 'h024, 1, 5'd6,  32'h0202_0202 ); // lw   x6, 0(x2)
  check_trace( 'h028, 1, 5'd7,  32'h0303_0303 ); // lw   x7, 0(x3)
  check_trace( 'h02c, 1, 5'd8,  32'h0404_0404 ); // lw   x8, 0(x4)

  check_trace( 'h030, 1, 5'd5,  32'h0505_0505 ); // lw   x5, 0(x28)
  check_trace( 'h034, 1, 5'd6,  32'h0606_0606 ); // lw   x6, 0(x29)
  check_trace( 'h038, 1, 5'd7,  32'h0707_0707 ); // lw   x7, 0(x30)
  check_trace( 'h03c, 1, 5'd8,  32'h0808_0808 ); // lw   x8, 0(x31)

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_sw
//------------------------------------------------------------------------

task test_case_sw( int test_case_num, logic [31:0] random_wait );

  // Create a test case name based on given arguments

  $sformat( test_case_name, "test_case_%0d_sw_wait%0d",
            test_case_num, random_wait );

  t.test_case_begin( test_case_name );

  // Set the max memory delay (use test_case_num as seed)

  set_random_wait( test_case_num, random_wait );

  // Write assembly program into memory

  asm( 'h000, "addi x1,  x0, 0x100" );

  asm( 'h004, "addi x2,  x0, 20"    );
  asm( 'h008, "addi x3,  x0, 21"    );
  asm( 'h00c, "addi x4,  x0, 22"    );
  asm( 'h010, "addi x5,  x0, 23"    );

  asm( 'h014, "sw   x2,  0(x1)"     );
  asm( 'h018, "sw   x3,  4(x1)"     );
  asm( 'h01c, "sw   x4,  8(x1)"     );
  asm( 'h020, "sw   x5,  12(x1)"    );

  asm( 'h024, "lw   x7,  0(x1)"     );
  asm( 'h028, "lw   x8,  4(x1)"     );
  asm( 'h02c, "lw   x9,  8(x1)"     );
  asm( 'h030, "lw   x10, 12(x1)"    );

  // Write data into memory

  data( 'h100, 'hdead_beef );
  data( 'h104, 'hdead_beef );
  data( 'h108, 'hdead_beef );
  data( 'h10c, 'hdead_beef );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1,  32'h0000_0100 ); // addi x1,  x0, 0x100

  check_trace( 'h004, 1, 5'd2,  32'h0000_0014 ); // addi x2,  x0, 20
  check_trace( 'h008, 1, 5'd3,  32'h0000_0015 ); // addi x3,  x0, 21
  check_trace( 'h00c, 1, 5'd4,  32'h0000_0016 ); // addi x4,  x0, 22
  check_trace( 'h010, 1, 5'd5,  32'h0000_0017 ); // addi x5,  x0, 23

  check_trace( 'h014, 0, 5'dx,  32'hxxxx_xxxx ); // sw   x2,  0(x1)
  check_trace( 'h018, 0, 5'dx,  32'hxxxx_xxxx ); // sw   x3,  4(x1)
  check_trace( 'h01c, 0, 5'dx,  32'hxxxx_xxxx ); // sw   x4,  8(x1)
  check_trace( 'h020, 0, 5'dx,  32'hxxxx_xxxx ); // sw   x5,  12(x1)

  check_trace( 'h024, 1, 5'd7,  32'h0000_0014 ); // lw   x7,  0(x1)
  check_trace( 'h028, 1, 5'd8,  32'h0000_0015 ); // lw   x8,  4(x1)
  check_trace( 'h02c, 1, 5'd9,  32'h0000_0016 ); // lw   x9,  8(x1)
  check_trace( 'h030, 1, 5'd10, 32'h0000_0017 ); // lw   x10, 12(x1)

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_jal
//------------------------------------------------------------------------

task test_case_jal( int test_case_num, logic [31:0] random_wait );

  // Create a test case name based on given arguments

  $sformat( test_case_name, "test_case_%0d_jal_wait%0d",
            test_case_num, random_wait );

  t.test_case_begin( test_case_name );

  // Set the max memory delay (use test_case_num as seed)

  set_random_wait( test_case_num, random_wait );

  // Write assembly program into memory

  asm( 'h000, "addi x1,  x0,  6"     );
  asm( 'h004, "addi x1,  x1,  -1"    );
  asm( 'h008, "jal  x2,  0x004"      );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1,             6 ); // addi x1,  x0,  6
  check_trace( 'h004, 1, 5'd1,             5 ); // addi x1,  x1,  -1
  check_trace( 'h008, 1, 5'd2, 32'h0000_000c ); // jal  x1,  0x004

  check_trace( 'h004, 1, 5'd1,             4 ); // addi x1,  x1,  -1
  check_trace( 'h008, 1, 5'd2, 32'h0000_000c ); // jal  x1,  0x004

  check_trace( 'h004, 1, 5'd1,             3 ); // addi x1,  x1,  -1
  check_trace( 'h008, 1, 5'd2, 32'h0000_000c ); // jal  x1,  0x004

  check_trace( 'h004, 1, 5'd1,             2 ); // addi x1,  x1,  -1
  check_trace( 'h008, 1, 5'd2, 32'h0000_000c ); // jal  x1,  0x004

  check_trace( 'h004, 1, 5'd1,             1 ); // addi x1,  x1,  -1
  check_trace( 'h008, 1, 5'd2, 32'h0000_000c ); // jal  x1,  0x004

  check_trace( 'h004, 1, 5'd1,             0 ); // addi x1,  x1,  -1
  check_trace( 'h008, 1, 5'd2, 32'h0000_000c ); // jal  x1,  0x004

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_jr
//------------------------------------------------------------------------

task test_case_jr( int test_case_num, logic [31:0] random_wait );

  // Create a test case name based on given arguments

  $sformat( test_case_name, "test_case_%0d_jr_wait%0d",
            test_case_num, random_wait );

  t.test_case_begin( test_case_name );

  // Set the max memory delay (use test_case_num as seed)

  set_random_wait( test_case_num, random_wait );

  // Write assembly program into memory

  asm( 'h000, "addi x1,  x0,  6"     );
  asm( 'h004, "addi x2,  x0,  0x008" );
  asm( 'h008, "addi x1,  x1,  -1"    );
  asm( 'h00c, "jr   x2"              );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1,             6 ); // addi x1,  x0,  6
  check_trace( 'h004, 1, 5'd2, 32'h0000_0008 ); // addi x2,  x0,  0x004
  check_trace( 'h008, 1, 5'd1,             5 ); // addi x1,  x1,  -1
  check_trace( 'h00c, 0, 5'dx,            'x ); // jr   x2

  check_trace( 'h008, 1, 5'd1,             4 ); // addi x1,  x1,  -1
  check_trace( 'h00c, 0, 5'dx,            'x ); // jr   x2

  check_trace( 'h008, 1, 5'd1,             3 ); // addi x1,  x1,  -1
  check_trace( 'h00c, 0, 5'dx,            'x ); // jr   x2

  check_trace( 'h008, 1, 5'd1,             2 ); // addi x1,  x1,  -1
  check_trace( 'h00c, 0, 5'dx,            'x ); // jr   x2

  check_trace( 'h008, 1, 5'd1,             1 ); // addi x1,  x1,  -1
  check_trace( 'h00c, 0, 5'dx,            'x ); // jr   x2

  check_trace( 'h008, 1, 5'd1,             0 ); // addi x1,  x1,  -1
  check_trace( 'h00c, 0, 5'dx,            'x ); // jr   x2

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_bne
//------------------------------------------------------------------------

task test_case_bne( int test_case_num, logic [31:0] random_wait );

  // Create a test case name based on given arguments

  $sformat( test_case_name, "test_case_%0d_bne_wait%0d",
            test_case_num, random_wait );

  t.test_case_begin( test_case_name );

  // Set the max memory delay (use test_case_num as seed)

  set_random_wait( test_case_num, random_wait );

  // Write assembly program into memory

  asm( 'h000, "addi x1,  x0,  6"     );
  asm( 'h004, "addi x1,  x1,  -1"    );
  asm( 'h008, "bne  x1,  x0,  0x004" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1,  6 ); // addi x1,  x0,  6
  check_trace( 'h004, 1, 5'd1,  5 ); // addi x1,  x1,  -1
  check_trace( 'h008, 0, 5'dx, 'x ); // bne  x1,  x0,  0x004

  check_trace( 'h004, 1, 5'd1,  4 ); // addi x1,  x1,  -1
  check_trace( 'h008, 0, 5'dx, 'x ); // bne  x1,  x0,  0x004

  check_trace( 'h004, 1, 5'd1,  3 ); // addi x1,  x1,  -1
  check_trace( 'h008, 0, 5'dx, 'x ); // bne  x1,  x0,  0x004

  check_trace( 'h004, 1, 5'd1,  2 ); // addi x1,  x1,  -1
  check_trace( 'h008, 0, 5'dx, 'x ); // bne  x1,  x0,  0x004

  check_trace( 'h004, 1, 5'd1,  1 ); // addi x1,  x1,  -1
  check_trace( 'h008, 0, 5'dx, 'x ); // bne  x1,  x0,  0x004

  check_trace( 'h004, 1, 5'd1,  0 ); // addi x1,  x1,  -1
  check_trace( 'h008, 0, 5'dx, 'x ); // bne  x1,  x0,  0x004

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

initial begin
  t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1)) test_case_basic(1,25);
  if ((t.n <= 0) || (t.n == 2)) test_case_basic(2,50);
  if ((t.n <= 0) || (t.n == 3)) test_case_basic(3,75);

  if ((t.n <= 0) || (t.n == 4)) test_case_add(4,25);
  if ((t.n <= 0) || (t.n == 5)) test_case_add(5,50);
  if ((t.n <= 0) || (t.n == 6)) test_case_add(6,75);

  if ((t.n <= 0) || (t.n == 7)) test_case_mul(7,25);
  if ((t.n <= 0) || (t.n == 8)) test_case_mul(8,50);
  if ((t.n <= 0) || (t.n == 9)) test_case_mul(9,75);

  if ((t.n <= 0) || (t.n == 10)) test_case_lw(10,25);
  if ((t.n <= 0) || (t.n == 11)) test_case_lw(11,50);
  if ((t.n <= 0) || (t.n == 12)) test_case_lw(12,75);

  if ((t.n <= 0) || (t.n == 13)) test_case_sw(13,25);
  if ((t.n <= 0) || (t.n == 14)) test_case_sw(14,50);
  if ((t.n <= 0) || (t.n == 15)) test_case_sw(15,75);

  if ((t.n <= 0) || (t.n == 16)) test_case_jal(16,25);
  if ((t.n <= 0) || (t.n == 17)) test_case_jal(17,50);
  if ((t.n <= 0) || (t.n == 18)) test_case_jal(18,75);

  if ((t.n <= 0) || (t.n == 19)) test_case_jr(19,25);
  if ((t.n <= 0) || (t.n == 20)) test_case_jr(20,50);
  if ((t.n <= 0) || (t.n == 21)) test_case_jr(21,75);

  if ((t.n <= 0) || (t.n == 22)) test_case_bne(22,25);
  if ((t.n <= 0) || (t.n == 23)) test_case_bne(23,50);
  if ((t.n <= 0) || (t.n == 24)) test_case_bne(24,75);

  t.test_bench_end();
end
