# The MemOS Simple Memory System

By Rich West, Boston University.

DEADLINE March 1st, 11:59PM (HARD DEADLINE, NO EXTENSIONS)

**This project can be performed in groups of up to TWO people.**
 If working in a group of two, only one person is required to submit a solution, but it must be submitted by the deadline (posted on the class syllabus page) for you to receive a grade. In a **README file**, please include the name of the other person.

 ## Background
 In this assignment, you are going to write a very simple OS. Okay, it's not a particularly useful OS but it will provide a way to understand **how systems are booted, and how system information is displayed on the screen**. The idea is to bootstrap a program that **probes the system BIOS and reports the amount of physical memory available in your machine**.

 This is then displayed as a message, in the form:
```
    "MemOS: Welcome *** System Memory is: XXXMB"
```
The value XXX is replaced by the actual memory your system has available.

You should also give a breakdown of the ranges of physical memory and their type, where the type is **USABLE RAM, RESERVED, ACPI RECLAIMABLE MEMORY, ACPI NVS MEMORY, or BAD MEMORY** according to the flags reported by the BIOS. 

You can find more on the osdev page (https://wiki.osdev.org/Detecting_Memory_%28x86%29) for the five types of memory reported using BIOS INT 0x15, EAX=0xE820. For each memory range you should output a line to the screen of the form:
```
    "Address range [xxxx : yyyy] status: zzzz" 
    where xxxx is the start address, 
    yyyy is the end address and zzzz is the type of the memory in that range.
```

## Step 1: Building a Virtual Disk
The first step is to build a virtual disk for MemOS. To do this you should follow the general guidelines (http://www.cs.bu.edu/fac/richwest/cs552_spring_2020/assignments/memos/BOCHS-disk-image-HOWTO) I provided for creating a simple disk image for use in BOCHS. If you do not have BOCHS, you can replace bximage with either dd or qemu-img. The latter requires you to have QEMU available.

## Requirements
1. Displayed as a message, in the form.
```
    "MemOS: Welcome *** System Memory is: XXXMB"
```
2. Usable RAM, reserved, ACPI reclaimable memory, ACPI NVS memory, or bad memory.
```
    "Address range [xxxx : yyyy] status: zzzz" 
    where xxxx is the start address, 
    yyyy is the end address and zzzz is the type of the memory in that range.
```
3. 
