#=========================================================================
# Makefile dependency fragment
#=========================================================================

Multiplier_2x16b_RTL-test: \
  Multiplier_2x16b_RTL-test.v \
  ece2300-test.v \
  Multiplier_2x16b_RTL.v \
  Multiplier_2x16b-test-cases.v \
  ece2300-misc.v \

Multiplier_2x16b_RTL-test.d: \
  Multiplier_2x16b_RTL-test.v \
  ece2300-test.v \
  Multiplier_2x16b_RTL.v \
  Multiplier_2x16b-test-cases.v \
  ece2300-misc.v \

ece2300-test.v:

Multiplier_2x16b_RTL.v:

Multiplier_2x16b-test-cases.v:

ece2300-misc.v:

