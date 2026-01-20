#=========================================================================
# Makefile dependency fragment
#=========================================================================

counter-sim: \
  counter-sim.v \
  ece2300-misc.v \
  SevenSegFL.v \
  DisplayOpt_GL.v \
  Counter_16b_RTL.v \
  BinaryToBinCodedDec_GL.v \
  BinaryToSevenSegOpt_GL.v \
  Register_16b_RTL.v \

counter-sim.d: \
  counter-sim.v \
  ece2300-misc.v \
  SevenSegFL.v \
  DisplayOpt_GL.v \
  Counter_16b_RTL.v \
  BinaryToBinCodedDec_GL.v \
  BinaryToSevenSegOpt_GL.v \
  Register_16b_RTL.v \

ece2300-misc.v:

SevenSegFL.v:

DisplayOpt_GL.v:

Counter_16b_RTL.v:

BinaryToBinCodedDec_GL.v:

BinaryToSevenSegOpt_GL.v:

Register_16b_RTL.v:

