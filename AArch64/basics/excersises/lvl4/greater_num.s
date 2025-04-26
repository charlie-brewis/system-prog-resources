/*
Compare two numbers and print the bigger one

Hardcode two values
Use cmp and conditional branch (b.gt, b.lt, etc.)

Jump to the correct print call
*/

.section .bss
print_buffer: .skip 1

.section .text 
.global _start

_start:
    // x3 = num1; x4 = num2;
    mov x3, #5
    mov x4, #3

    // Make x5 point to the buffer
    adr x5, print_buffer

    // Set-up print before branch
    mov x0, #1   // filedesc = stdout
    mov x1, x5   // msg_adr  = buffer
    mov x2, #1   // msg_len  = 1
    mov x8, #64  // syscall  = write

    // Conditional branch
    cmp x3, x4
    b.lt load_num2

    load_num1:
        add x3, x3, #48  // Convert num1 to ASCII
        strb w3, [x5]    // Save num1 (x3) to buffer
        b print

    load_num2:
        add x4, x4, #48  // Convert num2 to ASCII
        strb w4, [x5]    // Save num2 (x4) to buffer
        b print
    
    print:
        svc #0
    
    // Exit
    mov x0, #0
    mov x8, #93
    svc #0
