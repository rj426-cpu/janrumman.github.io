#=========================================================================
# lab2
#=========================================================================

lab2_srcs = \
  FullAdder_GL.v \
  AdderRippleCarry_8b_GL.v \
  AdderRippleCarry_16b_GL.v \
  Mux2_1b_GL.v \
  Mux2_8b_GL.v \
  Mux2_16b_GL.v \
  AdderCarrySelect_16b_GL.v \
  Adder_16b_RTL.v \
  Multiplier_1x16b_GL.v \
  Multiplier_2x16b_GL.v \
  Multiplier_2x16b_RTL.v \
  Calculator_GL.v \

lab2_partA_tests = \
  FullAdder_GL-test.v \
  AdderRippleCarry_8b_GL-test.v \
  AdderRippleCarry_16b_GL-test.v \
  Mux2_1b_GL-test.v \
  Mux2_8b_GL-test.v \
  Mux2_16b_GL-test.v \
  AdderCarrySelect_16b_GL-test.v \
  Adder_16b_RTL-test.v \

lab2_partB_tests = \
  Multiplier_1x16b_GL-test.v \
  Multiplier_2x16b_GL-test.v \
  Multiplier_2x16b_RTL-test.v \
  Calculator_GL-test.v \

lab2_tests = \
  $(lab2_partA_tests) \
  $(lab2_partB_tests) \

lab2_sims = \
  calculator-sim.v \

$(eval $(call check_part,lab2_partA))
$(eval $(call check_part,lab2_partB))
$(eval $(call check_part,lab2))
