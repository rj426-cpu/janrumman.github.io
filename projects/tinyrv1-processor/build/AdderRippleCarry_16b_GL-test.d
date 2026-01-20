#=========================================================================
# Makefile dependency fragment
#=========================================================================

AdderRippleCarry_16b_GL-test: \
  AdderRippleCarry_16b_GL-test.v \
  ece2300-test.v \
  AdderRippleCarry_16b_GL.v \
  Adder_16b-test-cases.v \
  ece2300-misc.v \
  AdderRippleCarry_8b_GL.v \
  FullAdder_GL.v \

AdderRippleCarry_16b_GL-test.d: \
  AdderRippleCarry_16b_GL-test.v \
  ece2300-test.v \
  AdderRippleCarry_16b_GL.v \
  Adder_16b-test-cases.v \
  ece2300-misc.v \
  AdderRippleCarry_8b_GL.v \
  FullAdder_GL.v \

ece2300-test.v:

AdderRippleCarry_16b_GL.v:

Adder_16b-test-cases.v:

ece2300-misc.v:

AdderRippleCarry_8b_GL.v:

FullAdder_GL.v:

