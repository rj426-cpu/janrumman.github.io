#=========================================================================
# Makefile dependency fragment
#=========================================================================

DFFRE_RTL-test: \
  DFFRE_RTL-test.v \
  ece2300-test.v \
  DFFRE_RTL.v \
  DFFRE-test-cases.v \
  ece2300-misc.v \

DFFRE_RTL-test.d: \
  DFFRE_RTL-test.v \
  ece2300-test.v \
  DFFRE_RTL.v \
  DFFRE-test-cases.v \
  ece2300-misc.v \

ece2300-test.v:

DFFRE_RTL.v:

DFFRE-test-cases.v:

ece2300-misc.v:

