/*
Build a tiny calculator

Add two numbers using a function
Multiply two numbers using repeated addition (loop)

Print both results

Return their sum as the exit code
*/

.section .bss 
buffer: .skip 4  // hundreds, tens, units, newline

.section .text 
.global _start

// Prints the contents of a buffer of n size to stdout
// Args: x0 = buffer_pointer; x1 = buffer_size
print_buffer:
    // Function Prologue
    stp x29, x30, [sp, #-16]!  // Store fp and lr to frame
    mov x29, sp                // Setup new fp

    mov x2, x1   // msg_len   = buffer_size
    mov x1, x0   // msg_adr   = buffer_pointer
    mov x0, #1   // file_desc = stdout
    mov x8, #64  // syscall   = write
    svc #0

    // Function Epilogue
    ldp x29, x30, [sp], #16    // Reset fp and lr
    ret

// Converts an unsigned 3-digit integer to ASCII and store it in a buffer[0:2]
// buffer[x2, x3, x4] (hundreds, tens, units)
// Args: x0 = num; x1 = buffer_pointer;
to_ASCII:
    // Function Prologue
    stp x29, x30, [sp, #-16]!  // Store fp and lr to frame
    mov x29, sp                // Setup new fp

    mov x5, #100
    mov x6, #10

    udiv x2, x0, x5  // hundreds = num DIV 100
    
    mul x7, x2, x5   // x7 is sum of hundreds
    sub x3, x0, x7   // tens (+units) = num - sum_hundreds

    udiv x3, x3, x6  // tens = tens (+units) DIV 10

    mul x8, x3, x6   // x8 is sum of tens
    add x7, x7, x8   // x7 = sum_hundreds + sum_tens
    sub x4, x0, x7   // units = num - x7

    // Convert hundreds, tens, units to ASCII
    add x2, x2, #48
    add x3, x3, #48
    add x4, x4, #48

    // Store ASCII hundreds, tens, units in the buffer
    strb w2, [x1]
    strb w3, [x1, #1]
    strb w4, [x1, #2]

    // Function Epilogue
    ldp x29, x30, [sp], #16    // Reset fp and lr
    ret

// Multiplies two inputted unsigned integers together
// Args: x0 = num1; x1 = num2;
mult:
    // Function Prologue
    stp x29, x30, [sp, #-16]!  // Store fp and lr to frame
    mov x29, sp                // Setup new fp

    // Check either number is 0
    cmp x0, #0
    b.eq mult_exit
    cmp x1, #0      //! x0 will need to be set to 0 before exit
    b.eq mult_exit

    mov x2, x0      // Save original value of num1
    sub x1, x1, #1  // Decrement num2 by 1 as we imply first iteration //! Also means we can use x1 = 1 as a base case
    
    mult_loop:
        // Exit condition
        cmp x1, #0
        b.eq mult_exit

        // Perform iterative multiplication
        add x0, x0, x2 

        sub x1, x1, #1
        b mult_loop
        
    mult_exit:
        // Function Epilogue
        ldp x29, x30, [sp], #16    // Reset fp and lr
        ret




// num1: x19; num2: x20; buffer_pointer: x21
_start:
    // Store num1 and num2 as static values
    mov x19, #22
    mov x20, #7 
    
    // Set up the buffer
    adr x21, buffer
    mov x0, #10 
    strb w0, [x21, #3]  // Store newline at buffer[3]

    // Convert add result to ASCII and store in buffer
    add x0, x19, x20  // num: num1 + num 2
    mov x1, x21       // buffer_pointer: x21
    bl to_ASCII

    // Print the buffer
    mov x0, x21  // buffer_pointer: x21
    mov x1, #4   // buffer_length:  4
    bl print_buffer

    // Calculate Multiply result
    mov x0, x19  // num1: num1
    mov x1, x20  // num2: num2
    bl mult      // x0 = num1 * num2

    // Convert mult result to ASCII and store in buffer
    mov x1, x21  // buffer_pointer: x21
    bl to_ASCII

    // Print the buffer
    mov x0, x21  // buffer_pointer: x21
    mov x1, #4   // buffer_length: 4
    bl print_buffer

    // Exit
    mov x0, #0
    mov x8, #93
    svc #0


