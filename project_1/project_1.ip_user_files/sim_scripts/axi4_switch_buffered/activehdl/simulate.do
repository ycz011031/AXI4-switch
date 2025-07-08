onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+axi4_switch_buffered -L xpm -L xil_defaultlib -L axis_infrastructure_v1_1_0 -L axis_data_fifo_v2_0_7 -L xlconstant_v1_1_7 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.axi4_switch_buffered xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {axi4_switch_buffered.udo}

run -all

endsim

quit -force
