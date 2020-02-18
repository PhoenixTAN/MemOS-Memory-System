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


