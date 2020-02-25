# Master Boot Record (MBR)

## Definition
A special type of **boot sector** at the very beginning of partitioned computer mass storage devices.

The MBR holds the information on **how the logical partitions, containing file systems, are organized** on that medium. The MBR also contains executable code to function as a loader for the installed operating system—usually by passing control over to the loader's second stage, or in conjunction with each partition's volume boot record (VBR). This MBR code is usually referred to as a **boot loader**.

