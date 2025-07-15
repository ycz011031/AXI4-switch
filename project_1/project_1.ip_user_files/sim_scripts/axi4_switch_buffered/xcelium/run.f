-makelib xcelium_lib/xpm -sv \
  "C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
  "C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi4_switch_buffered/ip/axi4_switch_buffered_axi4_switch_custom_0_0/sim/axi4_switch_buffered_axi4_switch_custom_0_0.v" \
-endlib
-makelib xcelium_lib/axis_infrastructure_v1_1_0 \
  "../../../../project_1.gen/sources_1/bd/axi4_switch_buffered/ipshared/8713/hdl/axis_infrastructure_v1_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axis_data_fifo_v2_0_7 \
  "../../../../project_1.gen/sources_1/bd/axi4_switch_buffered/ipshared/4852/hdl/axis_data_fifo_v2_0_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi4_switch_buffered/ip/axi4_switch_buffered_axis_data_fifo_0_1/sim/axi4_switch_buffered_axis_data_fifo_0_1.v" \
  "../../../bd/axi4_switch_buffered/ip/axi4_switch_buffered_axis_data_fifo_0_2/sim/axi4_switch_buffered_axis_data_fifo_0_2.v" \
-endlib
-makelib xcelium_lib/xlconstant_v1_1_7 \
  "../../../../project_1.gen/sources_1/bd/axi4_switch_buffered/ipshared/fcfc/hdl/xlconstant_v1_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi4_switch_buffered/ip/axi4_switch_buffered_xlconstant_0_0/sim/axi4_switch_buffered_xlconstant_0_0.v" \
  "../../../bd/axi4_switch_buffered/ip/axi4_switch_buffered_tkeep_byte_to_dword_0_0/sim/axi4_switch_buffered_tkeep_byte_to_dword_0_0.v" \
  "../../../bd/axi4_switch_buffered/ip/axi4_switch_buffered_tkeep_byte_to_dword_1_0/sim/axi4_switch_buffered_tkeep_byte_to_dword_1_0.v" \
  "../../../bd/axi4_switch_buffered/sim/axi4_switch_buffered.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

