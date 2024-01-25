cmake_minimum_required(VERSION 3.23)
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

project(os C)
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_C_STANDARD 17)

# c
set(FLAGS_DISABLE "-fno-PIC -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-ssse3 -mno-sse4.1 -mno-sse4.2 -mno-sse4 -mno-sse4a -mno-3dnow -mno-avx -mno-avx2")
set(FLAGS_COMMON "-g -mcmodel=large -pedantic -W -Wall -Wextra -masm=intel -ffreestanding ${FLAGS_DISABLE}")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}   ${FLAGS_COMMON}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${FLAGS_COMMON} -fno-exceptions -fno-rtti -fuse-cxa-atexit -fno-threadsafe-statics")

# crt* file locations
execute_process(COMMAND ${CMAKE_C_COMPILER} -print-file-name=crtbegin.o OUTPUT_VARIABLE CRTBEGIN_OBJ)
execute_process(COMMAND ${CMAKE_C_COMPILER} -print-file-name=crtend.o OUTPUT_VARIABLE CRTEND_OBJ)

# link
set(LINKER_SCRIPT "kernel/linker.ld")
set(CMAKE_EXE_LINKER_FLAGS "-g -ffreestanding -nostdlib -lgcc -mcmodel=large -n -z max-page-size=0x1000")

# nasm config
enable_language(ASM_NASM)
set(CAN_USE_ASSEMBLER TRUE)
set(CMAKE_ASM_NASM_OBJECT_FORMAT elf64)
set(CMAKE_ASM_NASM_FLAGS_DEBUG "-g")
set(CMAKE_ASM_NASM_LINK_FLAGS "${CMAKE_ASM_NASM_LINK_FLAGS} -g")
set(CMAKE_ASM_NASM_LINK_EXECUTABLE "<CMAKE_LINKER> <CMAKE_ASM_NASM_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
add_compile_options(-I kernel/src/)


add_subdirectory(libk)
add_subdirectory(kernel)
add_subdirectory(iso)
