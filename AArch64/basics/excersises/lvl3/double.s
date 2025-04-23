/*
Make a function that doubles a number

x0 holds the input
bl double_func

Result in x0, print it or use as exit code

Use a real stack frame for the function (stp/ldp, mov x29, sp, etc.)
*/

.section .bss
buffer: .skip 2

.section .text
.global _start

// Args -> x0: num_to_double
double:
    // Function prologue
    stp x29, x30, [sp, #-16]!  // 1. Grow stack by 2 bytes, and save the frame pointer and link register to the new stack frame 
    mov x29, sp                // 2. Set up the new frame pointer

    // Function body
    mov x1, #2
    mul x0, x0, x1  // x0 *= 2

    // Function epilogue
    ldp x29, x30, [sp], #16  // 1. Reset frame pointer and link register, and shrink stack by 2 bytes
    ret                      // 2. Return back to link register (x30)


_start:
    mov x0, #4  // Define number to double
    bl double   // Call function

    add x0, x0, #48  // Convert result to ASCII

    // Save char to buffer
    adr x3, buffer
    strb w0, [x3]

    // Print buffer
    mov x0, #1   // file_desc = stdout
    mov x1, x3   // msg_adr   = buffer
    mov x2, #1   // msg_len   = 1
    mov x8, #64  // syscall   = write
    svc #0

    // Exit
    mov x0, #0
    mov x8, #93
    svc #0
