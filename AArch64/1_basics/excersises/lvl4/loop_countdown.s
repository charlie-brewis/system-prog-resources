/*
Count down from 10 to 0 using a loop

Use a label and conditional branch (cbz, subs, b.ne)

Print each number
*/

.section .bss
buffer: .skip 3  // 3 bytes stored: tens + units + newline

.section .text 
.global _start

// x3: buffer_pointer, x4: current_num, x5: tens, x6: units
_start:
    // Set-up buffer
    adr x3, buffer 
    mov x0, #10        // Define x0 as ASCII newline char
    strb w0, [x3, #2]  // Store newline at buffer[2]

    // Define x4
    mov x4, #10
    loop:
        // Convert current_num to tens and units
        mov x0, #10       // Use x0 as 10
        udiv x5, x4, x0   // tens = current_num DIV 10
        
        mul x6, x5, x0
        sub x6, x4, x6    // units = current_num % 10 = current_num - tens

        // Convert tens and units to ASCII
        add x5, x5, #48
        add x6, x6, #48
        
        // Store ASCII tens and units in buffer
        strb w5, [x3]  // Store tens(ASCII) in buffer[0]
        strb w6, [x3, #1]  // Store units(ASCII) in buffer[1]

        // Print buffer
        mov x0, #1   // file_desc = stdout
        mov x1, x3   // msg_adr   = buffer
        mov x2, #3   // msg_len   = 2 (current_num + newline)
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
