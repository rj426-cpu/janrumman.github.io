#=========================================================================
# ece2300
#=========================================================================

ece2300_srcs = \
  SevenSegFL.v \
  TestReadOnlyMemory.v \

# ece2300_tests = \
#   TestReadOnlyMemory-test.v \

$(eval $(call check_part,ece2300))
