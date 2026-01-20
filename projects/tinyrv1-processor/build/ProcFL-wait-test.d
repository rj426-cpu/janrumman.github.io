#=========================================================================
# Makefile dependency fragment
#=========================================================================

ProcFL-wait-test: \
  ProcFL-wait-test.v \
  ece2300-test.v \
  ece2300-misc.v \
  ProcFL.v \
  Proc-wait-test-cases.v \
  tinyrv1.v \

ProcFL-wait-test.d: \
  ProcFL-wait-test.v \
  ece2300-test.v \
  ece2300-misc.v \
  ProcFL.v \
  Proc-wait-test-cases.v \
  tinyrv1.v \

ece2300-test.v:

ece2300-misc.v:

ProcFL.v:

Proc-wait-test-cases.v:

tinyrv1.v:

