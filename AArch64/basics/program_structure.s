/// Again note this file is not to be run but is instead completely educational

// In this file we will be looking at the hihg-level structure of an ARM assembly program
// Here is the skeleton:

.section .data
msg: .asciz "Hello, world!\n"

.section .text
.global _start

_start:
    // Entry point, like main
    
    // Program logic goes here

    // Exit cleanly
    mov x0, #0    // exit code = 0
    mov x8, #93   // syscall: exit
    svc #0        // trap



// .section 's explained:
//
//  Section        | Purpose
//  ---------------+------------------------------------------------
//  .data/.rodata  | Static data - strings, consts, etc
//  .bss           | Uninitialised data (auto-zeroed by the OS)
//  .text          | Actual instructions
//  .global _start | Makes the `_start` label visible to the linker
//  _start         | The program entry point, like main in C
//
// .data notes:
//   - .asciz adds a null terminator
//   - can also use, .word, .quad, .byte, etc
//
// .bss example:
.section .bss
.lcomm buffer, 256  // Reserves 256 bytes of zero-initialised space
//
// _start Vs main:
//   - _start is the true entry point of a program when no C runtime is used
//   - if you want to interact with C code, you'd write a main and the compiler would set up the _start
//   - but in pure assembly, _start is your entry
//   - inside start you, load arguments for syscalls; perform operations; and cleanly exit

// Lets write an example hello world program again!
.section .data
msg: .asciz "Hello World!\n"

.section .text
.global _start

hello_world:
    // Function Prologue
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Function Body
    mov x0, #1      // stdout (file descriptor)
    adr x1, msg     // address of msg 
    mov x2, #13     // length of msg
    mov x8, #64     // syscall: write (64)
    svc #0          // trap into kernel

    // Function Epilogue
    ldp x29, x30, [sp], #16
    ret


_start:

    bl hello_world

    // Exit cleanly
    mov x0, #0    // exit code = 0
    mov x8, #93   // syscall: exit
    svc #0        // trap