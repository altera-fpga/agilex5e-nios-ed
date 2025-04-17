# Settings
set_setting hal.make.cflags_defined_symbols {-DTF_LITE_STATIC_MEMORY}
set_setting hal.make.cflags_optimization {-O3}
set_setting hal.make.cflags_user_flags {-ffunction-sections -fdata-sections -fno-rtti -fno-exceptions}
set_setting hal.make.cxx_flags {-std=c++17}
set_setting hal.make.link_flags {-Wl,--gc-sections}