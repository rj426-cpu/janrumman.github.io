#=========================================================================
# Makefile dependency fragment
#=========================================================================

ALU_32b-test: \
  ALU_32b-test.v \
  ece2300-test.v \
  ALU_32b.v \
  ece2300-misc.v \
  Adder_32b_GL.v \
  EqComparator_32b_RTL.v \
  Mux2_32b_RTL.v \
  AdderCarrySelect_16b_GL.v \
  AdderRippleCarry_8b_GL.v \
  Mux2_8b_GL.v \
  Mux2_1b_GL.v \
  FullAdder_GL.v \

ALU_32b-test.d: \
  ALU_32b-test.v \
  ece2300-test.v \
  ALU_32b.v \
  ece2300-misc.v \
  Adder_32b_GL.v \
  EqComparator_32b_RTL.v \
  Mux2_32b_RTL.v \
  AdderCarrySelect_16b_GL.v \
  AdderRippleCarry_8b_GL.v \
  Mux2_8b_GL.v \
  Mux2_1b_GL.v \
  FullAdder_GL.v \

ece2300-test.v:

ALU_32b.v:

ece2300-misc.v:

Adder_32b_GL.v:

EqComparator_32b_RTL.v:

Mux2_32b_RTL.v:

AdderCarrySelect_16b_GL.v:

AdderRippleCarry_8b_GL.v:

Mux2_8b_GL.v:

Mux2_1b_GL.v:

FullAdder_GL.v:

