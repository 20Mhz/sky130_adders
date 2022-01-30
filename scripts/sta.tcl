# Setup Tech
set LIB_DIR /Users/ronaldv/Projects/repositories/open_pdks/sky130/sky130A/libs.ref/sky130_fd_sc_hd/lib/
# slow
set SLOW_LIB sky130_fd_sc_hd__ss_100C_1v60.lib
# Fast
set FAST_LIB sky130_fd_sc_hd__ff_100C_1v65.lib 

define_corners slow fast
read_liberty -corner slow ${LIB_DIR}/${SLOW_LIB}
read_liberty -corner fast ${LIB_DIR}/${FAST_LIB}
read_lef /Users/ronaldv/Projects/repositories/open_pdks/sky130/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef

# Read the design
set TOP_MODULE carryLookAhead
read_verilog results/carryLookAhead.vg
set current_design_name ${TOP_MODULE}
link 

# Consrain
create_clock -name clk -period 10
set_input_delay -clock clk 0 A
set_input_delay -clock clk 0 B
set_output_delay -clock clk 0 S*
set_input_delay -clock clk 0 Cin
set_output_delay -clock clk 0 Cout   

if {$current_design_name=="carrySkip"} {
	set all_mux_selects [get_pins -hierarchical *S]
	set first_mux_select [get_pins csa[1].u_CSA/u_MUX/S]
	set_case_analysis 1 ${all_mux_selects}
	set_case_analysis 0 ${first_mux_select}
}
# report
report_checks -format full -digits 4 -fields {capacitance transition}
exit
