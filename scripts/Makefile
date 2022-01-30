SED := gsed
NETLIST ?= netlist.vg
TOP_MODULE ?= top
RTL ?= ./carrySkip.vg
TEST_BENCH ?= ../sim/adder_tb.v
STDCELL_LIB ?= /Users/ronaldv/Projects/repositories/open_pdks/sky130/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ss_100C_1v60.lib
PRIMITIVES ?= /Users/ronaldv/Projects/repositories/open_pdks/sky130/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
STDCELL_BEHAV ?= /Users/ronaldv/Projects/repositories/open_pdks/sky130/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
WIDTH ?= 32

all: %.svg

%:
	mkdir -p results
	yosys	-p "read_verilog -lib $(STDCELL_BEHAV)" \
				-p "read_verilog -defer  -sv -formal ../rtl/$@.v " \
				-p "select -list "\
				-p "select -module \$$abstract\$(TOP_MODULE)"  \
				-p "chparam -set N 32"  \
				-p "hierarchy -top $(TOP_MODULE)"  \
				-p "proc"  \
				-p "write_json results/$@.json" \
				-p "write_verilog results/$@.vg"
				#-p "CONSTMAP; opt_muxtree; opt_const -mux_undef -mux_bool -fine;" \
				-p "opt_muxtree; " \
				-p "
	netlistsvg results/$@.json  -o results/$@.svg

gate_sim:
	iverilog -o $(TOP_MODULE).sim -D THE_DUT=$(TOP_MODULE) -D WIDTH=32 $(PRIMITIVES) $(STDCELL_BEHAV) $(NETLIST) $(TEST_BENCH) 

sta:
	mkdir -p reports
	$(SED) -E "s/(read_verilog) ([a-zA-Z_.]+).*/\1 $(subst /,\/,$(NETLIST))/" -i ../scripts/sta.tcl
	$(SED) -E "s/(set TOP_MODULE) ([a-zA-Z]+).*/\1 $(TOP_MODULE)/" -i ../scripts/sta.tcl 
	openroad ../scripts/sta.tcl | tee reports/$(TOP_MODULE).sta

clean:
	rm *.svg *.json

