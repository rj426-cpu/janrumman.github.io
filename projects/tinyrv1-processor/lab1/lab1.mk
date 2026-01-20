#=========================================================================
# lab1
#=========================================================================

lab1_srcs = \
  BinaryToSevenSegUnopt_GL.v \
  BinaryToBinCodedDec_GL.v \
  DisplayUnopt_GL.v \
  BinaryToSevenSegOpt_GL.v \
  DisplayOpt_GL.v \

lab1_partA_tests = \
  BinaryToSevenSegUnopt_GL-test.v \
  BinaryToBinCodedDec_GL-test.v \
  DisplayUnopt_GL-test.v \

lab1_partB_tests = \
  BinaryToSevenSegOpt_GL-test.v \
  DisplayOpt_GL-test.v \

lab1_tests = \
  $(lab1_partA_tests) \
  $(lab1_partB_tests) \

lab1_sims = \
  display-sim.v \

$(eval $(call check_part,lab1_partA))
$(eval $(call check_part,lab1_partB))
$(eval $(call check_part,lab1))
