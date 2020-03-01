# ----------------------------------------------------------------------------------------
# Ziqi Tan, Jiaqian Sun
# Reference: 
#       https://www.gnu.org/software/grub/manual/multiboot/multiboot.html#multiboot_002eh
# 
# ------------------------------------------------------------------------------------------
.text
.global _start	
.global stack

_start:
    jmp boot_entry
    
    # Multiboot header -- Must be in 1st page for GRUB
    .align 4

    .long 0x1BADB002    # Multiboot magic number
    
    /* MULTIBOOT_HEADER_MAGIC */
    .long 0x00000003    # Align modules to 4KB, req. mem size
    
    /* checksum */
    .long 0xE4524FFB    # -(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS)

boot_entry:
    /* Initialize the stack pointer. */
    movl $(stack+0x4000), %ESP

    /* Push the pointer to the Multiboot information structure. */
    pushl %EBX

    /* Push the magic value. */
    pushl   %EAX

    /* Now enter the C main function... */
    call cmain
     
    hlt     # halts CPU until the next external interrupt is fired

/* Our stack area. */
    .comm stack, 0x4000