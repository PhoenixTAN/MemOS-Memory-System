# Real mode
https://en.wikipedia.org/wiki/Real_mode

## Definition
**Real mode**, also called **real address mode**, is an **operating mode** of all **x86**-compatible CPUs. 

The mode gets its name from the fact that addresses in real mode always correspond to **real locations in memory**.

Real mode is characterized by a **20-bit segmented memory** address space (giving exactly 1 MiB of addressable memory) and **unlimited direct software access** to all addressable memory, I/O addresses and peripheral hardware.

Real mode provides **no support** for memory protection, multitasking, or code privilege levels.

## History
Before the release of the 80286, **which introduced protected mode**, real mode was the only available mode for x86 CPUs; and **for backward compatibility, all x86 CPUs start in real mode when reset**, though it is possible to emulate real mode on other systems when starting on other modes.

## Addressing capacity
The 8086, 8088, and 80186 have **a 20-bit address bus**, but the unusual segmented addressing scheme Intel chose for these processors actually produces effective addresses which can have 21 significant bits.

This scheme shifts a 16-bit segment number left four bits (making a 20-bit number with four least-significant zeros) before adding to it a 16-bit address offset; the maximum sum occurs when both the segment and offset are 0xFFFF, yielding 0xFFFF0 + 0xFFFF = 0x10FFEF. On the 8086, 8088, and 80186, the result of an effective address that **overflows 20 bits is that the address "wraps around"** to the zero end of the address range, i.e. it is taken **modulo** 2^20 (2^20 = 1048576 = 0x10000).

```
Segment memory: <Segment> : <offset>

Address: ( <Segment> << 4 + <offset> ) % (2^20)
```

## Switching to real mode
Intel introduced protected mode into the x86 family with the intention that **operating systems** which used it would run entirely in the new mode and that **all programs** running under a protected mode operating system would run in protected mode as well.

Because of the substantial differences between real mode and even the rather limited 286 protected mode, programs written for real mode cannot run in protected mode without being rewritten.

Therefore, with a wide base of existing real mode applications which users depended on, abandoning real mode posed problems for the industry, and **programmers sought a way to switch between the modes at will**.

# Wiki.osdev.org/Real_Mode

https://wiki.osdev.org/Real_Mode

## Cons
* Less than 1 MB of RAM is available for use.
* There is no hardware-based memory protection (GDT), nor virtual memory.
* There is no built in security mechanisms to protect against buggy or malicious applications.
* The default CPU operand length is only 16 bits.
* The memory addressing modes provided are more restrictive than other CPU modes.
* Accessing more than 64k requires the use of segment register that are difficult to work with.

## Pros
* The BIOS installs device drivers to control devices and handle interrupt.
* BIOS functions provide operating systems with a advanced collection of low level API functions.
* Memory access is faster due to the lack of descriptor tables to check and smaller registers.

## Common Misconception
Programmers often think that since Real Mode defaults to 16 bits, that the 32 bit registers are not accessible. **This is not true.**

All of the 32-bit registers (EAX, ...) are still usable, by simply adding the 
```
"Operand Size Override Prefix" (0x66)
```
 to the beginning of any instruction. Your assembler is likely to do this for you, if you simply try to use a 32-bit register.

## Memory Addressing
In Real Mode, there is a little over 1 MB of "addressable" memory (including the High Memory Area). See Detecting Memory (x86) and Memory Map (x86) to determine how much is actually usable. The usable amount will be much less than 1 MB. Memory access is done using Segmentation via a **segment:offset system**.

There are six 16-bit segment registers: CS, DS, ES, FS, GS, and SS. 

### The Stack
**SS (Stack Segment) and SP (Stack Pointer)** are 16-bit segment:offset registers that specify a 20-bit physical address (described above), which is the current **"top" of the stack**. The stack stores 16-bit words, grows downwards, and must be aligned on a word (16-bit) boundary. It is used every time a program does a **PUSH, POP, CALL, INT, or RET** opcode and also when the BIOS handles any **hardware interrupt**.

### High Memory Area
If you set DS (Data Segment) (or any segment register) to a value of 0xFFFF, it points to an address that is 16 bytes below 1 MB. If you then use that segment register as a base, with an offset of 0x10 to 0xFFFF, you can access physical memory addresses from **0x100000 to 0x10FFEF**. This (almost 64 kB) area above 1 MB is called the "High Memory Area" in Real Mode. Note that you have to have the A20 address line activated for this to work.

### Addressing Mode
Real Mode uses 16-bit addressing mode by default. Assembly programmers are typically familiar with the more common 32-bit addressing modes, and may want to make adjustments -- because the registers that are available in 16-bit addressing mode for use as "pointers" are much more limited. The typical programs that run in Real Mode are often limited in the number of bytes available, and it takes one extra byte in each opcode to use 32-bit addressing instead.

## Swicthing from Protected Mode to Real Mode

As noted above, it is possible for a Protected mode operating system to use Virtual 8086 Mode mode to access BIOS functions.


