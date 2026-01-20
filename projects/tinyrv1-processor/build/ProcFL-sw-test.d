#=========================================================================
# Makefile dependency fragment
#=========================================================================

ProcFL-sw-test: \
  ProcFL-sw-test.v \
  ece2300-test.v \
  ece2300-misc.v \
  ProcFL.v \
  Proc-sw-test-cases.v \
  tinyrv1.v \

ProcFL-sw-test.d: \
  ProcFL-sw-test.v \
  ece2300-test.v \
  ece2300-misc.v \
  ProcFL.v \
  Proc-sw-test-cases.v \
  tinyrv1.v \

ece2300-test.v:

ece2300-misc.v:

ProcFL.v:

Proc-sw-test-cases.v:

tinyrv1.v:

