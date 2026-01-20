//========================================================================
// tinyrv1-test
//========================================================================
// These tests were created by using the RISC-V GNU assembler to generate
// the correct machine instructions as follows:
//
//  % echo "SECTIONS{ . = 0x000000; }" > test.ld
//  % echo "add x0, x0, x0" > test.S
//  % riscv64-linux-gnu-as -o test.o test.S
//  % riscv64-linux-gnu-ld -T test.ld -o test test.o
//  % riscv64-linux-gnu-objdump -d -Mno-aliases -Mnumeric test
//  0000000000000000 <.text>:
//  0:  00000033  add x0,x0,x0
//

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/tinyrv1.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  CombinationalTestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  TinyRV1 tinyrv1();

  //----------------------------------------------------------------------
  // check_asm
  //----------------------------------------------------------------------

  logic [31:0] inst;

  task check_asm
  (
    input logic [31:0] addr,
    input string       asm,
    input logic [31:0] inst_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      inst = tinyrv1.asm( addr, asm ) ;

      #8;

      if ( t.n != 0 ) begin
        $display( "%3d: %x %-20s > %x", t.cycles, addr, asm, inst );
      end

      `ECE2300_CHECK_EQ_HEX( inst, inst_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_asm_add
  //----------------------------------------------------------------------

  task test_case_1_asm_add();
    t.test_case_begin( "test_case_1_asm_add" );

    check_asm( 0, "add x0, x0, x0",    32'h00000033 );
    check_asm( 0, "add x0, x0, x1",    32'h00100033 );
    check_asm( 0, "add x0, x1, x1",    32'h00108033 );
    check_asm( 0, "add x1, x1, x0",    32'h000080b3 );
    check_asm( 0, "add x1, x1, x1",    32'h001080b3 );
    check_asm( 0, "add x1, x2, x3",    32'h003100b3 );
    check_asm( 0, "add x4, x5, x6",    32'h00628233 );
    check_asm( 0, "add x31, x30, x29", 32'h01df0fb3 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_2_asm_addi
  //----------------------------------------------------------------------

  task test_case_2_asm_addi();
    t.test_case_begin( "test_case_2_asm_addi" );

    check_asm( 0, "addi x0, x0, 0",     32'h00000013 );
    check_asm( 0, "addi x1, x0, 0",     32'h00000093 );
    check_asm( 0, "addi x2, x0, 0",     32'h00000113 );
    check_asm( 0, "addi x31, x0, 0",    32'h00000f93 );

    check_asm( 0, "addi x1, x0, 0",     32'h00000093 );
    check_asm( 0, "addi x1, x2, 0",     32'h00010093 );
    check_asm( 0, "addi x2, x1, 0",     32'h00008113 );
    check_asm( 0, "addi x31, x30, 0",   32'h000f0f93 );

    check_asm( 0, "addi x1, x0, 1",     32'h00100093 );
    check_asm( 0, "addi x1, x2, 1",     32'h00110093 );
    check_asm( 0, "addi x2, x1, 1",     32'h00108113 );
    check_asm( 0, "addi x31, x30, 1",   32'h001f0f93 );

    check_asm( 0, "addi x1, x0, 1",     32'h00100093 );
    check_asm( 0, "addi x1, x0, 2",     32'h00200093 );
    check_asm( 0, "addi x1, x0, 3",     32'h00300093 );
    check_asm( 0, "addi x1, x0, 32",    32'h02000093 );
    check_asm( 0, "addi x1, x0, 2047",  32'h7ff00093 );

    check_asm( 0, "addi x1, x0, -1",    32'hfff00093 );
    check_asm( 0, "addi x1, x0, -2",    32'hffe00093 );
    check_asm( 0, "addi x1, x0, -3",    32'hffd00093 );
    check_asm( 0, "addi x1, x0, -32",   32'hfe000093 );
    check_asm( 0, "addi x1, x0, -2048", 32'h80000093 );

    check_asm( 0, "addi x1, x0, 0x1",   32'h00100093 );
    check_asm( 0, "addi x1, x0, 0x01",  32'h00100093 );
    check_asm( 0, "addi x1, x0, 0x001", 32'h00100093 );

    check_asm( 0, "addi x1, x0, 0x1",   32'h00100093 );
    check_asm( 0, "addi x1, x0, 0x2",   32'h00200093 );
    check_asm( 0, "addi x1, x0, 0x3",   32'h00300093 );
    check_asm( 0, "addi x1, x0, 0x20",  32'h02000093 );
    check_asm( 0, "addi x1, x0, 0x7ff", 32'h7ff00093 );

    check_asm( 0, "addi x1, x0, 0xfff", 32'hfff00093 );
    check_asm( 0, "addi x1, x0, 0xffe", 32'hffe00093 );
    check_asm( 0, "addi x1, x0, 0xffd", 32'hffd00093 );
    check_asm( 0, "addi x1, x0, 0xfe0", 32'hfe000093 );
    check_asm( 0, "addi x1, x0, 0x800", 32'h80000093 );

    check_asm( 0, "addi x1, x0, 0b1",   32'h00100093 );
    check_asm( 0, "addi x1, x0, 0b01",  32'h00100093 );
    check_asm( 0, "addi x1, x0, 0b001", 32'h00100093 );
    check_asm( 0, "addi x1, x0, 0b10",  32'h00200093 );
    check_asm( 0, "addi x1, x0, 0b11",  32'h00300093 );
    check_asm( 0, "addi x1, x0, 0b100000", 32'h02000093 );
    check_asm( 0, "addi x1, x0, 0b111_1111_1111", 32'h7ff00093 );

    check_asm( 0, "addi x1, x0, 0b1111_1111_1111", 32'hfff00093 );
    check_asm( 0, "addi x1, x0, 0b1111_1111_1110", 32'hffe00093 );
    check_asm( 0, "addi x1, x0, 0b1111_1111_1101", 32'hffd00093 );
    check_asm( 0, "addi x1, x0, 0b1111_1110_0000", 32'hfe000093 );
    check_asm( 0, "addi x1, x0, 0b1000_0000_0000", 32'h80000093 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_asm_mul
  //----------------------------------------------------------------------

  task test_case_3_asm_mul();
    t.test_case_begin( "test_case_3_asm_mul" );

    check_asm( 0, "mul x0, x0, x0",    32'h02000033 );
    check_asm( 0, "mul x0, x0, x1",    32'h02100033 );
    check_asm( 0, "mul x0, x1, x1",    32'h02108033 );
    check_asm( 0, "mul x1, x1, x0",    32'h020080b3 );
    check_asm( 0, "mul x1, x1, x1",    32'h021080b3 );
    check_asm( 0, "mul x1, x2, x3",    32'h023100b3 );
    check_asm( 0, "mul x4, x5, x6",    32'h02628233 );
    check_asm( 0, "mul x31, x30, x29", 32'h03df0fb3 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_4_asm_lw
  //----------------------------------------------------------------------

  task test_case_4_asm_lw();
    t.test_case_begin( "test_case_4_asm_lw" );

    check_asm( 0, "lw x0, 0(x0)",      32'h00002003 );
    check_asm( 0, "lw x1, 0(x0)",      32'h00002083 );
    check_asm( 0, "lw x2, 0(x0)",      32'h00002103 );
    check_asm( 0, "lw x31, 0(x0)",     32'h00002f83 );

    check_asm( 0, "lw x1, 0(x0)",      32'h00002083 );
    check_asm( 0, "lw x1, 0(x2)",      32'h00012083 );
    check_asm( 0, "lw x2, 0(x1)",      32'h0000a103 );
    check_asm( 0, "lw x31, 0(x30)",    32'h000f2f83 );

    check_asm( 0, "lw x0, 4(x0)",      32'h00402003 );
    check_asm( 0, "lw x1, 4(x0)",      32'h00402083 );
    check_asm( 0, "lw x1, 4(x2)",      32'h00412083 );
    check_asm( 0, "lw x2, 4(x1)",      32'h0040a103 );
    check_asm( 0, "lw x31, 4(x30)",    32'h004f2f83 );

    check_asm( 0, "lw x1, 1(x2)",      32'h00112083 );
    check_asm( 0, "lw x1, 4(x2)",      32'h00412083 );
    check_asm( 0, "lw x1, 8(x2)",      32'h00812083 );
    check_asm( 0, "lw x1, 12(x2)",     32'h00c12083 );
    check_asm( 0, "lw x1, 32(x2)",     32'h02012083 );
    check_asm( 0, "lw x1, 2044(x2)",   32'h7fc12083 );

    check_asm( 0, "lw x1, -1(x2)",     32'hfff12083 );
    check_asm( 0, "lw x1, -4(x2)",     32'hffc12083 );
    check_asm( 0, "lw x1, -8(x2)",     32'hff812083 );
    check_asm( 0, "lw x1, -12(x2)",    32'hff412083 );
    check_asm( 0, "lw x1, -32(x2)",    32'hfe012083 );
    check_asm( 0, "lw x1, -2048(x2)",  32'h80012083 );

    check_asm( 0, "lw x1, 0x4(x2)",    32'h00412083 );
    check_asm( 0, "lw x1, 0x04(x2)",   32'h00412083 );
    check_asm( 0, "lw x1, 0x004(x2)",  32'h00412083 );

    check_asm( 0, "lw x1, 0x1(x2)",    32'h00112083 );
    check_asm( 0, "lw x1, 0x4(x2)",    32'h00412083 );
    check_asm( 0, "lw x1, 0x8(x2)",    32'h00812083 );
    check_asm( 0, "lw x1, 0xc(x2)",    32'h00c12083 );
    check_asm( 0, "lw x1, 0x20(x2)",   32'h02012083 );
    check_asm( 0, "lw x1, 0x7fc(x2)",  32'h7fc12083 );

    // These don't assemble using the GNU assembler?
    check_asm( 0, "lw x1, 0xffc(x2)",  32'hffc12083 );
    check_asm( 0, "lw x1, 0xff8(x2)",  32'hff812083 );
    check_asm( 0, "lw x1, 0xff4(x2)",  32'hff412083 );
    check_asm( 0, "lw x1, 0xfe0(x2)",  32'hfe012083 );
    check_asm( 0, "lw x1, 0x800(x2)",  32'h80012083 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_5_asm_sw
  //----------------------------------------------------------------------

  task test_case_5_asm_sw();
    t.test_case_begin( "test_case_5_asm_sw" );

    check_asm( 0, "sw x0, 0(x0)",      32'h00002023 );
    check_asm( 0, "sw x1, 0(x0)",      32'h00102023 );
    check_asm( 0, "sw x2, 0(x0)",      32'h00202023 );
    check_asm( 0, "sw x31, 0(x0)",     32'h01f02023 );

    check_asm( 0, "sw x1, 0(x0)",      32'h00102023 );
    check_asm( 0, "sw x1, 0(x2)",      32'h00112023 );
    check_asm( 0, "sw x2, 0(x1)",      32'h0020a023 );
    check_asm( 0, "sw x31, 0(x30)",    32'h01ff2023 );

    check_asm( 0, "sw x0, 4(x0)",      32'h00002223 );
    check_asm( 0, "sw x1, 4(x0)",      32'h00102223 );
    check_asm( 0, "sw x1, 4(x2)",      32'h00112223 );
    check_asm( 0, "sw x2, 4(x1)",      32'h0020a223 );
    check_asm( 0, "sw x31, 4(x30)",    32'h01ff2223 );

    check_asm( 0, "sw x1, 1(x2)",      32'h001120a3 );
    check_asm( 0, "sw x1, 4(x2)",      32'h00112223 );
    check_asm( 0, "sw x1, 8(x2)",      32'h00112423 );
    check_asm( 0, "sw x1, 12(x2)",     32'h00112623 );
    check_asm( 0, "sw x1, 32(x2)",     32'h02112023 );
    check_asm( 0, "sw x1, 2044(x2)",   32'h7e112e23 );

    check_asm( 0, "sw x1, -1(x2)",     32'hfe112fa3 );
    check_asm( 0, "sw x1, -4(x2)",     32'hfe112e23 );
    check_asm( 0, "sw x1, -8(x2)",     32'hfe112c23 );
    check_asm( 0, "sw x1, -12(x2)",    32'hfe112a23 );
    check_asm( 0, "sw x1, -32(x2)",    32'hfe112023 );
    check_asm( 0, "sw x1, -2048(x2)",  32'h80112023 );

    check_asm( 0, "sw x1, 0x4(x2)",    32'h00112223 );
    check_asm( 0, "sw x1, 0x04(x2)",   32'h00112223 );
    check_asm( 0, "sw x1, 0x004(x2)",  32'h00112223 );

    check_asm( 0, "sw x1, 0x1(x2)",    32'h001120a3 );
    check_asm( 0, "sw x1, 0x4(x2)",    32'h00112223 );
    check_asm( 0, "sw x1, 0x8(x2)",    32'h00112423 );
    check_asm( 0, "sw x1, 0xc(x2)",    32'h00112623 );
    check_asm( 0, "sw x1, 0x20(x2)",   32'h02112023 );
    check_asm( 0, "sw x1, 0x7fc(x2)",  32'h7e112e23 );

    // These don't assemble using the GNU assembler?
    check_asm( 0, "sw x1, 0xffc(x2)",  32'hfe112e23 );
    check_asm( 0, "sw x1, 0xff8(x2)",  32'hfe112c23 );
    check_asm( 0, "sw x1, 0xff4(x2)",  32'hfe112a23 );
    check_asm( 0, "sw x1, 0xfe0(x2)",  32'hfe112023 );
    check_asm( 0, "sw x1, 0x800(x2)",  32'h80112023 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_6_asm_jal
  //----------------------------------------------------------------------

  task test_case_6_asm_jal();
    t.test_case_begin( "test_case_6_asm_jal" );

    check_asm(   0, "jal x0, 0",      32'h0000006f );
    check_asm(   0, "jal x1, 0",      32'h000000ef );
    check_asm(   0, "jal x2, 0",      32'h0000016f );
    check_asm(   0, "jal x31, 0",     32'h00000fef );

    check_asm(   0, "jal x1, 4",      32'h004000ef );
    check_asm(   0, "jal x1, 8",      32'h008000ef );
    check_asm(   0, "jal x1, 12",     32'h00c000ef );

    check_asm(  12, "jal x1,  0",     32'hff5ff0ef );
    check_asm(  12, "jal x1,  4",     32'hff9ff0ef );
    check_asm(  12, "jal x1,  8",     32'hffdff0ef );
    check_asm(  12, "jal x1, 12",     32'h000000ef );
    check_asm(  12, "jal x1, 16",     32'h004000ef );
    check_asm(  12, "jal x1, 20",     32'h008000ef );
    check_asm(  12, "jal x1, 24",     32'h00c000ef );

    check_asm( 'hc, "jal x1, 0x00",   32'hff5ff0ef );
    check_asm( 'hc, "jal x1, 0x04",   32'hff9ff0ef );
    check_asm( 'hc, "jal x1, 0x08",   32'hffdff0ef );
    check_asm( 'hc, "jal x1, 0x0c",   32'h000000ef );

    check_asm( 'hc, "jal x1, 0x10",   32'h004000ef );
    check_asm( 'hc, "jal x1, 0x14",   32'h008000ef );
    check_asm( 'hc, "jal x1, 0x18",   32'h00c000ef );
    check_asm( 'hc, "jal x1, 0x1c",   32'h010000ef );

    check_asm( 'hc, "jal x1, 0x20",   32'h014000ef );
    check_asm( 'hc, "jal x1, 0x24",   32'h018000ef );
    check_asm( 'hc, "jal x1, 0x28",   32'h01c000ef );
    check_asm( 'hc, "jal x1, 0x2c",   32'h020000ef );

    check_asm( 'hc, "jal x1, 0x30",   32'h024000ef );
    check_asm( 'hc, "jal x1, 0x34",   32'h028000ef );
    check_asm( 'hc, "jal x1, 0x38",   32'h02c000ef );
    check_asm( 'hc, "jal x1, 0x3c",   32'h030000ef );

    check_asm( 'hc, "jal x1, 0x0400", 32'h3f4000ef );
    check_asm( 'hc, "jal x1, 0x0800", 32'h7f4000ef );
    check_asm( 'hc, "jal x1, 0x0c00", 32'h3f5000ef );
    check_asm( 'hc, "jal x1, 0x1000", 32'h7f5000ef );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_7_asm_jr
  //----------------------------------------------------------------------

  task test_case_7_asm_jr();
    t.test_case_begin( "test_case_7_asm_jr" );

    check_asm( 0, "jr x0",  32'h00000067 );
    check_asm( 0, "jr x1",  32'h00008067 );
    check_asm( 0, "jr x2",  32'h00010067 );
    check_asm( 0, "jr x31", 32'h000f8067 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_8_asm_bne
  //----------------------------------------------------------------------

  task test_case_8_asm_bne();
    t.test_case_begin( "test_case_8_asm_bne" );

    check_asm(   0, "bne x0, x0, 0",      32'h00001063 );
    check_asm(   0, "bne x0, x1, 0",      32'h00101063 );
    check_asm(   0, "bne x1, x0, 0",      32'h00009063 );
    check_asm(   0, "bne x1, x1, 0",      32'h00109063 );
    check_asm(   0, "bne x1, x2, 0",      32'h00209063 );
    check_asm(   0, "bne x3, x4, 0",      32'h00419063 );
    check_asm(   0, "bne x31, x30, 0",    32'h01ef9063 );

    check_asm(   0, "bne x1, x1, 4",      32'h00109263 );
    check_asm(   0, "bne x1, x1, 8",      32'h00109463 );
    check_asm(   0, "bne x1, x1, 12",     32'h00109663 );

    check_asm(  12, "bne x1, x1,  0",     32'hfe109ae3 );
    check_asm(  12, "bne x1, x1,  4",     32'hfe109ce3 );
    check_asm(  12, "bne x1, x1,  8",     32'hfe109ee3 );
    check_asm(  12, "bne x1, x1, 12",     32'h00109063 );
    check_asm(  12, "bne x1, x1, 16",     32'h00109263 );
    check_asm(  12, "bne x1, x1, 20",     32'h00109463 );
    check_asm(  12, "bne x1, x1, 24",     32'h00109663 );

    check_asm( 'hc, "bne x1, x1, 0x00",   32'hfe109ae3 );
    check_asm( 'hc, "bne x1, x1, 0x04",   32'hfe109ce3 );
    check_asm( 'hc, "bne x1, x1, 0x08",   32'hfe109ee3 );
    check_asm( 'hc, "bne x1, x1, 0x0c",   32'h00109063 );

    check_asm( 'hc, "bne x1, x1, 0x10",   32'h00109263 );
    check_asm( 'hc, "bne x1, x1, 0x14",   32'h00109463 );
    check_asm( 'hc, "bne x1, x1, 0x18",   32'h00109663 );
    check_asm( 'hc, "bne x1, x1, 0x1c",   32'h00109863 );

    check_asm( 'hc, "bne x1, x1, 0x20",   32'h00109a63 );
    check_asm( 'hc, "bne x1, x1, 0x24",   32'h00109c63 );
    check_asm( 'hc, "bne x1, x1, 0x28",   32'h00109e63 );
    check_asm( 'hc, "bne x1, x1, 0x2c",   32'h02109063 );

    check_asm( 'hc, "bne x1, x1, 0x30",   32'h02109263 );
    check_asm( 'hc, "bne x1, x1, 0x34",   32'h02109463 );
    check_asm( 'hc, "bne x1, x1, 0x38",   32'h02109663 );
    check_asm( 'hc, "bne x1, x1, 0x3c",   32'h02109863 );

    check_asm( 'hc, "bne x1, x1, 0x1000", 32'h7e109ae3 );
    check_asm( 'hc, "bne x1, x1, 0x0ffc", 32'h7e1098e3 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_9_asm_spacing
  //----------------------------------------------------------------------
  // Try different spacing between fields in assembly instruction.

  task test_case_9_asm_spacing();
    t.test_case_begin( "test_case_9_asm_spacing" );

    check_asm( 0, "add x0, x0, x0",         32'h00000033 );
    check_asm( 0, "add  x0,  x0,  x0 ",     32'h00000033 );
    check_asm( 0, "add   x0,   x0,   x0  ", 32'h00000033 );

    check_asm( 0, "mul x0, x0, x0",         32'h02000033 );
    check_asm( 0, "mul  x0,  x0,  x0 ",     32'h02000033 );
    check_asm( 0, "mul   x0,   x0,   x0  ", 32'h02000033 );

    check_asm( 0, "lw x0, 0(x0)",           32'h00002003 );
    check_asm( 0, "lw  x0,  0(x0) ",        32'h00002003 );
    check_asm( 0, "lw   x0,   0(x0)  ",     32'h00002003 );

    check_asm( 0, "sw x0, 0(x0)",           32'h00002023 );
    check_asm( 0, "sw  x0,  0(x0) ",        32'h00002023 );
    check_asm( 0, "sw   x0,   0(x0)  ",     32'h00002023 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // check_disasm
  //----------------------------------------------------------------------

  logic [22*8-1:0] asm_s;

  task check_disasm
  (
    input logic [31:0]     addr,
    input logic [31:0]     inst_,
    input logic [22*8-1:0] asm_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      asm_s = tinyrv1.disasm( addr, inst_ );

      #8;

      if ( t.n != 0 ) begin
        $display( "%3d: %x %x > %-s|", t.cycles, addr, inst_, asm_s );
      end

      `ECE2300_CHECK_EQ_STR( asm_s, asm_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_10_disasm_add
  //----------------------------------------------------------------------

  task test_case_10_disasm_add();
    t.test_case_begin( "test_case_10_disasm_add" );

    check_disasm( 0, 32'h00000033, "add  x0, x0, x0" );
    check_disasm( 0, 32'h00100033, "add  x0, x0, x1" );
    check_disasm( 0, 32'h00108033, "add  x0, x1, x1" );
    check_disasm( 0, 32'h000080b3, "add  x1, x1, x0" );
    check_disasm( 0, 32'h001080b3, "add  x1, x1, x1" );
    check_disasm( 0, 32'h003100b3, "add  x1, x2, x3" );
    check_disasm( 0, 32'h00628233, "add  x4, x5, x6" );
    check_disasm( 0, 32'h01df0fb3, "add  x31, x30, x29" );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_11_disasm_addi
  //----------------------------------------------------------------------

  task test_case_11_disasm_addi();
    t.test_case_begin( "test_case_11_disasm_addi" );

    check_disasm( 0, 32'h00000013, "addi x0, x0, 0x000"  );
    check_disasm( 0, 32'h00000093, "addi x1, x0, 0x000"  );
    check_disasm( 0, 32'h00000113, "addi x2, x0, 0x000"  );
    check_disasm( 0, 32'h00000f93, "addi x31, x0, 0x000" );

    check_disasm( 0, 32'h00100093, "addi x1, x0, 0x001" );
    check_disasm( 0, 32'h00200093, "addi x1, x0, 0x002" );
    check_disasm( 0, 32'h00300093, "addi x1, x0, 0x003" );
    check_disasm( 0, 32'h02000093, "addi x1, x0, 0x020" );
    check_disasm( 0, 32'h7ff00093, "addi x1, x0, 0x7ff" );

    check_disasm( 0, 32'hfff00093, "addi x1, x0, 0xfff" );
    check_disasm( 0, 32'hffe00093, "addi x1, x0, 0xffe" );
    check_disasm( 0, 32'hffd00093, "addi x1, x0, 0xffd" );
    check_disasm( 0, 32'hfe000093, "addi x1, x0, 0xfe0" );
    check_disasm( 0, 32'h80000093, "addi x1, x0, 0x800" );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_12_disasm_mul
  //----------------------------------------------------------------------

  task test_case_12_disasm_mul();
    t.test_case_begin( "test_case_12_disasm_mul" );

    check_disasm( 0, 32'h02000033, "mul  x0, x0, x0"    );
    check_disasm( 0, 32'h02100033, "mul  x0, x0, x1"    );
    check_disasm( 0, 32'h02108033, "mul  x0, x1, x1"    );
    check_disasm( 0, 32'h020080b3, "mul  x1, x1, x0"    );
    check_disasm( 0, 32'h021080b3, "mul  x1, x1, x1"    );
    check_disasm( 0, 32'h023100b3, "mul  x1, x2, x3"    );
    check_disasm( 0, 32'h02628233, "mul  x4, x5, x6"    );
    check_disasm( 0, 32'h03df0fb3, "mul  x31, x30, x29" );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_13_disasm_lw
  //----------------------------------------------------------------------

  task test_case_13_disasm_lw();
    t.test_case_begin( "test_case_13_disasm_lw" );

    check_disasm( 0, 32'h00002003, "lw   x0, 0x000(x0)"   );
    check_disasm( 0, 32'h00002083, "lw   x1, 0x000(x0)"   );
    check_disasm( 0, 32'h00002103, "lw   x2, 0x000(x0)"   );
    check_disasm( 0, 32'h00002f83, "lw   x31, 0x000(x0)"  );

    check_disasm( 0, 32'h00002083, "lw   x1, 0x000(x0)"   );
    check_disasm( 0, 32'h00012083, "lw   x1, 0x000(x2)"   );
    check_disasm( 0, 32'h0000a103, "lw   x2, 0x000(x1)"   );
    check_disasm( 0, 32'h000f2f83, "lw   x31, 0x000(x30)" );

    check_disasm( 0, 32'h00112083, "lw   x1, 0x001(x2)"   );
    check_disasm( 0, 32'h00412083, "lw   x1, 0x004(x2)"   );
    check_disasm( 0, 32'h00812083, "lw   x1, 0x008(x2)"   );
    check_disasm( 0, 32'h00c12083, "lw   x1, 0x00c(x2)"   );
    check_disasm( 0, 32'h02012083, "lw   x1, 0x020(x2)"   );
    check_disasm( 0, 32'h7fc12083, "lw   x1, 0x7fc(x2)"   );

    // These don't assemble using the GNU assembler?
    check_disasm( 0, 32'hffc12083, "lw   x1, 0xffc(x2)"   );
    check_disasm( 0, 32'hff812083, "lw   x1, 0xff8(x2)"   );
    check_disasm( 0, 32'hff412083, "lw   x1, 0xff4(x2)"   );
    check_disasm( 0, 32'hfe012083, "lw   x1, 0xfe0(x2)"   );
    check_disasm( 0, 32'h80012083, "lw   x1, 0x800(x2)"   );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_14_disasm_sw
  //----------------------------------------------------------------------

  task test_case_14_disasm_sw();
    t.test_case_begin( "test_case_14_disasm_sw" );

    check_disasm( 0, 32'h00002023, "sw   x0, 0x000(x0)"    );
    check_disasm( 0, 32'h00102023, "sw   x1, 0x000(x0)"    );
    check_disasm( 0, 32'h00202023, "sw   x2, 0x000(x0)"    );
    check_disasm( 0, 32'h01f02023, "sw   x31, 0x000(x0)"   );

    check_disasm( 0, 32'h00102023, "sw   x1, 0x000(x0)"    );
    check_disasm( 0, 32'h00112023, "sw   x1, 0x000(x2)"    );
    check_disasm( 0, 32'h0020a023, "sw   x2, 0x000(x1)"    );
    check_disasm( 0, 32'h01ff2023, "sw   x31, 0x000(x30)"  );

    check_disasm( 0, 32'h001120a3, "sw   x1, 0x001(x2)"    );
    check_disasm( 0, 32'h00112223, "sw   x1, 0x004(x2)"    );
    check_disasm( 0, 32'h00112423, "sw   x1, 0x008(x2)"    );
    check_disasm( 0, 32'h00112623, "sw   x1, 0x00c(x2)"    );
    check_disasm( 0, 32'h02112023, "sw   x1, 0x020(x2)"    );
    check_disasm( 0, 32'h7e112e23, "sw   x1, 0x7fc(x2)"    );

    // These don't assemble using the GNU assembler?
    check_disasm( 0, 32'hfe112e23, "sw   x1, 0xffc(x2)"    );
    check_disasm( 0, 32'hfe112c23, "sw   x1, 0xff8(x2)"    );
    check_disasm( 0, 32'hfe112a23, "sw   x1, 0xff4(x2)"    );
    check_disasm( 0, 32'hfe112023, "sw   x1, 0xfe0(x2)"    );
    check_disasm( 0, 32'h80112023, "sw   x1, 0x800(x2)"    );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_15_disasm_jal
  //----------------------------------------------------------------------

  task test_case_15_disasm_jal();
    t.test_case_begin( "test_case_15_disasm_jal" );

    check_disasm(   0, 32'h0000006f, "jal  x0, 0x00000"   );
    check_disasm(   0, 32'h000000ef, "jal  x1, 0x00000"   );
    check_disasm(   0, 32'h0000016f, "jal  x2, 0x00000"   );
    check_disasm(   0, 32'h00000fef, "jal  x31, 0x00000"  );

    check_disasm(   0, 32'h004000ef, "jal  x1, 0x00004"   );
    check_disasm(   0, 32'h008000ef, "jal  x1, 0x00008"   );
    check_disasm(   0, 32'h00c000ef, "jal  x1, 0x0000c"   );

    check_disasm( 'hc, 32'hff5ff0ef, "jal  x1, 0x00000"   );
    check_disasm( 'hc, 32'hff9ff0ef, "jal  x1, 0x00004"   );
    check_disasm( 'hc, 32'hffdff0ef, "jal  x1, 0x00008"   );
    check_disasm( 'hc, 32'h000000ef, "jal  x1, 0x0000c"   );

    check_disasm( 'hc, 32'h004000ef, "jal  x1, 0x00010"   );
    check_disasm( 'hc, 32'h008000ef, "jal  x1, 0x00014"   );
    check_disasm( 'hc, 32'h00c000ef, "jal  x1, 0x00018"   );
    check_disasm( 'hc, 32'h010000ef, "jal  x1, 0x0001c"   );

    check_disasm( 'hc, 32'h014000ef, "jal  x1, 0x00020"   );
    check_disasm( 'hc, 32'h018000ef, "jal  x1, 0x00024"   );
    check_disasm( 'hc, 32'h01c000ef, "jal  x1, 0x00028"   );
    check_disasm( 'hc, 32'h020000ef, "jal  x1, 0x0002c"   );

    check_disasm( 'hc, 32'h024000ef, "jal  x1, 0x00030"   );
    check_disasm( 'hc, 32'h028000ef, "jal  x1, 0x00034"   );
    check_disasm( 'hc, 32'h02c000ef, "jal  x1, 0x00038"   );
    check_disasm( 'hc, 32'h030000ef, "jal  x1, 0x0003c"   );

    check_disasm( 'hc, 32'h3f4000ef, "jal  x1, 0x00400"   );
    check_disasm( 'hc, 32'h7f4000ef, "jal  x1, 0x00800"   );
    check_disasm( 'hc, 32'h3f5000ef, "jal  x1, 0x00c00"   );
    check_disasm( 'hc, 32'h7f5000ef, "jal  x1, 0x01000"   );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_16_disasm_jr
  //----------------------------------------------------------------------

  task test_case_16_disasm_jr();
    t.test_case_begin( "test_case_16_disasm_jr" );

    check_disasm( 0, 32'h00000067, "jr   x0"  );
    check_disasm( 0, 32'h00008067, "jr   x1"  );
    check_disasm( 0, 32'h00010067, "jr   x2"  );
    check_disasm( 0, 32'h000f8067, "jr   x31" );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_17_disasm_bne
  //----------------------------------------------------------------------

  task test_case_17_disasm_bne();
    t.test_case_begin( "test_case_17_disasm_bne" );

    check_disasm(   0, 32'h00001063, "bne  x0, x0, 0x00000"   );
    check_disasm(   0, 32'h00101063, "bne  x0, x1, 0x00000"   );
    check_disasm(   0, 32'h00009063, "bne  x1, x0, 0x00000"   );
    check_disasm(   0, 32'h00109063, "bne  x1, x1, 0x00000"   );
    check_disasm(   0, 32'h00209063, "bne  x1, x2, 0x00000"   );
    check_disasm(   0, 32'h00419063, "bne  x3, x4, 0x00000"   );
    check_disasm(   0, 32'h01ef9063, "bne  x31, x30, 0x00000" );

    check_disasm( 'hc, 32'hfe109ae3, "bne  x1, x1, 0x00000"   );
    check_disasm( 'hc, 32'hfe109ce3, "bne  x1, x1, 0x00004"   );
    check_disasm( 'hc, 32'hfe109ee3, "bne  x1, x1, 0x00008"   );
    check_disasm( 'hc, 32'h00109063, "bne  x1, x1, 0x0000c"   );

    check_disasm( 'hc, 32'h00109263, "bne  x1, x1, 0x00010"   );
    check_disasm( 'hc, 32'h00109463, "bne  x1, x1, 0x00014"   );
    check_disasm( 'hc, 32'h00109663, "bne  x1, x1, 0x00018"   );
    check_disasm( 'hc, 32'h00109863, "bne  x1, x1, 0x0001c"   );

    check_disasm( 'hc, 32'h00109a63, "bne  x1, x1, 0x00020"   );
    check_disasm( 'hc, 32'h00109c63, "bne  x1, x1, 0x00024"   );
    check_disasm( 'hc, 32'h00109e63, "bne  x1, x1, 0x00028"   );
    check_disasm( 'hc, 32'h02109063, "bne  x1, x1, 0x0002c"   );

    check_disasm( 'hc, 32'h02109263, "bne  x1, x1, 0x00030"   );
    check_disasm( 'hc, 32'h02109463, "bne  x1, x1, 0x00034"   );
    check_disasm( 'hc, 32'h02109663, "bne  x1, x1, 0x00038"   );
    check_disasm( 'hc, 32'h02109863, "bne  x1, x1, 0x0003c"   );

    check_disasm( 'hc, 32'h7e109ae3, "bne  x1, x1, 0x01000"   );
    check_disasm( 'hc, 32'h7e1098e3, "bne  x1, x1, 0x00ffc"   );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1))  test_case_1_asm_add();
    if ((t.n <= 0) || (t.n == 2))  test_case_2_asm_addi();
    if ((t.n <= 0) || (t.n == 3))  test_case_3_asm_mul();
    if ((t.n <= 0) || (t.n == 4))  test_case_4_asm_lw();
    if ((t.n <= 0) || (t.n == 5))  test_case_5_asm_sw();
    if ((t.n <= 0) || (t.n == 6))  test_case_6_asm_jal();
    if ((t.n <= 0) || (t.n == 7))  test_case_7_asm_jr();
    if ((t.n <= 0) || (t.n == 8))  test_case_8_asm_bne();
    if ((t.n <= 0) || (t.n == 9))  test_case_9_asm_spacing();

    if ((t.n <= 0) || (t.n == 10)) test_case_10_disasm_add();
    if ((t.n <= 0) || (t.n == 11)) test_case_11_disasm_addi();
    if ((t.n <= 0) || (t.n == 12)) test_case_12_disasm_mul();
    if ((t.n <= 0) || (t.n == 13)) test_case_13_disasm_lw();
    if ((t.n <= 0) || (t.n == 14)) test_case_14_disasm_sw();
    if ((t.n <= 0) || (t.n == 15)) test_case_15_disasm_jal();
    if ((t.n <= 0) || (t.n == 16)) test_case_16_disasm_jr();
    if ((t.n <= 0) || (t.n == 17)) test_case_17_disasm_bne();

    t.test_bench_end();
  end

endmodule
