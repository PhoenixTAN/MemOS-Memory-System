# Master Boot Record (MBR)

## Definition
A special type of **boot sector** at the very beginning of partitioned computer mass storage devices.

The MBR holds the information on **how the logical partitions, containing file systems, are organized** on that medium. The MBR also contains executable code to function as a loader for the installed operating system—usually by passing control over to the loader's second stage, or in conjunction with each partition's volume boot record (VBR). This MBR code is usually referred to as a **boot loader**.

## OSdev.org
https://wiki.osdev.org/Boot_Sequence

The (legacy) BIOS checks bootable devices for a boot signature, a so called **magic number**. The boot signature is in a boot sector (sector number 0) and it contains the byte sequence 0x55, 0xAA at byte offsets 510 and 511 respectively.

When the BIOS finds such a boot sector, it is loaded into memory at **0x0000:0x7c00 (segment 0, address 0x7c00)**.

However, some BIOS' load to **0x7c0:0x0000** (segment 0x07c0, offset 0), which resolves to the **same physical address**, but can be surprising. A good practice is to enforce CS:IP at the very start of your boot sector.
