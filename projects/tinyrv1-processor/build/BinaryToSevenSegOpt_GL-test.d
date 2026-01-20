#=========================================================================
# Makefile dependency fragment
#=========================================================================

BinaryToSevenSegOpt_GL-test: \
  BinaryToSevenSegOpt_GL-test.v \
  ece2300-test.v \
  BinaryToSevenSegOpt_GL.v \
  BinaryToSevenSeg-test-cases.v \
  ece2300-misc.v \

BinaryToSevenSegOpt_GL-test.d: \
  BinaryToSevenSegOpt_GL-test.v \
  ece2300-test.v \
  BinaryToSevenSegOpt_GL.v \
  BinaryToSevenSeg-test-cases.v \
  ece2300-misc.v \

ece2300-test.v:

BinaryToSevenSegOpt_GL.v:

BinaryToSevenSeg-test-cases.v:

ece2300-misc.v:

