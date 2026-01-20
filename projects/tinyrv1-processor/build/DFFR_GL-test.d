#=========================================================================
# Makefile dependency fragment
#=========================================================================

DFFR_GL-test: \
  DFFR_GL-test.v \
  ece2300-test.v \
  DFFR_GL.v \
  DFFR-test-cases.v \
  DFF_GL.v \
  ece2300-misc.v \
  DLatch_GL.v \

DFFR_GL-test.d: \
  DFFR_GL-test.v \
  ece2300-test.v \
  DFFR_GL.v \
  DFFR-test-cases.v \
  DFF_GL.v \
  ece2300-misc.v \
  DLatch_GL.v \

ece2300-test.v:

DFFR_GL.v:

DFFR-test-cases.v:

DFF_GL.v:

ece2300-misc.v:

DLatch_GL.v:

