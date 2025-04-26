/*
Count down from 10 to 0 using a loop

Use a label and conditional branch (cbz, subs, b.ne)

Print each number
*/

.section .bss
buffer: .skip 2  // 2 bytes stored: digit + newline

.section .text 
.global _start

// x3: buffer_pointer, x4: current_num, x5: current_num_ASCII
_start:
    // Set-up buffer
    adr x3, buffer 
    mov x0, #10        // Define x0 as ASCII newline char
    strb w0, [x3, #1]  // Store newline at buffer[1]

    // Define x4
    mov x4, #10
    loop:
        // Store ASCII num in buffer
        add x5, x4, #48  // Convert current_num to ASCII and store in x5
        strb w5, [x3]    // Store current_num_ASCII in buffer [0]

        // Print buffer
        mov x0, #1   // file_desc = stdout
        mov x1, x3   // msg_adr   = buffer
        mov x2, #2   // msg_len   = 2 (current_num + newline)
        mov x8, #64  // syscall   = write
        svc #0

        // Decrement current_num and conditional branch
        sub x4, x4, #1
        cmp x4, #0
        b.gt loop
    
    // Exit
    mov x0, #0
    mov x8, #93
    svc #0
