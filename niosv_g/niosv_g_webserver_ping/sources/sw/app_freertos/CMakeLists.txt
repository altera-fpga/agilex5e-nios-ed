cmake_minimum_required(VERSION 3.14)

add_subdirectory(../bsp_freertos bsp_freertos)

include(../bsp_freertos/toolchain.cmake)

project(app_freertos)

enable_language(ASM)
enable_language(C)
enable_language(CXX)

add_executable(app_freertos.elf)

target_sources(app_freertos.elf
    PRIVATE
        main.c
)

target_include_directories(app_freertos.elf
    PRIVATE
    PUBLIC
)

target_link_libraries(app_freertos.elf
    PRIVATE
        -T "${BspLinkerScript}" -nostdlib
        "${ExtraArchiveLibraries}"
        -Wl,--start-group "${BspLibraryName}" -lc -lstdc++ -lgcc -lm -Wl,--end-group
)

# Create objdump from ELF.
set(objdump app_freertos.elf.objdump)
add_custom_command(
    OUTPUT "${objdump}"
    DEPENDS app_freertos.elf
    COMMAND "${ToolchainObjdump}" "${ToolchainObjdumpFlags}" app_freertos.elf >
            "${objdump}"
    COMMENT "Creating ${objdump}."
    VERBATIM
)
add_custom_target(create-objdump ALL DEPENDS "${objdump}")

# Report space free for stack + heap. Note that the file below is never created
# so the report is always output on build.
set(stack_report_file app_freertos.elf.stack_report)
add_custom_command(
    OUTPUT "${stack_report_file}"
    DEPENDS app_freertos.elf
    COMMAND niosv-stack-report -p "${ToolchainPrefix}" app_freertos.elf
    COMMENT "Reporting memory available for stack + heap in app_freertos.elf."
    VERBATIM
)
add_custom_target(niosv-stack-report ALL DEPENDS "${stack_report_file}")

# Generate HEX file(s) from app_freertos.elf using elf2hex tool.
# Note : If ECC Full is enabled, width of 39 is set for NiosV TCM. Otherwise, 32.
add_custom_command(
    OUTPUT "sys_desc_mem.hex"
    DEPENDS app_freertos.elf
    COMMAND elf2hex app_freertos.elf -o sys_desc_mem.hex -b 0x00210000 -w 32 -e 0x00211FFF -r 4
    COMMENT "Creating sys_desc_mem.hex."
    VERBATIM
)
add_custom_command(
    OUTPUT "sys_cpu_ram.hex"
    DEPENDS app_freertos.elf
    COMMAND elf2hex app_freertos.elf -o sys_cpu_ram.hex -b 0x00000000 -w 32 -e 0x001E847F -r 4
    COMMENT "Creating sys_cpu_ram.hex."
    VERBATIM
)
add_custom_target(create-hex ALL DEPENDS "sys_desc_mem.hex" "sys_cpu_ram.hex")
