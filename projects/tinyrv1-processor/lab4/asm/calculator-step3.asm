#-------------------------------------------------------------------------
# calculator-step3.asm
#-------------------------------------------------------------------------

loop: 
  lw   x1, 0x200(x0)
  lw   x2, 0x204(x0)
  lw   x3, 0x208(x0)
  addi x5, x0, 1
  addi x6, x0, -1

  sw   x1, 0x210(x0)
  sw   x2, 0x214(x0)

  bne  x3, x0, else
  add  x4, x1, x2
  jal  x0, done

else:
  bne x3, x5, subtraction
  mul x4, x1, x2
  jal x0, done

subtraction: 
  mul x7, x6, x2
  add x4, x1, x7
      
done: 
  sw   x4, 0x218(x0)

jal  x0, loop

