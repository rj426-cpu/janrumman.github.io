#=========================================================================
# Makefile dependency fragment
#=========================================================================

BinaryToSevenSegUnopt_GL-test: \
  BinaryToSevenSegUnopt_GL-test.v \
  ece2300-test.v \
  BinaryToSevenSegUnopt_GL.v \
  BinaryToSevenSeg-test-cases.v \
  ece2300-misc.v \

BinaryToSevenSegUnopt_GL-test.d: \
  BinaryToSevenSegUnopt_GL-test.v \
  ece2300-test.v \
  BinaryToSevenSegUnopt_GL.v \
  BinaryToSevenSeg-test-cases.v \
  ece2300-misc.v \

ece2300-test.v:

BinaryToSevenSegUnopt_GL.v:

BinaryToSevenSeg-test-cases.v:

ece2300-misc.v:

