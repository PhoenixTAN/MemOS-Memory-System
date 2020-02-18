# Protected mode

## Definition
Protected mode, also called **protected virtual address mode**, is an operational mode of x86-compatible central processing units (CPUs).

It allows system software to use features such as **virtual memory, paging and safe multi-tasking** designed to increase an operating system's control over application software.

When a processor that supports x86 protected mode is powered on, it begins executing instructions in real mode, in order to maintain backward compatibility with earlier x86 processors. **Protected mode may only be entered after the system software sets up one descriptor table and enables the Protection Enable (PE) bit in the control register 0 (CR0)**.

## Features

### Priviledge Levels

![alt text](./image/Priv_rings.svg.png)

In protected mode, there are four privilege levels or rings, numbered from 0 to 3, with ring 0 being the most privileged and 3 being the least.

The use of rings allows for system software to restrict tasks from accessing data, call gates or executing privileged instructions. In most environments, the operating system and some device drivers run in **ring 0** and applications run in **ring 3**.

