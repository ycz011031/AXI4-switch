vlib work
vlib activehdl

vlib activehdl/xpm
vlib activehdl/xil_defaultlib
vlib activehdl/axis_infrastructure_v1_1_0
vlib activehdl/axis_data_fifo_v2_0_7
vlib activehdl/xlconstant_v1_1_7

vmap xpm activehdl/xpm
vmap xil_defaultlib activehdl/xil_defaultlib
vmap axis_infrastructure_v1_1_0 activehdl/axis_infrastructure_v1_1_0
vmap axis_data_fifo_v2_0_7 activehdl/axis_data_fifo_v2_0_7
vmap xlconstant_v1_1_7 activehdl/xlconstant_v1_1_7

vlog -work xpm  -sv2k12 "+incdir+../../../../project_1.gen/sources_1/bd/axi4_switch_buffered/ipshared/8713/hdl" \
"C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../project_1.gen/sources_1/bd/axi4_switch_buffered/ipshared/8713/hdl" \
"../../../bd/axi4_switch_buffered/ip/axi4_switch_buffered_axi4_switch_custom_0_0/sim/axi4_switch_buffered_axi4_switch_custom_0_0.v" \

vlog -work axis_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../project_1.gen/sources_1/bd/axi4_switch_buffered/ipshared/8713/hdl" \
"../../../../project_1.gen/sources_1/bd/axi4_switch_buffered/ipshared/8713/hdl/axis_infrastructure_v1_1_vl_rfs.v" \

vlog -work axis_data_fifo_v2_0_7  -v2k5 "+incdir+../../../../project_1.gen/sources_1/bd/axi4_switch_buffered/ipshared/8713/hdl" \
"../../../../project_1.gen/sources_1/bd/axi4_switch_buffered/ipshared/4852/hdl/axis_data_fifo_v2_0_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../project_1.gen/sources_1/bd/axi4_switch_buffered/ipshared/8713/hdl" \
"../../../bd/axi4_switch_buffered/ip/axi4_switch_buffered_axis_data_fifo_0_1/sim/axi4_switch_buffered_axis_data_fifo_0_1.v" \
"../../../bd/axi4_switch_buffered/ip/axi4_switch_buffered_axis_data_fifo_0_2/sim/axi4_switch_buffered_axis_data_fifo_0_2.v" \

vlog -work xlconstant_v1_1_7  -v2k5 "+incdir+../../../../project_1.gen/sources_1/bd/axi4_switch_buffered/ipshared/8713/hdl" \
"../../../../project_1.gen/sources_1/bd/axi4_switch_buffered/ipshared/fcfc/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../project_1.gen/sources_1/bd/axi4_switch_buffered/ipshared/8713/hdl" \
"../../../bd/axi4_switch_buffered/ip/axi4_switch_buffered_xlconstant_0_0/sim/axi4_switch_buffered_xlconstant_0_0.v" \
"../../../bd/axi4_switch_buffered/ip/axi4_switch_buffered_tkeep_byte_to_dword_0_0/sim/axi4_switch_buffered_tkeep_byte_to_dword_0_0.v" \
"../../../bd/axi4_switch_buffered/ip/axi4_switch_buffered_tkeep_byte_to_dword_1_0/sim/axi4_switch_buffered_tkeep_byte_to_dword_1_0.v" \
"../../../bd/axi4_switch_buffered/sim/axi4_switch_buffered.v" \

vlog -work xil_defaultlib \
"glbl.v"

