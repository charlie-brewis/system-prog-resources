/*
Reverse a string in memory

Store a string in .data

Use pointers (adr, ldrb, strb) and swap bytes
*/

.section .data
string: .asciz "hello"

.section .text
.global _start

// Finds the length of a null terminated string
// Args    -> x0: pointer to string base
// Returns -> x0: length of the string
str_len:
    // Function Prologue
    stp x29, x30, [sp, #-16]!  // Store fp and lr to frame
    mov x29, sp                // Setup new fp

    // Function body
    mov x1, #0                  // Initialise length (x1) as 0
    str_len_count_loop:
        ldrb w2, [x0, x1]       // Load byte at string_base + offset (x0 + x1)
        cbz w2, str_len_exit    // If null terminator, break
        add x1, x1, #1          // Increment length
        b str_len_count_loop

    str_len_exit:
        // Function Epilogue
        mov x0, x1              // Return value in x0
        ldp x29, x30, [sp], #16 // Reset fp and lr
        ret


_start:
    // Compute length of string 
    adr x0, string   // x0: string base address
    bl str_len       // x0: string length

    // Set up start and end pointers
    adr x1, string   // x1: string base address
    add x2, x1, x0   // x2: x1 + string length = null terminator address
    sub x2, x2, #1   // x2: null terminator address - 1 = string end address

    // Loop through string using 2-pointer method, swapping bytes
    swap_loop_start:
        // Check break condition
        cmp x1, x2
        b.ge print_str  // if x1 >= x2, break

        // Load bytes from memory to registers
        ldrb w3, [x1]    // w3: byte at x1
        ldrb w4, [x2]    // w4: byte at x2

        // Store bytes from registers to memory - the swap
        strb w4, [x1]    // byte at x1: w4
        strb w3, [x2]    // byte at x2: w3

        // Increment / decrement our pointers and loop
        add x1, x1, #1
        sub x2, x2, #1
        b swap_loop_start

    print_str:
    mov x2, x0        // str_length:   x0
    mov x0, #1        // file_desc:    stdout
    adr x1, string    // str_base_adr: string
    mov x8, #64       // syscall:      write
    svc #0

    // Exit
    mov x0, #0     // return:  0
    mov x8, #93    // syscall: exit
    svc #0
