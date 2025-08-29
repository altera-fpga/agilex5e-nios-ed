niosv-bsp -c --quartus-project=hw/top.qpf --qsys=hw/qsys_top.qsys --type=hal sw/bsp_hal/settings.bsp
niosv-app --bsp-dir=sw/bsp_hal --app-dir=sw/app_hal --srcs=sw/app_hal/main.c
cmake -S ./sw/app_hal -B sw/app_hal/build
make -C sw/app_hal/build
elf2hex sw/app_hal/build/app_hal.elf -b 0x0 -w 32 -e 0x7ffff ./hw/onchip_mem.hex