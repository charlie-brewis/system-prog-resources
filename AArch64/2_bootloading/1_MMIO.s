/*
Again please note this file is not intended to be run

When writing a bootloader, we do not have any underlying operating system to do things for us
Therefore, we need to access the hardware devices directly in order to do anything - no syscalls
We do this using Memory-Mapped I/O:

Memory-Mapped I/O (MMIO) is how the CPU talks to hardware *as if it were memory*
    - Devices (like UART, timers, GPIO) are assigned **physical memory addresses**
    - You write or read those addresses using regular load/store instructions (`ldr`, `str`, etc)
    For example:
*/
str w0, [x1]    // x1 might be 0x09000000 (UART data register)
                // So here we are writing a byte to the UART

/*
What is UART?

Universal Asynchronous Receiver/Transmitter (UART) is the most common way to do simple serial output
It's often used to:
    - Output debugging info
    - Print strings
    - Receive input from a terminal
CPUs like the Raspberry Pi, QEMU-Virt, or real SoCs expose UARTs at fixed MMIO addresses
*/

/*
Our Target CPU: QEMU-Virt 

The base address for UART on the QEMU virt board is `0x09000000`  (PL011 UART)
Note that PLO11 UART is a standard ARM UART - see https://developer.arm.com/documentation/ddi0183/latest for more

Key UART Registers:
    1. Data Register (DR)
        - Reads/ writes a char
        - Offset: 0x00
    2. Flag Register (FR)
        - Holds multiple flags with various uses
        - E.g., bit 5 is the Transmit FIFO Full (TXFF) flag which if set, means you need to wait before writing
        - Offset: 0x18
*/

/*
How UART Output Works

1. Poll UART Flag Register
    - Wait until transmit FIFO is *not full*
2. Write byte to UART Data Register

Here's an example of a basic UART Print Routine (Conceptual):
*/
UART_BASE = 0x09000000
UART_DR   = UART_BASE + 0X00
UART_FR   = UART_BASE + 0x18
TXFF_MASK = 1 << 5

// x0 = char to print
uart_send:
.loop:
    ldr w1, =UART_FR    //! Note in actual bootloader code, this would be replaced with proper immediate loading instructions - see bottom of aarch64_basics.s
    ldr w2, [w1]
    and w2, w2, #TXFF_MASK
    cbnz w2, .loop     // Wait if FIFO is full - i.e., w2 != 0x0

    ldr w1, =UART_DR   //! Same note about loading immediates as before
    str w0, [w1]       // Send byte
    ret

// Note: This code assumes MMIO and execution from physical memory. It won't work under an OS. 
//       You'll need a linker script and start-up code to make this run bare-metal - we'll get there

// This is how we handle hardware devices bare-metal. 
// But this code is not placed properly in memory.
// Without a *linker script*, our UART address might be interpreted as a virtual or relocated address