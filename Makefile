slang_rtl:
	slang -f flist_uart.rtl

slang_verif:
	slang \
	-I "$(UVM_HOME)" \
	"$(UVM_HOME)/uvm_pkg.sv" \
	-f flist_uart.verif

