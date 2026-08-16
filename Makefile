TOP       = apb_uart_tb
SIM       = simv
VERILATOR = verilator
# Selecting the Verilator C++ compiler/optimizer
export CXX       := clang++
export LINK	  	 := clang++
# Your UVM_HOME already points to:
# /home/muzzy_ubuntu/tools/uvm/1800.2-2017-1.0/src
UVM_HOME ?= /home/muzzy_ubuntu/tools/uvm/1800.2-2017-1.0/src

UVM_TESTNAME = apb_uart_rif_smoke_test
SIM_FLAGS += +UVM_TESTNAME=$(UVM_TESTNAME) 

DUMP?=0
ifeq ($(DUMP),1)
    VERILATOR_FLAGS += --trace-fst
endif

VERILATOR_FLAGS += \
	-sv \
	-O3 \
	-j 8 \
	-CFLAGS "-Os -fstrict-aliasing -march=native" \
	-LDFLAGS "-fuse-ld=lld" \
	-Wno-fatal \
	--compiler clang \
	--no-decoration \
	--threads 4 \
	--binary \
	--timing \
	--top-module $(TOP) \
	+incdir+. \
	+incdir+$(UVM_HOME) \
	+define+UVM_NO_DEPRECATED \
	+define+UVM_NO_DPI \
	"$(UVM_HOME)/uvm_pkg.sv" \
	-o $(SIM)

slang_rtl:
	slang -f flist_uart.rtl

slang_verif:
	slang \
	-I "$(UVM_HOME)" \
	"$(UVM_HOME)/uvm_pkg.sv" \
	-f flist_uart.verif

all: build run

build:
	$(VERILATOR) $(VERILATOR_FLAGS) -f flist_uart.verif

run:
	./obj_dir/$(SIM) $(SIM_FLAGS)

clean:
	rm -rf obj_dir logs *.vcd *.fst *.log

