/*
Write a program that prints numbers 0 to 9 (on separate lines)

Use a loop
Convert each number to ASCII ('0' + x)

Use write syscall each time

Bonus: Print them on the same line with spaces
*/

.section .bss
buffer: .skip 2


.section .text
.global _start


_start:
    adr x7, buffer     // Setup pointer to buffer
    // mov x0, #10        // Define x0 as ASCII newline char
    mov x0, #32        // Define x0 as ASCII space
    strb w0, [x7, #1]  // Store the newline char in buffer[1]

    mov x3, #0   // Current number
    mov x4, #10  // End number
    mov x5, #1   // Step size
    loop:
        add x6, x3, #48  // Convert x3 to ASCII and store in x6

        strb w6, [x7]  // Store w6 in buffer[0] 

        // Write value of buffer
        mov x0, #1   // file_desc = stdout
        mov x1, x7   // msg_adr   = buffer
        mov x2, #2   // msg_len   = 2 (digit + newline || space)
        mov x8, #64  // syscall   = write
        svc #0

        // Loop
        add x3, x3, #1
        cmp x3, x4
        b.ne loop

    // Exit
    mov x0, #0
    mov x8, #93
    svc #0
