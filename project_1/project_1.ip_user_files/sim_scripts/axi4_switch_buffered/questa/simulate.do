onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib axi4_switch_buffered_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {axi4_switch_buffered.udo}

run -all

quit -force
