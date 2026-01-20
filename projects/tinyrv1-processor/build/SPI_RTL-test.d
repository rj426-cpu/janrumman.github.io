#=========================================================================
# Makefile dependency fragment
#=========================================================================

SPI_RTL-test: \
  SPI_RTL-test.v \
  ece2300-test.v \
  SPI_RTL.v \
  ece2300-misc.v \
  Synchronizer_RTL.v \
  EdgeDetector_RTL.v \
  ShiftRegister_44b_RTL.v \
  DFF_RTL.v \

SPI_RTL-test.d: \
  SPI_RTL-test.v \
  ece2300-test.v \
  SPI_RTL.v \
  ece2300-misc.v \
  Synchronizer_RTL.v \
  EdgeDetector_RTL.v \
  ShiftRegister_44b_RTL.v \
  DFF_RTL.v \

ece2300-test.v:

SPI_RTL.v:

ece2300-misc.v:

Synchronizer_RTL.v:

EdgeDetector_RTL.v:

ShiftRegister_44b_RTL.v:

DFF_RTL.v:

