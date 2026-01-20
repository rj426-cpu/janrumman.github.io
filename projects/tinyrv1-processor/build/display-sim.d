#=========================================================================
# Makefile dependency fragment
#=========================================================================

display-sim: \
  display-sim.v \
  SevenSegFL.v \
  DisplayUnopt_GL.v \
  ece2300-misc.v \
  BinaryToBinCodedDec_GL.v \
  BinaryToSevenSegUnopt_GL.v \

display-sim.d: \
  display-sim.v \
  SevenSegFL.v \
  DisplayUnopt_GL.v \
  ece2300-misc.v \
  BinaryToBinCodedDec_GL.v \
  BinaryToSevenSegUnopt_GL.v \

SevenSegFL.v:

DisplayUnopt_GL.v:

ece2300-misc.v:

BinaryToBinCodedDec_GL.v:

BinaryToSevenSegUnopt_GL.v:

