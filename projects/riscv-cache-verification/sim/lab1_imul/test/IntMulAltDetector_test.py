#=========================================================================
# IntMulAltDetector_test
#=========================================================================

from pymtl3 import *
from pymtl3.passes.backends.verilog import *
from pymtl3.stdlib.test_utils import config_model_with_cmdline_opts

from lab1_imul.IntMulAltDetector import IntMulAltDetector

#-------------------------------------------------------------------------
# test_bit0
#-------------------------------------------------------------------------

def test_bit0( cmdline_opts ):

  # Create and elaborate the model

  model = IntMulAltDetector()
  model.elaborate()

  # Apply the Verilog import passes and the default pass group

  model.apply( VerilogPlaceholderPass() )
  model = VerilogTranslationImportPass()( model )
  model.apply( DefaultPassGroup(linetrace=True) )

  # Reset simulator

  model.sim_reset()

  # Write inputs and check outputs

  model.b @= 0b00000001
  model.sim_tick()
  assert model.shift_amt == 1

  # Clean up the verilator before next test

  model.finalize()

#-------------------------------------------------------------------------
# test_one_trailing_0
#-------------------------------------------------------------------------

def test_one_trailing_0( cmdline_opts ):

  model = IntMulAltDetector()
  model.elaborate()

  model.apply( VerilogPlaceholderPass() )
  model = VerilogTranslationImportPass()( model )
  model.apply( DefaultPassGroup(linetrace=True) )

  model.sim_reset()

  model.b @= 0b00000010
  model.sim_tick()
  assert model.shift_amt == 1

  model.finalize()

#-------------------------------------------------------------------------
# test_two_trailing_0
#-------------------------------------------------------------------------

def test_two_trailing_0( cmdline_opts ):

  model = IntMulAltDetector()
  model.elaborate()

  model.apply( VerilogPlaceholderPass() )
  model = VerilogTranslationImportPass()( model )
  model.apply( DefaultPassGroup(linetrace=True) )

  model.sim_reset()

  model.b @= 0b00000100
  model.sim_tick()
  assert model.shift_amt == 2

  model.finalize()

#-------------------------------------------------------------------------
# test_three_trailing_0
#-------------------------------------------------------------------------

def test_three_trailing_0( cmdline_opts ):

  model = IntMulAltDetector()
  model.elaborate()

  model.apply( VerilogPlaceholderPass() )
  model = VerilogTranslationImportPass()( model )
  model.apply( DefaultPassGroup(linetrace=True) )

  model.sim_reset()

  model.b @= 0b00001000
  model.sim_tick()
  assert model.shift_amt == 3

  model.finalize()

#-------------------------------------------------------------------------
# test_four_trailing_0
#-------------------------------------------------------------------------

def test_four_trailing_0( cmdline_opts ):

  model = IntMulAltDetector()
  model.elaborate()

  model.apply( VerilogPlaceholderPass() )
  model = VerilogTranslationImportPass()( model )
  model.apply( DefaultPassGroup(linetrace=True) )

  model.sim_reset()

  model.b @= 0b00010000
  model.sim_tick()
  assert model.shift_amt == 4

  model.finalize()

#-------------------------------------------------------------------------
# test_five_trailing_0
#-------------------------------------------------------------------------

def test_five_trailing_0( cmdline_opts ):

  model = IntMulAltDetector()
  model.elaborate()

  model.apply( VerilogPlaceholderPass() )
  model = VerilogTranslationImportPass()( model )
  model.apply( DefaultPassGroup(linetrace=True) )

  model.sim_reset()

  model.b @= 0b00100000
  model.sim_tick()
  assert model.shift_amt == 5

  model.finalize()

#-------------------------------------------------------------------------
# test_six_trailing_0
#-------------------------------------------------------------------------

def test_six_trailing_0( cmdline_opts ):

  model = IntMulAltDetector()
  model.elaborate()

  model.apply( VerilogPlaceholderPass() )
  model = VerilogTranslationImportPass()( model )
  model.apply( DefaultPassGroup(linetrace=True) )

  model.sim_reset()

  model.b @= 0b01000000
  model.sim_tick()
  assert model.shift_amt == 6

  model.finalize()

#-------------------------------------------------------------------------
# test_seven_trailing_0
#-------------------------------------------------------------------------

def test_seven_trailing_0( cmdline_opts ):

  model = IntMulAltDetector()
  model.elaborate()

  model.apply( VerilogPlaceholderPass() )
  model = VerilogTranslationImportPass()( model )
  model.apply( DefaultPassGroup(linetrace=True) )

  model.sim_reset()

  model.b @= 0b10000000
  model.sim_tick()
  assert model.shift_amt == 7

  model.finalize()

#-------------------------------------------------------------------------
# test_all_0
#-------------------------------------------------------------------------

def test_all_0( cmdline_opts ):

  model = IntMulAltDetector()
  model.elaborate()

  model.apply( VerilogPlaceholderPass() )
  model = VerilogTranslationImportPass()( model )
  model.apply( DefaultPassGroup(linetrace=True) )

  model.sim_reset()

  model.b @= 0b00000000
  model.sim_tick()
  assert model.shift_amt == 8

  model.finalize()
