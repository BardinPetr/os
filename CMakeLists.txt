cmake_minimum_required(VERSION 3.26)
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

project(os C)

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_FLAGS "-std=c17 -ffreestanding -O2 -Wall -Wextra -masm=intel")

# link
set(LINKER_SCRIPT "linker.ld")
set(CMAKE_EXE_LINKER_FLAGS "-ffreestanding -O2 -nostdlib -lgcc")
#add_link_options(-T ${LINKER_SCRIPT})

# asm config
enable_language(ASM_NASM)
set(CAN_USE_ASSEMBLER TRUE)
set(CMAKE_ASM_NASM_OBJECT_FORMAT elf32)
set(CMAKE_ASM_NASM_LINK_EXECUTABLE "<CMAKE_LINKER> <CMAKE_ASM_NASM_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
add_compile_options(-I ${CMAKE_CURRENT_SOURCE_DIR}/)

# asm
file(GLOB_RECURSE ASM_FILES CONFIGURE_DEPENDS
        src/*.nasm
)

# c
file(GLOB_RECURSE C_FILES CONFIGURE_DEPENDS
        src/*.c
        include/*.h
)

add_executable(os ${C_FILES} ${ASM_FILES})
target_include_directories(os PRIVATE src include)

set_target_properties(os PROPERTIES LINK_FLAGS "-T ${CMAKE_CURRENT_SOURCE_DIR}/linker.ld")