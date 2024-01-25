; that code is loaded by GRUB at 1M and in protected mode
; sets up paging and runs with identity paging firstly
; than maps kernel to KERNEL_VMA
; switch to compatibility long mode
; then with configuring gdt sector jump into 64bit long mode
; final target is to call kernel_init procedure
; setting up paging and GDT for OS is on kernel_init

KERNEL_VMA equ 0xFFFFFF8000000000
%define PHY(vmem) (vmem - KERNEL_VMA)

MSR_IA32_EFER equ 0xC0000080

PT_ENTRY_COUNT equ 512
PT_ENTRY_P equ 1 << 0
PT_ENTRY_W equ 1 << 1
PT_ENTRY_H equ 1 << 7
PT_ENTRY_PW equ PT_ENTRY_P | PT_ENTRY_W

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
align 0x1000
stack_bottom: resb 16*1024
stack_top:


section .rodata
align 0x1000
page_table_l4:
    ; identity mapping
    dq (PHY(page_table_l3) + PT_ENTRY_PW)
    times PT_ENTRY_COUNT-2 dq 0
    ; mapping into ff80_0000_0000h
    dq (PHY(page_table_l3) + PT_ENTRY_PW)

page_table_l3:
    dq (PHY(page_table_l2) + PT_ENTRY_PW)
    times PT_ENTRY_COUNT-1 dq 0

page_table_l2:
    dq (PT_ENTRY_PW | PT_ENTRY_H)   ; first 2M of physical mem
    times PT_ENTRY_COUNT-1 dq 0

gdt:
    dq 0
.code: equ $ - gdt
    dq (GDT_ENTRY_ACCESS_P | GDT_ENTRY_ACCESS_DPL0 | GDT_ENTRY_ACCESS_E | GDT_ENTRY_ACCESS_S | GDT_ENTRY_FLAGS_L)
.gdtr_contents:
    dw $ - gdt - 1
    dq PHY(gdt)


section .data
term_pos: dd 0xb8000
msg_start: db 'bootstrap started. ', 0
msg_paging: db 'paging set.  ', 0
msg_gdt: db 'gdt set.  ', 0
msg_64ok: db 'long mode!  ', 0
msg_64err: db 'switch failed.  ', 0

section .text
bits 32
write_string:
    mov ebx, [PHY(term_pos)]

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
    add [PHY(term_pos)], ecx
    ret


test_64:
    mov ecx, MSR_IA32_EFER
    rdmsr
    bt eax, 10
    jc .ok_64
    mov edi, PHY(msg_64err)
    call write_string
    hlt
.ok_64:
    mov edi, PHY(msg_64ok)
    call write_string
.end:
    ret


setup_paging:
    ; Page directory base (CR3.PDBR bit 12-31)
    mov eax, PHY(page_table_l4)
    mov cr3, eax

    ; PAE on (CR4.PAE bit 5)
    mov eax, cr4
    bts eax, 5
    mov cr4, eax

    ; PSE on (CR4.PSE bit 5)
    mov eax, cr4
    bts eax, 4
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


global _bootstrap
_bootstrap:
    mov dword esp, PHY(stack_top)
    push eax
    push ebx

    mov dword edi, PHY(msg_start)
    call write_string

    call setup_paging

    mov dword edi, PHY(msg_paging)
    call write_string
    call test_64

    pop esi
    pop edi

setup_gdt:
    lgdt [PHY(gdt.gdtr_contents)]

    ; jump to 64bit code segment -> set cs
    jmp gdt.code:PHY(_bootstrap_64)

bits 64
_bootstrap_64:
    mov rax, 0x0
    mov ds, rax
    mov es, rax
    mov fs, rax
    mov gs, rax
    mov ss, rax

    ; jump into target address space from KERNEL_VMA
    mov rax, _bootstrap_higher
    jmp rax
_bootstrap_higher:
    ; unmap identity 0-2MB
    mov rax, page_table_l4
    mov qword [rax], 0

    ; clear tlb
    mov rax, cr3
    mov cr3, rax

start_kernel:
    mov rsp, stack_top

    extern kernel_init
    call kernel_init

    hlt
