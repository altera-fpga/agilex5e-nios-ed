niosv-bsp -c --quartus-project=hw/top.qpf --qsys=hw/qsys_top.qsys --type=freertos sw/bsp_freertos/settings.bsp
niosv-app --bsp-dir=sw/bsp_freertos --app-dir=sw/app_freertos --srcs=sw/app_freertos/main.c
cmake -S ./sw/app_freertos -B sw/app_freertos/build
make -C sw/app_freertos/build
