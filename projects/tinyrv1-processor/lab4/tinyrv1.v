//========================================================================
// TinyRV1 Instruction Set Specification
//========================================================================
// The 32-bit instruction has different fields depending on the format of
// the instruction used. The following are the various instruction
// encoding formats used in the TinyRV1 ISA.
//
//  31          25 24   20 19   15 14    12 11          7 6      0
// | funct7       | rs2   | rs1   | funct3 | rd          | opcode |  R-type
// | imm[11:0]            | rs1   | funct3 | rd          | opcode |  I-type,I-imm
// | imm[11:5]    | rs2   | rs1   | funct3 | imm[4:0]    | opcode |  S-type,S-imm
// | imm[12|10:5] | rs2   | rs1   | funct3 | imm[4:1|11] | opcode |  S-type,B-imm
// | imm[20|10:1|11|19:12]                 | rd          | opcode |  U-type,J-imm

`ifndef TINYRV1_ASM_V
`define TINYRV1_ASM_V

//------------------------------------------------------------------------
// Instruction fields
//------------------------------------------------------------------------

`define TINYRV1_INST_IMM_J   31:12
`define TINYRV1_INST_IMM_I   31:20
`define TINYRV1_INST_FUNCT7  31:25
`define TINYRV1_INST_RS2     24:20
`define TINYRV1_INST_RS1     19:15
`define TINYRV1_INST_FUNCT3  14:12
`define TINYRV1_INST_RD      11:7
`define TINYRV1_INST_OPCODE  6:0

//------------------------------------------------------------------------
// Field sizes
//------------------------------------------------------------------------

`define TINYRV1_INST_NBITS          32
`define TINYRV1_INST_IMM_J_NBITS    20
`define TINYRV1_INST_IMM_I_NBITS    12
`define TINYRV1_INST_FUNCT7_NBITS   7
`define TINYRV1_INST_RS2_NBITS      5
`define TINYRV1_INST_RS1_NBITS      5
`define TINYRV1_INST_FUNCT3_NBITS   3
`define TINYRV1_INST_RD_NBITS       5
`define TINYRV1_INST_OPCODE_NBITS   7

//------------------------------------------------------------------------
// Instruction opcodes
//------------------------------------------------------------------------

`define TINYRV1_INST_ADD   32'b0000000_?????_?????_000_?????_0110011
`define TINYRV1_INST_ADDI  32'b???????_?????_?????_000_?????_0010011
`define TINYRV1_INST_MUL   32'b0000001_?????_?????_000_?????_0110011
`define TINYRV1_INST_LW    32'b???????_?????_?????_010_?????_0000011
`define TINYRV1_INST_SW    32'b???????_?????_?????_010_?????_0100011
`define TINYRV1_INST_JAL   32'b???????_?????_?????_???_?????_1101111
`define TINYRV1_INST_JR    32'b???????_?????_?????_000_?????_1100111
`define TINYRV1_INST_BNE   32'b???????_?????_?????_001_?????_1100011

//------------------------------------------------------------------------
// Coprocessor registers
//------------------------------------------------------------------------

`ifndef SYNTHESIS

module TinyRV1();

  //----------------------------------------------------------------------
  // Global signals
  //----------------------------------------------------------------------

  integer e;

  //----------------------------------------------------------------------
  // check_imm
  //----------------------------------------------------------------------
  // Verify immediate can be stored in nbits. Assume decimal immediates
  // are signed and hexadecimal immediates are unsigned.

  function check_imm
  (
    input integer nbits,
    input integer is_dec,
    input integer value
  );

    check_imm = 1;
    if ( is_dec == 1 ) begin
      if (( value > (2**(nbits-1))-1 ) || (value < -(2**(nbits-1)))) begin
        $display( " ERROR: Immediate (%d) outside valid range [%d,%d]",
                  value, -(2**(nbits-1)), (2**(nbits-1))-1 );
        check_imm = 0;
      end
    end
    else if (( value > (2**nbits)-1 ) || (value < 0)) begin
      $display( " ERROR: Immediate (%x) outside valid range [0x000,%x]",
                value, (2**nbits)-1 );
      check_imm = 0;
    end

  endfunction

  //----------------------------------------------------------------------
  // asm_add
  //----------------------------------------------------------------------

  function [`TINYRV1_INST_NBITS-1:0] asm_add
  (
    input logic [`TINYRV1_INST_RD_NBITS-1:0]  rd,
    input logic [`TINYRV1_INST_RS1_NBITS-1:0] rs1,
    input logic [`TINYRV1_INST_RS2_NBITS-1:0] rs2
  );

    asm_add[`TINYRV1_INST_FUNCT7] = 7'b0000000;
    asm_add[`TINYRV1_INST_RS2]    = rs2;
    asm_add[`TINYRV1_INST_RS1]    = rs1;
    asm_add[`TINYRV1_INST_FUNCT3] = 3'b000;
    asm_add[`TINYRV1_INST_RD]     = rd;
    asm_add[`TINYRV1_INST_OPCODE] = 7'b0110011;

  endfunction

  //----------------------------------------------------------------------
  // asm_addi
  //----------------------------------------------------------------------

  integer asm_addi_e;
  integer asm_addi_imm_i;
  integer asm_addi_imm_is_dec;
  logic [`TINYRV1_INST_IMM_I_NBITS-1:0] asm_addi_imm;

  function [`TINYRV1_INST_NBITS-1:0] asm_addi
  (
    input logic [`TINYRV1_INST_RD_NBITS-1:0]  rd,
    input logic [`TINYRV1_INST_RS1_NBITS-1:0] rs1,
    input logic [20*8-1:0]                    imm_s
  );

    // Parse immediate

    asm_addi_imm_is_dec = 0;
    asm_addi_e = $sscanf( imm_s, "0x%x", asm_addi_imm_i );
    if ( asm_addi_e == 0 )
      asm_addi_e = $sscanf( imm_s, "0b%b", asm_addi_imm_i );
    if ( asm_addi_e == 0 ) begin
      asm_addi_e = $sscanf( imm_s, "%d", asm_addi_imm_i );
      asm_addi_imm_is_dec = 1;
    end
    if ( asm_addi_e == 0 )
      e = 0;

    // Check for valid immediate

    e = 32'(check_imm( 12, asm_addi_imm_is_dec, asm_addi_imm_i ));

    if ( e != 0 )
      asm_addi_imm = `TINYRV1_INST_IMM_I_NBITS'(asm_addi_imm_i);
    else
      asm_addi_imm = 'x;

    // Assemble the instruction

    asm_addi[`TINYRV1_INST_IMM_I]  = asm_addi_imm;
    asm_addi[`TINYRV1_INST_RS1]    = rs1;
    asm_addi[`TINYRV1_INST_FUNCT3] = 3'b000;
    asm_addi[`TINYRV1_INST_RD]     = rd;
    asm_addi[`TINYRV1_INST_OPCODE] = 7'b0010011;

  endfunction

  //----------------------------------------------------------------------
  // asm_mul
  //----------------------------------------------------------------------

  function [`TINYRV1_INST_NBITS-1:0] asm_mul
  (
    input logic [`TINYRV1_INST_RD_NBITS-1:0]  rd,
    input logic [`TINYRV1_INST_RS1_NBITS-1:0] rs1,
    input logic [`TINYRV1_INST_RS2_NBITS-1:0] rs2
  );

    asm_mul[`TINYRV1_INST_FUNCT7] = 7'b0000001;
    asm_mul[`TINYRV1_INST_RS2]    = rs2;
    asm_mul[`TINYRV1_INST_RS1]    = rs1;
    asm_mul[`TINYRV1_INST_FUNCT3] = 3'b000;
    asm_mul[`TINYRV1_INST_RD]     = rd;
    asm_mul[`TINYRV1_INST_OPCODE] = 7'b0110011;

  endfunction

  //----------------------------------------------------------------------
  // asm_lw
  //----------------------------------------------------------------------

  integer asm_lw_e;
  integer asm_lw_imm_i;
  integer asm_lw_imm_is_dec;
  logic [`TINYRV1_INST_IMM_I_NBITS-1:0] asm_lw_imm;
  logic [`TINYRV1_INST_RS1_NBITS-1:0]   asm_lw_rs1;

  function [`TINYRV1_INST_NBITS-1:0] asm_lw
  (
    input logic [`TINYRV1_INST_RD_NBITS-1:0] rd,
    input logic [20*8-1:0]                   addr_s
  );

    // Parse address

    asm_lw_imm_is_dec = 0;
    asm_lw_e = $sscanf( addr_s, "0x%x(x%d)", asm_lw_imm_i, asm_lw_rs1 );
    if ( asm_lw_e == 0 ) begin
      asm_lw_e = $sscanf( addr_s, "%d(x%d)", asm_lw_imm_i, asm_lw_rs1 );
      asm_lw_imm_is_dec = 1;
    end
    if ( asm_lw_e == 0 )
      e = 0;

    // Check for valid immediate

    e = 32'(check_imm( 12, asm_lw_imm_is_dec, asm_lw_imm_i ));

    if ( e != 0 )
      asm_lw_imm = `TINYRV1_INST_IMM_I_NBITS'(asm_lw_imm_i);
    else
      asm_lw_imm = 'x;

    // Assemble the instruction

    asm_lw[`TINYRV1_INST_IMM_I]  = asm_lw_imm;
    asm_lw[`TINYRV1_INST_RS1]    = asm_lw_rs1;
    asm_lw[`TINYRV1_INST_FUNCT3] = 3'b010;
    asm_lw[`TINYRV1_INST_RD]     = rd;
    asm_lw[`TINYRV1_INST_OPCODE] = 7'b0000011;

  endfunction

  //----------------------------------------------------------------------
  // asm_sw
  //----------------------------------------------------------------------

  integer asm_sw_e;
  integer asm_sw_imm_i;
  integer asm_sw_imm_is_dec;
  logic [`TINYRV1_INST_IMM_I_NBITS-1:0] asm_sw_imm;
  logic [`TINYRV1_INST_RS1_NBITS-1:0]   asm_sw_rs1;

  function [`TINYRV1_INST_NBITS-1:0] asm_sw
  (
    input logic [`TINYRV1_INST_RS2_NBITS-1:0] rs2,
    input logic [20*8-1:0]                    addr_s
  );

    // Parse address

    asm_sw_imm_is_dec = 0;
    asm_sw_e = $sscanf( addr_s, "0x%x(x%d)", asm_sw_imm_i, asm_sw_rs1 );
    if ( asm_sw_e == 0 ) begin
      asm_sw_e = $sscanf( addr_s, "%d(x%d)", asm_sw_imm_i, asm_sw_rs1 );
      asm_sw_imm_is_dec = 1;
    end
    if ( asm_sw_e == 0 )
      e = 0;

    // Check for valid immediate

    e = 32'(check_imm( 12, asm_sw_imm_is_dec, asm_sw_imm_i ));

    if ( e != 0 )
      asm_sw_imm = `TINYRV1_INST_IMM_I_NBITS'(asm_sw_imm_i);
    else
      asm_sw_imm = 'x;

    // Assemble the instruction

    asm_sw[`TINYRV1_INST_FUNCT7] = asm_sw_imm[11:5];
    asm_sw[`TINYRV1_INST_RS2]    = rs2;
    asm_sw[`TINYRV1_INST_RS1]    = asm_sw_rs1;
    asm_sw[`TINYRV1_INST_FUNCT3] = 3'b010;
    asm_sw[`TINYRV1_INST_RD]     = asm_sw_imm[4:0];
    asm_sw[`TINYRV1_INST_OPCODE] = 7'b0100011;

  endfunction

  //----------------------------------------------------------------------
  // asm_jal
  //----------------------------------------------------------------------

  integer asm_jal_e;
  integer asm_jal_jtarg_i;
  integer asm_jal_imm_i;
  logic [`TINYRV1_INST_IMM_J_NBITS:0] asm_jal_imm;
  logic asm_jal_imm_unused;

  function [`TINYRV1_INST_NBITS-1:0] asm_jal
  (
    input logic [31:0]                       addr,
    input logic [`TINYRV1_INST_RD_NBITS-1:0] rd,
    input logic [20*8-1:0]                   jtarg_s
  );

    // Parse jump target address

    asm_jal_e = $sscanf( jtarg_s, "0x%x", asm_jal_jtarg_i );
    if ( asm_jal_e == 0 )
      asm_jal_e = $sscanf( jtarg_s, "%d", asm_jal_jtarg_i );
    if ( asm_jal_e == 0 )
      e = 0;

    if ( (asm_jal_jtarg_i % 4 ) != 0 ) begin
      $display( " ERROR: Jump target (%x) must be evenly divisible by four",
                asm_jal_imm_i );
      e = 0;
    end

    // Calculate immediate

    asm_jal_imm_i = asm_jal_jtarg_i - addr;

    // Check for valid immediate

    e = 32'(check_imm( 21, 1, asm_jal_imm_i ));

    if ( e != 0 )
      asm_jal_imm = 21'(asm_jal_imm_i);
    else
      asm_jal_imm = 'x;

    // Assemble the instruction

    asm_jal[`TINYRV1_INST_IMM_J]  = { asm_jal_imm[20], asm_jal_imm[10:1], asm_jal_imm[11], asm_jal_imm[19:12] };
    asm_jal[`TINYRV1_INST_RD]     = rd;
    asm_jal[`TINYRV1_INST_OPCODE] = 7'b1101111;

    // Least signficant bit will always be zero in TinyRV1

    asm_jal_imm_unused = asm_jal_imm[0];

  endfunction

  //----------------------------------------------------------------------
  // asm_jr
  //----------------------------------------------------------------------

  function [`TINYRV1_INST_NBITS-1:0] asm_jr
  (
    input logic [`TINYRV1_INST_RS1_NBITS-1:0] rs1
  );

    asm_jr[`TINYRV1_INST_FUNCT7] = 7'b0000000;
    asm_jr[`TINYRV1_INST_RS2]    = 5'b00000;
    asm_jr[`TINYRV1_INST_RS1]    = rs1;
    asm_jr[`TINYRV1_INST_FUNCT3] = 3'b000;
    asm_jr[`TINYRV1_INST_RD]     = 5'b00000;
    asm_jr[`TINYRV1_INST_OPCODE] = 7'b1100111;

  endfunction

  //----------------------------------------------------------------------
  // asm_bne
  //----------------------------------------------------------------------

  integer asm_bne_e;
  integer asm_bne_btarg_i;
  integer asm_bne_imm_i;
  logic [12:0] asm_bne_imm;
  logic asm_bne_imm_unused;

  function [`TINYRV1_INST_NBITS-1:0] asm_bne
  (
    input logic [31:0]                        addr,
    input logic [`TINYRV1_INST_RS1_NBITS-1:0] rs1,
    input logic [`TINYRV1_INST_RS2_NBITS-1:0] rs2,
    input logic [20*8-1:0]                    btarg_s
  );

    // Parse branch target address

    asm_bne_e = $sscanf( btarg_s, "0x%x", asm_bne_btarg_i );
    if ( asm_bne_e == 0 )
      asm_bne_e = $sscanf( btarg_s, "%d", asm_bne_btarg_i );
    if ( asm_bne_e == 0 )
      e = 0;

    if ( (asm_bne_btarg_i % 4 ) != 0 ) begin
      $display( " ERROR: Branch target (%x) must be evenly divisible by four",
                asm_bne_imm_i );
      e = 0;
    end

    // Calculate immediate

    asm_bne_imm_i = asm_bne_btarg_i - addr;

    // Check for valid immediate

    e = 32'(check_imm( 13, 1, asm_bne_imm_i ));

    if ( e != 0 )
      asm_bne_imm = 13'(asm_bne_imm_i);
    else
      asm_bne_imm = 'x;

    // Assemble the instruction

    asm_bne[`TINYRV1_INST_FUNCT7] = { asm_bne_imm[12], asm_bne_imm[10:5] };
    asm_bne[`TINYRV1_INST_RS1]    = rs1;
    asm_bne[`TINYRV1_INST_RS2]    = rs2;
    asm_bne[`TINYRV1_INST_FUNCT3] = 3'b001;
    asm_bne[`TINYRV1_INST_RD]     = { asm_bne_imm[4:1], asm_bne_imm[11] };
    asm_bne[`TINYRV1_INST_OPCODE] = 7'b1100011;

    // Least signficant bit will always be zero in TinyRV1

    asm_bne_imm_unused = asm_bne_imm[0];

  endfunction

  //----------------------------------------------------------------------
  // asm
  //----------------------------------------------------------------------
  // This function takes as input an assembly instruction as a string
  // along with the address of this instruction in memory and then
  // returns the corresponding machine instruction.

  logic [10*8-1:0] inst_s;
  logic [20*8-1:0] imm_s;
  logic [20*8-1:0] addr_s;
  logic [20*8-1:0] jtarg_s;
  logic [20*8-1:0] btarg_s;

  logic [`TINYRV1_INST_RS1_NBITS-1:0] rs1;
  logic [`TINYRV1_INST_RS2_NBITS-1:0] rs2;
  logic [`TINYRV1_INST_RD_NBITS-1:0]  rd;

  function [`TINYRV1_INST_NBITS-1:0] asm
  (
    input [31:0] addr,
    input string str
  );

    e = $sscanf( str, "%s ", inst_s );
    case ( inst_s )

      "add"  : begin e = $sscanf( str, "add  x%d, x%d, x%d", rd, rs1, rs2      ); asm = asm_add ( rd, rs1, rs2 );            end
      "addi" : begin e = $sscanf( str, "addi x%d, x%d, %s",  rd, rs1, imm_s    ); asm = asm_addi( rd, rs1, imm_s );          end
      "mul"  : begin e = $sscanf( str, "mul  x%d, x%d, x%d", rd, rs1, rs2      ); asm = asm_mul ( rd, rs1, rs2 );            end
      "lw"   : begin e = $sscanf( str, "lw   x%d, %s",       rd, addr_s        ); asm = asm_lw  ( rd, addr_s );              end
      "sw"   : begin e = $sscanf( str, "sw   x%d, %s",       rs2, addr_s       ); asm = asm_sw  ( rs2, addr_s );             end
      "jal"  : begin e = $sscanf( str, "jal  x%d, %s",       rd, jtarg_s       ); asm = asm_jal ( addr, rd, jtarg_s );       end
      "jr"   : begin e = $sscanf( str, "jr   x%d",           rs1               ); asm = asm_jr  ( rs1 );                     end
      "bne"  : begin e = $sscanf( str, "bne  x%d, x%d, %s",  rs1, rs2, btarg_s ); asm = asm_bne ( addr, rs1, rs2, btarg_s ); end

      default : asm = 'x;
    endcase

    if ( e == 0 )
      asm = 'x;

    inst_s  = 'x;
    imm_s   = 'x;
    addr_s  = 'x;
    jtarg_s = 'x;
    btarg_s = 'x;
    rs1     = 'x;
    rs2     = 'x;
    rd      = 'x;

    // If asm has any Xs then |(asm ^ asm)) will not equal zero, in which
    // case we will stop the simulation with an error since something
    // went wrong in the assembly process.

    if ((|(asm ^ asm)) == 1'b0);
    else begin
      $display( " ERROR: Could not assemble \"%s\"\n", str );
      $finish;
    end

  endfunction

  //----------------------------------------------------------------------
  // disasm immediates
  //----------------------------------------------------------------------

  logic [31:0] inst_unused;

  function [11:0] disasm_imm_i
  (
    input [`TINYRV1_INST_NBITS-1:0] inst
  );
    disasm_imm_i = { inst[31], inst[30:25], inst[24:21], inst[20] };
    inst_unused = inst;
  endfunction

  function [11:0] disasm_imm_s
  (
    input [`TINYRV1_INST_NBITS-1:0] inst
  );
    disasm_imm_s = { inst[31], inst[30:25], inst[11:8], inst[7] };
    inst_unused = inst;
  endfunction

  function [31:0] disasm_imm_b
  (
    input [31:0] addr,
    input [`TINYRV1_INST_NBITS-1:0] inst
  );
    disasm_imm_b = { {19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0 };
    disasm_imm_b = addr + disasm_imm_b;
    inst_unused = inst;
  endfunction

  function [31:0] disasm_imm_j
  (
    input [31:0] addr,
    input [`TINYRV1_INST_NBITS-1:0] inst
  );
    disasm_imm_j = { {11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0 };
    disasm_imm_j = addr + disasm_imm_j;
    inst_unused = inst;
  endfunction

  //----------------------------------------------------------------------
  // disasm
  //----------------------------------------------------------------------
  // This function takes as input a machine instruction and returns the
  // corresponding assembly instruction as a string.

  // logic [4*8-1:0]  rs1_s;
  // logic [4*8-1:0]  rs2_s;
  // logic [4*8-1:0]  rd_s;
  logic [20*8-1:0] disasm_;

  function [20*8-1:0] disasm
  (
    input [31:0]                    addr,
    input [`TINYRV1_INST_NBITS-1:0] inst
  );

    // Unpack the fields

    rs1 = inst[`TINYRV1_INST_RS1];
    rs2 = inst[`TINYRV1_INST_RS2];
    rd  = inst[`TINYRV1_INST_RD];

    // Create fixed-width register specifiers

    // if ( rs1 <= 9 )
    //   $sformat( rs1_s, "x%0d, ", rs1 );
    // else
    //   $sformat( rs1_s, "x%d,",  rs1 );

    // if ( rs2 <= 9 )
    //   $sformat( rs2_s, "x%0d, ", rs2 );
    // else
    //   $sformat( rs2_s, "x%d,",  rs2 );

    // if ( rd <= 9 )
    //   $sformat( rd_s, "x%0d, ", rd );
    // else
    //   $sformat( rd_s, "x%d,",  rd );

    // Actual disassembly

    casez ( inst )
      `TINYRV1_INST_ADD   : $sformat( disasm_, "add  x%-0d, x%-0d, x%-0d", rd, rs1, rs2 );
      `TINYRV1_INST_ADDI  : $sformat( disasm_, "addi x%-0d, x%-0d, 0x%x",  rd, rs1, disasm_imm_i(inst) );
      `TINYRV1_INST_MUL   : $sformat( disasm_, "mul  x%-0d, x%-0d, x%-0d", rd, rs1, rs2 );
      `TINYRV1_INST_LW    : $sformat( disasm_, "lw   x%-0d, 0x%x(x%-0d)",  rd, disasm_imm_i(inst), rs1 );
      `TINYRV1_INST_SW    : $sformat( disasm_, "sw   x%-0d, 0x%x(x%-0d)",  rs2, disasm_imm_s(inst), rs1 );
      `TINYRV1_INST_JAL   : $sformat( disasm_, "jal  x%-0d, 0x%x",         rd, 20'(disasm_imm_j(addr,inst)) );
      `TINYRV1_INST_JR    : $sformat( disasm_, "jr   x%-0d",               rs1 );
      `TINYRV1_INST_BNE   : $sformat( disasm_, "bne  x%-0d, x%-0d, 0x%x",  rs1, rs2, 20'(disasm_imm_b(addr,inst)) );
      default             : $sformat( disasm_, "illegal inst" );
    endcase

    disasm = disasm_;

  endfunction

  //----------------------------------------------------------------------
  // Disasm Tiny
  //----------------------------------------------------------------------

  function [4*8-1:0] disasm_tiny
  (
    input [`TINYRV1_INST_NBITS-1:0] inst
  );

    casez ( inst )
      `TINYRV1_INST_ADD  : disasm_tiny = "add ";
      `TINYRV1_INST_ADDI : disasm_tiny = "addi";
      `TINYRV1_INST_MUL  : disasm_tiny = "mul ";
      `TINYRV1_INST_LW   : disasm_tiny = "lw  ";
      `TINYRV1_INST_SW   : disasm_tiny = "sw  ";
      `TINYRV1_INST_JAL  : disasm_tiny = "jal ";
      `TINYRV1_INST_JR   : disasm_tiny = "jr  ";
      `TINYRV1_INST_BNE  : disasm_tiny = "bne ";
      default            : disasm_tiny = "????";
    endcase

  endfunction

endmodule

`endif /* SYNTHESIS */

`endif /* TINYRV1_ASM_V */

