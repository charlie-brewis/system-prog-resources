/*
Use command-line arguments (argc/argv)

Use _start as entry
First argument is at [sp], then pointers to arguments follow

Print the first argument
*/

/*
    When the program starts, Linux sets up the stack like this:
        [sp]                 -->  argc (64-bit int)
        [sp+8]               -->  argv[0] (pointer to first string)
        [sp+16]              -->  argv[1]
        ...
        [sp + 8*(argc + 1)]  --> NULL (end of argv)

    Also note that argv[0] is typically the program name.
    So for this program, where we want to read the first command line argument, we need to access 
    argv[1] = [sp + 16].
*/

.section .text 
.global _start

_start:
    ldr x0, [sp]        // Load argc into x0
    ldr x1, [sp, #16]   // Load [sp + 16] (argv[1]) into x1

    // Compute length of argv[1]
    mov x2, #0              // Initialise length (x2) as 0
    count_loop:
        ldrb w3, [x1, x2]   // Load byte at argv[1] + x2
        cbz w3, print_arg   // If null terminator, break    (null-terminated strings)
        add x2, x2, #1      // Increment length
        b count_loop
    
    print_arg:
        // x1 = pointer to argv[1]
        // x2 = length of argv[1]
        mov x0, #1    // stdout
        mov x8, #64   // syscall: write
        svc #0
    
    exit:
        mov x0, #0    // return 0
        mov x8, #93   // syscall: exit
        svc #0
    