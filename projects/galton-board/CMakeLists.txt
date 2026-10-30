# == DO NOT EDIT THE FOLLOWING LINES for the Raspberry Pi Pico VS Code Extension to work ==
if(WIN32)
    set(USERHOME $ENV{USERPROFILE})
else()
    set(USERHOME $ENV{HOME})
endif()
set(sdkVersion 2.3.1)
set(toolchainVersion 15_2_Rel1)
set(picotoolVersion 2.3.1)
set(picoVscode ${USERHOME}/.pico-sdk/cmake/pico-vscode.cmake)
if (EXISTS ${picoVscode})
    include(${picoVscode})
endif()
# ====================================================================================
# Generated Cmake Pico project file

cmake_minimum_required(VERSION 3.13)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(WIN32)
    set(USERHOME $ENV{USERPROFILE})
else()
    set(USERHOME $ENV{HOME})
endif()

set(sdkVersion 2.3.1)
set(toolchainVersion 15_2_Rel1)
set(picotoolVersion 2.3.1)
set(picoVscode ${USERHOME}/.pico-sdk/cmake/pico-vscode.cmake)

if (EXISTS ${picoVscode})
    include(${picoVscode})
endif()

set(PICO_BOARD pico2 CACHE STRING "Board type")

# Pull in Raspberry Pi Pico SDK
include(pico_sdk_import.cmake)

project(galton_board C CXX ASM)

# Initialise the Raspberry Pi Pico SDK
pico_sdk_init()

# Create executable
add_executable(galton_board
    galton_board.c
    VGA/vga16_graphics_v3.c
)

pico_set_program_name(galton_board "galton_board")
pico_set_program_version(galton_board "0.1")

# UART / USB
pico_enable_stdio_uart(galton_board 0)
pico_enable_stdio_usb(galton_board 1)

# Libraries
target_link_libraries(galton_board
    pico_stdlib
    pico_divider
    pico_multicore
    pico_sync
    hardware_pio
    hardware_dma
    hardware_spi
    hardware_irq
    hardware_clocks
    hardware_pll
    hardware_vreg
    m
)

# Include directories
target_include_directories(galton_board PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}
)

# VGA PIO programs
pico_generate_pio_header(galton_board
    ${CMAKE_CURRENT_LIST_DIR}/VGA/hsync.pio
)

pico_generate_pio_header(galton_board
    ${CMAKE_CURRENT_LIST_DIR}/VGA/vsync.pio
)

pico_generate_pio_header(galton_board
    ${CMAKE_CURRENT_LIST_DIR}/VGA/rgb.pio
)

# Generate UF2/bin/etc.
pico_add_extra_outputs(galton_board)