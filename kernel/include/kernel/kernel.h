#ifndef OS_KERNEL_C_H
#define OS_KERNEL_C_H

#define KERNEL_LMA 0xFFFFFF8000000000

void kernel_init(unsigned long magic, unsigned long mbi);


#endif //OS_KERNEL_C_H
