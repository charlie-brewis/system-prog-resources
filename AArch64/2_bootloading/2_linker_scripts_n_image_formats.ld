/*
Note that this file is not intended to be run.

Linker scripts and Image Formats are foundational concepts in bare-metal programming
These concepts are *not optional* as they give you full control over *how* your binary is *structured*
and *where* it loads in *memory*.

When building for Linux, the OS loads your ELF program into virtual memory, handles `.bss`, `.data`, the stack, etc
But in **bare-metal**, there's NO OS - so we must take **full** control over:
    - Where our code is placed
    - What memory layout is used
    - Where execution starts
    - How different segments (e.g., `.data`, `.text`, etc) are positioned

A **linker script** file (`.ld`) tells the linker exactly how to lay out the binary in memory. It's crucial for:
    - Correct UART MMIO access (e.g., at `0x09000000`)
    - Placing your code at `0x80000` (Raspberry Pi / QEMU convention)
    - Bootstrapping your execution from `_start`
*/

/* Key Concepts: */

/* 1. Memory Layout
/*     - We decide where in physical memory to place code and data
/*     - I.e., tell the linker what memory regions are available
/* Example: */
MEMORY 
{
    RAM (rwx) : ORIGIN = 0x80000, LENGTH = 64M
}
/* The block above defines a memory region called RAM which is readable, writable, and executable (hence `rwx`) 
   The memory region starts at `0x80000` (common for QEMU/Raspberry Pi)
   The memory region is 64 MB long - we have chosen this arbitrarily here.
*/

/* 2. Section Mapping
/*     - We define how sections in our code map to memory
/* Example: */
SECTIONS 
{
    . = 0x80000;             /* Start address */
    .text : { *(.text*) }    /* All sections matching '.text*' from .o files */
    .rodata : { *(.rodata*) }
    .data : { *(.data*) }
    .bss : { *(.bss*) }
}
/* Note in linkerScript '*()' is a wildcard for section names - e.g., `*(.rodata*)` means any section starting with `.rodata` in all .o files */

/* 3. Symbol Definition
/*     - We can define symbols the code can reference
/* Example: */
_estack = 0x90000;    /* Top of stack manually set */


/* MINIMAL LINKER SCRIPT EXAMPLE */
ENTRY(_start)               /* Tell the linker our entry point is the _start label  */

SECTIONS 
{
    . = 0x80000;             /* Load address for QEMU - '.' is called the location counter */

    .text : {
        KEEP(*(.text.boot))  /* Prevent the linker from removing unused sections (e.g., _start in .text.boot) */
        *(.text*)            /* All Code*/
    }

    .rodata : {
        *(.rodata*)
    }

    .data : {
        *(.data*)
    }

    .bss : {
        __bss_start = .;
        *(.bss*)
        __bss_end = .;      /* Initally the .bss is empty as we haven't declared any uninitialised variables */
    }
}

/* 
Bear in mind the above is a minimal, single memory region example using absoute addressing (the 
location counter) instead of using named memory regions like RAM. 
When we write our real linker script we will use named memory regions, allowing us to have multiple 
memory regions and work from a more abstracted view.
An example would work like this:
*/
MEMORY 
{
    RAM (rwx) : ORIGIN = 0x80000, LENGTH = 64M
}

SECTIONS {
    .text : {
        *(.text*)
    } > RAM
}




/*
Ok so thats how we write linker scripts - don't worry, we'll get much more practice at that
Now we need to talk about Image Formats

When we compile and link our code, by default a file of "Executable and Linkable Format" (ELF)
This format has rich metadata, symbol info, debug info, relocations, etc
BUT: Boot ROMs, QEMU, or real hardware often **don't understand ELF**

So we need to convert our compiled+linked ELFs to raw, flat binary (.bin)
BIN format is just raw bytes laid out as memory would see them
That means no headers, no metadata - just pure machine code
This is required for: `QEMU -kernel`, real bootloaders, firmware blobs, etc
*/
/*
So how do we convert ELF to BIN
We can use a command! `objcopy`, where we set the **object format** (-O) to *binary*:

    `aarch64-linux-gnu-objcopy -O binary kernel.elf kernel.bin`

And now kernel.bin can be loaded directly to memory
*/
