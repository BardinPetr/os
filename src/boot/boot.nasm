%include "src/boot/multiboot.nasm"

; allocate stack
section .bss
align 16
    stack_bottom:
    resb 16*1024
    stack_top:


section .text
global _start:function (_start.end - _start)
_start:
    ; prepare stack
    mov     esp, stack_top

    ; start
    extern  kernel_init
    call    kernel_init

    cli
.hang:
    hlt
    jmp .hang
.end: