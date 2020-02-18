# Detecting Memory x86
https://wiki.osdev.org/Detecting_Memory_%28x86%29

## Background
One of the most vital pieces of information that an OS needs in order to initialize itself is **a map of the available RAM** on a machine. Fundamentally, the best way an OS can get that information is **by using the BIOS**.

There may be rare machines where you have no other choice but to try to detect memory yourself -- however, doing so is **unwise** in any other situation.

It is perfectly reasonable to say to yourself, "How does the BIOS detect RAM? I'll just do it that way." Unfortunately, the answer is disappointing:
**Most BIOSes can't use any RAM until they detect the type of RAM installed**, then detect the size of each memory module, then configure the chipset to use the detected RAM.

All of this depends on chipset specific methods, and is usually documented in the datasheets for the memory controller (northbridge). **The RAM is unusable for running programs during this process**. The BIOS initially is running from ROM, so it can play the necessary games with the RAM chips. But it is completely impossible to do this from inside any other program.

It is also reasonable to wish to reclaim the memory from 0xA0000 to 0xFFFFF and make your RAM contiguous. Again the answer is disappointing:
