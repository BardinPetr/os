cmake_minimum_required(VERSION 3.26)
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

project(os C)
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_C_STANDARD 17)

# c
set(FLAGS_DISABLE "-fno-PIC -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-ssse3 -mno-sse4.1 -mno-sse4.2 -mno-sse4 -mno-sse4a -mno-3dnow -mno-avx -mno-avx2")
set(FLAGS_COMMON "-mcmodel=large -pedantic -W -Wall -Wextra -masm=intel -ffreestanding ${FLAGS_DISABLE}")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}   ${FLAGS_COMMON}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${FLAGS_COMMON} -fno-exceptions -fno-rtti -fuse-cxa-atexit -fno-threadsafe-statics")

# link
set(LINKER_SCRIPT "linker.ld")
set(CMAKE_EXE_LINKER_FLAGS "-ffreestanding -nostdlib -lgcc -mcmodel=large -n -z max-page-size=0x1000")

# nasm config
enable_language(ASM_NASM)
set(CAN_USE_ASSEMBLER TRUE)
set(CMAKE_ASM_NASM_OBJECT_FORMAT elf64)
set(CMAKE_ASM_NASM_LINK_EXECUTABLE "<CMAKE_LINKER> <CMAKE_ASM_NASM_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
add_compile_options(-I ${CMAKE_CURRENT_SOURCE_DIR}/src/)

# asm
file(GLOB_RECURSE ASM_FILES CONFIGURE_DEPENDS
        src/*.nasm
)

# c
file(GLOB_RECURSE C_FILES CONFIGURE_DEPENDS
        src/*.c
        include/*.h
)

add_executable(kernel.elf ${C_FILES} ${ASM_FILES})
target_include_directories(kernel.elf PRIVATE src include)
set_target_properties(kernel.elf PROPERTIES LINK_FLAGS "-T ${CMAKE_CURRENT_SOURCE_DIR}/linker.ld")
set_source_files_properties(
        src/boot/boot.nasm PROPERTIES OBJECT_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/linker.ld
)

add_custom_target(os.iso
        COMMAND mkdir -p ${PROJECT_BINARY_DIR}/iso/boot/grub
        COMMAND cp ${PROJECT_SOURCE_DIR}/iso/grub.cfg ${PROJECT_BINARY_DIR}/iso/boot/grub
        COMMAND cp $<TARGET_FILE:kernel.elf> ${PROJECT_BINARY_DIR}/iso/boot/kernel.elf
        COMMAND grub-mkrescue -o ${PROJECT_BINARY_DIR}/os.iso ${PROJECT_BINARY_DIR}/iso

        DEPENDS kernel.elf
)