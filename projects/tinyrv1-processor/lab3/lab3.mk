#=========================================================================
# lab3
#=========================================================================

lab3_srcs = \
  DLatch_GL.v \
  DFF_GL.v \
  DFF_RTL.v \
  DFFR_GL.v \
  DFFR_RTL.v \
  DFFRE_GL.v \
  DFFRE_RTL.v \
  Register_16b_GL.v \
  Register_16b_RTL.v \
  EqComparator_16b_GL.v \
  Counter_16b_GL.v \
  Counter_16b_RTL.v \
  NotePlayerCtrl_GL.v \
  NotePlayerCtrl_RTL.v \
  NotePlayer_GL.v \
  NotePlayer_RTL.v \
  EqComparator_16b_RTL.v \
  Mux2_3b_RTL.v \
  Mux8_1b_RTL.v \
  MultiNotePlayer_RTL.v \
  MusicPlayer_RTL.v \
  MusicPlayerCtrl_RTL.v \
  MusicPlayerDpath_RTL.v \
	ClockDiv_RTL.v \

lab3_partA_tests = \
  DLatch_GL-test.v \
  DFF_GL-test.v \
  DFF_RTL-test.v \
  DFFR_GL-test.v \
  DFFR_RTL-test.v \
  DFFRE_GL-test.v \
  DFFRE_RTL-test.v \
  Register_16b_GL-test.v \
  Register_16b_RTL-test.v \
  EqComparator_16b_GL-test.v \
  Counter_16b_GL-test.v \
  Counter_16b_RTL-test.v \
  NotePlayerCtrl_GL-test.v \
  NotePlayerCtrl_RTL-test.v \
  NotePlayer_GL-test.v \
  NotePlayer_RTL-test.v \

lab3_partB_tests = \
  EqComparator_16b_RTL-test.v \
  Mux2_3b_RTL-test.v \
  Mux8_1b_RTL-test.v \
  MultiNotePlayer_RTL-test.v \
  MusicPlayer_RTL-test.v \
	ClockDiv_RTL-test.v \

lab3_tests = \
  $(lab3_partA_tests) \
  $(lab3_partB_tests) \

lab3_sims = \
  counter-sim.v \
  note-player-sim.v \
  multi-note-player-sim.v \
  music-player-sim.v \

$(eval $(call check_part,lab3_partA))
$(eval $(call check_part,lab3_partB))
$(eval $(call check_part,lab3))

