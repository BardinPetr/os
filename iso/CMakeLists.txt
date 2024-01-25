add_custom_target(os.iso
        COMMAND mkdir -p ${PROJECT_BINARY_DIR}/iso/boot/grub
        COMMAND cp ${PROJECT_SOURCE_DIR}/iso/grub.cfg ${PROJECT_BINARY_DIR}/iso/boot/grub
        COMMAND cp $<TARGET_FILE:kernel> ${PROJECT_BINARY_DIR}/iso/boot/kernel
        COMMAND grub-mkrescue -o ${PROJECT_BINARY_DIR}/os.iso ${PROJECT_BINARY_DIR}/iso
        COMMAND echo ${CRTEND_OBJ}
        DEPENDS kernel
)