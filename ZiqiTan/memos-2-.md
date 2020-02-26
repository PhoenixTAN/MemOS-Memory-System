# Memos-2
Lecture on Feb 25, 2020.

## Protected mode 
- 1MB  accessible
- 32-bit code/data
- real mode addressing is no longer valid.
- BIOS is no longer accessible.
- global desscriped table: an array of segment descriptors.
  - LGDT:
    - 0 NULL
    - 1 Kernel: Code Segment
    - 2 Kernel: Data Segment

## grub/multiboot
- stage 1 (MBR)
- stage 1.5

ELF Binary file:
- File Headers
- program headers

File offset will jump here.
- Section 
  - .text: instructions
  - .data: INSTRS
  - .bss: 
  - .rodata: 


## x86 calling conventions
IA-32 cdecl GCC

## VGA standard
text mode graphics
memory map to address 0xb8000
- address: 0xb8000
    - 28 rows * 80 columns

### Each character to print
- attribute + ascii character
  - 0123 foreground color
  - 456 background color


