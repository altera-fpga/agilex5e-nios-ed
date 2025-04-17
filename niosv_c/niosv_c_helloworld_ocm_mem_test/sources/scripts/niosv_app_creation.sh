# (C) 2001-2025 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


niosv-bsp -c --quartus-project=hw/top.qpf --qsys=hw/qsys_top.qsys --type=hal --script=sw/bsp-update-small-driver.tcl sw/bsp/settings.bsp
niosv-app --bsp-dir=sw/bsp --app-dir=sw/app --srcs=sw/app/main.c
cmake -S ./sw/app -B sw/app/build
make -C sw/app/build
elf2hex sw/app/build/app.elf -b 0x0 -w 32 -e 0xfffff hw/onchip_mem.hex -r4
# cp -rf hw/onchip_mem.hex hw/qsys_top_tb/qsys_top_tb/sim/mentor/
