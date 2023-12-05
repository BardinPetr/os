; allocate stack
section .bss
stack_bottom: resb 16*1024
stack_top:

section .text
bits 64

global _start64
_start64:
    ; prepare stack
    mov rsp, stack_top

    extern kernel_init
    call kernel_init

    hlt
