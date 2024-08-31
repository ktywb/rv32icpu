set search_path [concat "/usr/local/lib/hit18-lib/kyoto_lib/synopsys/" $search_path]
set LIB_MAX_FILE {HIT018.db}
set link_library $LIB_MAX_FILE
set target_library $LIB_MAX_FILE

##read_verilog module
read_verilog regfile.v
read_verilog decoder.v
read_verilog defines.v
read_verilog ex2mem.v
read_verilog ex_alu.v
read_verilog calcu.v
read_verilog calcu2.v
read_verilog id2ex.v
read_verilog if2id.v
read_verilog mem2wb.v
read_verilog other_modules.v
read_verilog pc_reg.v
read_verilog rf32x32.v
read_verilog ppl_datapath_test.v
read_verilog includes.v
read_verilog top.v

current_design "top" 
#read_verilog topmodule
##current_design "TOP_MODULE_NAME"
set_max_area 0
set_max_fanout 64 [current_design]


# Create Clock 
 create_clock -period 4.99 clkk 
 set_clock_uncertainty -setup 0.0 [get_clock clkk] 
 set_clock_uncertainty -hold 0.0 [get_clock clkk] 
 set_input_delay 0.0 -clock clkk [remove_from_collection [all_inputs] clkk] 
 set_output_delay 0.0 -clock clkk [remove_from_collection [all_outputs] clkk] 
  
 # Check if Clock is created 
 derive_clocks 
  
 # Start Logical Synthesis 
 compile 
 ungroup -all -flatten 
 compile -map_effort high -area_effort high -incremental_mapping 
  
 # Check Design 
 check_design 
  
 # Show results 
 
 #report_cell 
 report_area
 report_power
 report_timing -net 
write -hier -format verilog -output HOGEHOGE_PROC.vnet
write -hier -output HOGEHOGE_PROC.db    

quit