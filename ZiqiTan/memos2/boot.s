.global _start	
.global stack
    .bss
    .align 0x1000
    .comm stack, 0x1000
    .data
    .text

_start:
    jmp real_start
    
    # Multiboot header -- Must be in 1st page for GRUB
    .align 4
    .long 0x1BADB002    # Multiboot magic number
    .long 0x00000003    # Align modules to 4KB, req. mem size
    .long 0xE4524FFB    # Checksum

real_start:
    movl $stack+0x1000, %ESP
    pushl %EBX

    call init
    
    hlt     # halts CPU until the next external interrupt is fired

