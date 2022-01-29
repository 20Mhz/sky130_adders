SED := gsed
NETLIST ?= netlist.vg
TOP_MODULE ?= top
STDCELL_LIB ?= /Users/ronaldv/Projects/repositories/open_pdks/sky130/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ss_100C_1v60.lib
WIDTH ?= 32

all: %.svg

%:
	yosys	-p "read_verilog -defer  -sv -formal ../rtl/$@.v " \
				-p "select -list "\
				-p "select -module \$$abstract\$(TOP_MODULE)"  \
				-p "chparam -set N 32"  \
				-p "hierarchy -top $(TOP_MODULE)"  \
				-p "proc"  \
				-p "write_json $@.json" \
				-p "write_verilog $@.vg"
				#-p "CONSTMAP; opt_muxtree; opt_const -mux_undef -mux_bool -fine;" \
				-p "opt_muxtree; " \
				-p "
	netlistsvg $@.json  -o $@.svg
sta:
	$(SED) -E "s/(read_verilog) ([a-zA-Z_.]+).*/\1 $(NETLIST)/" -i ../scripts/sta.tcl
	$(SED) -E "s/(set current_design_name) ([a-zA-Z]+).*/\1 $(TOP_MODULE)/" -i ../scripts/sta.tcl 
	openroad ../scripts/sta.tcl | tee $(NETLIST).sta

%.svg: pkg.json
	netlistsvg pgk.json  -o pgk.svg

clean:
	rm *.svg *.json

