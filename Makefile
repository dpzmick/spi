.SUFFIXES:
.PHONY: bin clean
BUILD_DIR ?= build
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -Werror -O3 -c -isystem/usr/share/verilator/include/ -I${BUILD_DIR}/verilator_dir/ -I./
VERILATOR_CXXFLAGS = -std=c++17 -O3 -c -isystem/usr/share/verilator/include/
LDFLAGS =

all: bin

# tricks to build the verilator objects we need
${BUILD_DIR}/obj/verilated.o: /usr/share/verilator/include/verilated.cpp
	@mkdir -p $(shell dirname $@)
	${CXX} ${VERILATOR_CXXFLAGS} $< -o $@

${BUILD_DIR}/dep/verilated.d: /usr/share/verilator/include/verilated.cpp
	@mkdir -p $(shell dirname $@)
	@touch $@

# -MG is important because headers might not all exist
${BUILD_DIR}/dep/%.d: %.cpp
	@mkdir -p $(shell dirname $@)
	${CXX} ${CXXFLAGS} $< -MM -MG -MT $(patsubst ${BUILD_DIR}/dep/%.d,${BUILD_DIR}/obj/%.o,$@) -o $@

${BUILD_DIR}/obj/%.o: %.cpp
	@mkdir -p $(shell dirname $@)
	${CXX} ${CXXFLAGS} $< -o $@

# Can't really get this to work without recurisve make
${BUILD_DIR}/verilator_dir/%__ALL.a ${BUILD_DIR}/verilator_dir/%.h: %.v
	@mkdir -p $(shell dirname $@)
	verilator -cc --prefix $(shell basename $*) $< --Mdir $(shell dirname $@)
	make -C $(shell dirname $@) -f $(shell basename $*).mk

# $(1): name of binary
# $(2): list of objects to link in
# $(3): list of verilog modules needed
# important to include all of the dependency files explicitly because make will
# attempt to create them if they do not exist, then include them
define _add-bin
${BUILD_DIR}/bin/${1}: $(foreach obj,${2},$(patsubst %,${BUILD_DIR}/obj/%.o,${obj})) $(foreach obj,${3},$(patsubst %,${BUILD_DIR}/verilator_dir/%__ALL.a,${obj}))
	@mkdir -p ${BUILD_DIR}/bin/
	${CXX} ${LDFLAGS} $$^ -o $$@
bin: ${BUILD_DIR}/bin/${1}
include $(foreach obj,${2},$(patsubst %,${BUILD_DIR}/dep/%.d,${2}))
endef
add-bin = $(eval $(call _add-bin,${1},${2},${3}))

# final targets

MAIN_OBJS    = verilator_tb/main verilated
MAIN_VERILOG = verilog/spi
$(call add-bin,main,${MAIN_OBJS},${MAIN_VERILOG})
