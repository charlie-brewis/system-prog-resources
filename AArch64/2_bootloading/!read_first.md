In the basics section we learnt about writing 64-bit Arm assembly code for Linux systems  

This has taught us the following concepts:  
- Register Usage (x0 - x30)  
- Function calls / stack frames  
- Memory sections (`.data`, `.bss`, `.text`, `.rodata`)
- Syscalls and small libc-less programs
- Pointer arithmetic and memory access
- Looping, branching, and conditional logic
- Working with the stack more generally (using `sp`)

This is a **solid core for bare-metal work**  
However, there is a problem...  

---
# The problem
If we want to develop a bootloader, it isn't just about Linux Arm assembly.  
It's about taking full repsonsibility for **hardware initialisation**, and running *without* an OS or standard environment.  
Here's what we're going to become familar with in this section before we can write a real bootloader:  

## 1. Bare-metal Environments (no syscalls)
- Won't have access to syscalls like `svc`, `write`, `exit`, etc
- Will need to interact **directly** with memory-mapped I/O, like *UART* for output
## 2. Linker Scripts
- Critical for controlling where code and data go in memory
- Writing our own `.ld` file to put code at a specific physical address (e.g., `0x80000` on Raspberry Pi)
## 3. Startup Code (reset vector)
- Usually we must define the entry point at a specific address (e.g., `_start` at `0x0` or `0x80000`)
- Set up the stack, zero out `.bss`, copy `.data`, etc
## 4. Interrupts and Exception Levels (ELs)
- We will be planning to support exceptions and/or higher-privilege modes
- Know how to get into EL1 (or even EL2/3 depending on the platform)
## 5. Peripheral Access
- Using MMIO (memory-mapped I/O) to talk to UART, GPIO, timers, etc
- Reading documentation for our specific platform (e.g., Raspberry Pi, QEMU Virt board)
## 6. Binary Layout and Image Formats
- We may need to convert our ELF file into a flat binary (`.bin`) using `objcopy`
- We'll load this via an emulator or real boot ROM
---
  
Ok I know thats a lot so here's the learning plan:
```
[x] Linux user-mode AArch64 assembly
[x] Argument passing, memory, logic, etc - general programming shit
[-] Bare-metal MMIO (UART output)
[-] Linker Scripts and image formats
[-] Stack setup, .bss init, boot image
[-] Building a minimal bootloader
[-] Extending to kernel + multitasking
```
Think of it this way:  
" You’ve been writing code in a house with plumbing and electricity. Bootloader development is wiring the house yourself - and maybe even building the generator. "