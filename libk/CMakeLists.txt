project(libk)

file(GLOB_RECURSE FILES CONFIGURE_DEPENDS
        lib/*.c
        include/*.h
)
add_library(libk ${FILES})
target_include_directories(libk PUBLIC include ../kernel/include)
target_link_libraries(libk PRIVATE kernel)
