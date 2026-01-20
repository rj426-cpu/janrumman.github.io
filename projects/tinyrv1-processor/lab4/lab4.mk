#=========================================================================
# lab4
#=========================================================================

lab4_srcs = \
  Mux2_32b_RTL.v \
  Mux4_32b_RTL.v \
  Register_32b_RTL.v \
  Adder_32b_GL.v \
  EqComparator_32b_RTL.v \
  ALU_32b.v \
  Multiplier_32x32b_RTL.v \
  ImmGen_RTL.v \
  RegfileZ2r1w_32x32b_RTL.v \
  EdgeDetector_RTL.v \
  ShiftRegister_44b_RTL.v \
  Synchronizer_RTL.v \
  ProcScycleDpath.v \
  ProcScycleCtrl.v \
  ProcScycle.v \
  MemoryBusAddrDecoder_RTL.v \
  MemoryBusDataMux_RTL.v \
  MemoryBusDpath_RTL.v \
  MemoryBusCtrl_RTL.v \
  MemoryBus_RTL.v \
  SPI_RTL.v \
  AccumXcelDpath.v \
  AccumXcelCtrl.v \
  AccumXcel.v \

lab4_partA_tests = \
  Mux2_32b_RTL-test.v \
  Mux4_32b_RTL-test.v \
  Register_32b_RTL-test.v \
  Adder_32b_GL-test.v \
  EqComparator_32b_RTL-test.v \
  ALU_32b-test.v \
  Multiplier_32x32b_RTL-test.v \
  ImmGen_RTL-test.v \
  RegfileZ2r1w_32x32b_RTL-test.v \
  EdgeDetector_RTL-test.v \
  ShiftRegister_44b_RTL-test.v \
  Synchronizer_RTL-test.v \

lab4_partB_tests = \
  ProcFL-addi-test.v \
  ProcFL-add-test.v \
  ProcFL-mul-test.v \
  ProcFL-lw-test.v \
  ProcFL-sw-test.v \
  ProcFL-jal-test.v \
  ProcFL-jr-test.v \
  ProcFL-bne-test.v \
  ProcFL-wait-test.v \
  ProcScycle-addi-test.v \
  ProcScycle-add-test.v \
  ProcScycle-mul-test.v \
  ProcScycle-lw-test.v \
  ProcScycle-sw-test.v \
  ProcScycle-jal-test.v \
  ProcScycle-jr-test.v \
  ProcScycle-bne-test.v \
  ProcScycle-wait-test.v \
  MemoryBusAddrDecoder_RTL-test.v \
  MemoryBusDataMux_RTL-test.v \
  MemoryBus_RTL-test.v \
  SPI_RTL-test.v \

lab4_partC_tests = \
  AccumXcel-test.v \

lab4_tests = \
  $(lab4_partA_tests) \
  $(lab4_partB_tests) \
  $(lab4_partC_tests) \

lab4_sims = \
  proc-isa-sim.v \
  proc-scycle-sim.v \
  accum-xcel-sim.v \

$(eval $(call check_part,lab4_partA))
$(eval $(call check_part,lab4_partB))
$(eval $(call check_part,lab4_partC))
$(eval $(call check_part,lab4))

#-------------------------------------------------------------------------
# assembly
#-------------------------------------------------------------------------

lab4_asms = \
  test1.asm \
  test2.asm \
  test3.asm \
  calculator-step1.asm \
  calculator-step2.asm \
  calculator-step3.asm \
	accumulate.asm \
