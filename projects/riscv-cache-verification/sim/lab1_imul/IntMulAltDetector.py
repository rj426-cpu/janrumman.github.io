#=========================================================================
# IntMulAlt_detector PyMTL3 Wrapper
#=========================================================================

from pymtl3 import *
from pymtl3.passes.backends.verilog import *

class IntMulAltDetector( VerilogPlaceholder, Component ):
  def construct( s ):
    s.b         = InPort(  Bits32 )
    s.shift_amt = OutPort( Bits4  )

