niosv-bsp -c --quartus-project=hw/top.qpf --qsys=hw/qsys_top.qsys --type=hal sw/bsp/settings.bsp
niosv-app --bsp-dir=sw/bsp --app-dir=sw/app --srcs=sw/app/main.c
cmake -S ./sw/app -B sw/app/build
make -C sw/app/build
#niosv-download -g sw/niosv_app/build/niosv_app.elf -c 1
# elf2hex sw/app/build/app.elf -b 0x0 -w 32 -e 0x9ffff hw/qsys_top_tb/qsys_top_tb/sim/mentor/onchip_mem.hex -r4
elf2hex sw/app/build/app.elf -b 0x0 -w 32 -e 0xfffff hw/onchip_mem.hex -r4
