MSR_IA32_EFER equ 0xC0000080

PT_ENTRY_SIZE equ 8
PT_ENTRY_P equ 1 << 0
PT_ENTRY_W equ 1 << 1
PT_ENTRY_H equ 1 << 7

GDT_ACCESS_OFFSET equ 40
GDT_FLAGS_OFFSET equ 52

GDT_ENTRY_ACCESS_A      equ 1 << (GDT_ACCESS_OFFSET + 0)
GDT_ENTRY_ACCESS_RW     equ 1 << (GDT_ACCESS_OFFSET + 1)
GDT_ENTRY_ACCESS_DC     equ 1 << (GDT_ACCESS_OFFSET + 2)
GDT_ENTRY_ACCESS_E      equ 1 << (GDT_ACCESS_OFFSET + 3)
GDT_ENTRY_ACCESS_S      equ 1 << (GDT_ACCESS_OFFSET + 4)
GDT_ENTRY_ACCESS_DPL0   equ 0 << (GDT_ACCESS_OFFSET + 5)
GDT_ENTRY_ACCESS_DPL3   equ 3 << (GDT_ACCESS_OFFSET + 5)
GDT_ENTRY_ACCESS_P      equ 1 << (GDT_ACCESS_OFFSET + 7)
GDT_ENTRY_FLAGS_L       equ 1 << (GDT_FLAGS_OFFSET  + 1)


section .bss
stack_bottom: resb 16*1024
stack_top:

align 4096
page_table_l4:
    resb 4096
page_table_l3:
    resb 4096
page_table_l2:
    resb 4096



section .rodata
gdt:
    dq 0
.code: equ $ - gdt
    dq (GDT_ENTRY_ACCESS_P | GDT_ENTRY_ACCESS_DPL0 | GDT_ENTRY_ACCESS_E | GDT_ENTRY_ACCESS_S | GDT_ENTRY_FLAGS_L)
.gdtr_contents:
    dw $ - gdt - 1
    dq gdt



section .data
msg_start: db 'bootstrap started  ', 0
msg_paging: db 'paging set  ', 0
msg_gdt: db 'gdt set  ', 0
msg_end: db 'bootstrap end  ', 0
msg_64ok: db '64BIT  ', 0
msg_64err: db '32BIT  ', 0
term_pos: dd 0xb8000



section .text
bits 32

write_string:
    mov ebx, [term_pos]

    xor ecx, ecx
    xor eax, eax
    .loop:
        mov byte al, [edi+ecx]
        test al, al
        jz .end

        mov byte [ebx+ecx*2], al
        mov byte [ebx+ecx*2+1], 0x02
        inc ecx
        jmp .loop


    .end:
    sal ecx, 1
    add [term_pos], ecx
    ret


test_64:
    mov ecx, MSR_IA32_EFER
    rdmsr
    bt eax, 10
    jc .ok_64
    mov edi, msg_64err
    call write_string
    jmp .end
.ok_64:
    mov edi, msg_64ok
    call write_string
.end:
    ret

setup_paging_tables:
    ; Page directory base (CR3.PDBR bit 12-31)
    mov eax, page_table_l4
    mov cr3, eax

    ; do identity mapping for 1GiB

    mov eax, page_table_l3
    or eax, PT_ENTRY_P | PT_ENTRY_W
    mov [page_table_l4], eax

    mov eax, page_table_l2
    or eax, PT_ENTRY_P | PT_ENTRY_W
    mov [page_table_l3], eax

    ; 2MiB pages
    xor ecx, ecx
.l2_entry:
    mov eax, 2*1024*1024
    mul ecx
    or eax, PT_ENTRY_P | PT_ENTRY_W | PT_ENTRY_H
    mov [page_table_l2 + ecx*PT_ENTRY_SIZE], eax

    inc ecx
    cmp ecx, 512
    jne .l2_entry

    ret


setup_paging:
    ; PAE on (CR4.PAE bit 5)
    mov eax, cr4
    bts eax, 5
    mov cr4, eax

    ; Long mode enable (IA32_EFER.LME bit 8)
    mov ecx, MSR_IA32_EFER
    rdmsr
    bts eax, 8
    wrmsr

    ; Paging on (CR0.PG bit 31)
    mov eax, cr0
    bts eax, 31
    mov cr0, eax
    ret

setup_gdt:
    lgdt [gdt.gdtr_contents]
    ret


global _bootstrap
_bootstrap:
    cli
    mov esp, stack_top

    call test_64

    mov edi, msg_start
    call write_string

    call setup_paging_tables
    call setup_paging

    mov edi, msg_paging
    call write_string

    call setup_gdt

    mov edi, msg_gdt
    call write_string

    call test_64

    extern _start64
    jmp gdt.code:_start64

    hlt

