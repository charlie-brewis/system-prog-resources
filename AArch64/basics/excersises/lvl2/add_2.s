/*
Add two numbers and print the result

Hardcode two values (mov x0, #5, mov x1, #7)
Add them, convert the result to ASCII manually, and print using write

Hint: ASCII for '0' is 48. Add your number to that to get the character.
*/

.section .bss
buffer: .skip 2  // reserve 2 bytes in the .bss section

.section .text
.global _start
_start:
    // 5 + 7 = 12
    mov x0, #5
    mov x1, #7
    add x2, x1, x0

    // Divide x2(=12) into tens and units
    mov x3, #10
    udiv x4, x2, x3      // x4 = x2 DIV x3 = 12 DIV 10 = 1
    msub x5, x4, x3, x2  // x5 = x2 - (x4 * x3) = 12 - (1 * 10) = 2

    // Convert digits to ASCII
    add x4, x4, #48  // x4 = '1'
    add x5, x5, #48  // x5 = '2'

    // Store into buffer
    adr x6, buffer     // x6 points to the buffer
    strb w4, [x6]      // Store '1' at buffer position 0
    strb w5, [x6, #1]  // Store '2' at buffer position 1
    /// Note `strb` means 'store register byte' and stores the lowest byte of a register into memory
    /// `strb` expects 8-bit portions of registers and so we use the wN registers as the top section 
    /// is ignored anyway.
    /// Actually, Arm assembly is strictly typed and so all parameters are of an expected size
    /*
        Store Type | Instruction | Register Used | Stores How Many Bytes?
        Byte       | strb        | wN            | 1 byte
        Halfword   | strh        | wN            | 2 bytes
        Word       | str         | wN            | 4 bytes
        Doubleword | str         | xN            | 8 bytes
    */
    /// E.g., x4 = 0x00000000 000000 01
    ///                  w4 =
    ///                       strb = 

    // Syscall: write(stdout, buffer, 2)
    mov x0, #1  // file_desc = stdout
    mov x1, x6  // msg_adr = buffer
    mov x2, #2  // msg_len = 2 (1, 2)
    mov x8, #64 // syscall: write
    svc #0

    // Exit
    mov x0, #0
    mov x8, #93
    svc #0
