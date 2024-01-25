project(kernel)
file(GLOB_RECURSE ASM_FILES CONFIGURE_DEPENDS
        src/*.nasm
)

file(GLOB_RECURSE C_FILES CONFIGURE_DEPENDS
        src/*.c
        src/*.cpp
        include/*.h
        include/*.hpp
)

set(LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/linker.ld")

add_executable(kernel ${C_FILES} ${ASM_FILES})
target_include_directories(kernel PUBLIC include)
set_target_properties(
        kernel
        PROPERTIES LINK_FLAGS "-T ${LINKER_SCRIPT}"
)
set_source_files_properties(
        src/boot/bootstrap64.nasm
        PROPERTIES OBJECT_DEPENDS ${LINKER_SCRIPT}
)
target_link_libraries(kernel PRIVATE libk)
