/*
Write "Hello" and "World" on two lines

Use two separate write syscalls.
Practice using .asciz or .ascii strings.
*/

.section .data
hello: .asciz "Hello\n"
world: .asciz "World!\n"

.section .text
.global _start

_start:
    // Syscall: write[x8: 64] (x0: file_desc, x1: msg_addr, x2: msg_len)
    mov x0, #1  //stdout
    adr x1, hello
    mov x2, #6
    mov x8, #64
    svc #0

    // Syscall: write: x0, x8 are the same but we need to redefine them as they are not 
    // 'callee-preserved' registers (x19-x28, sp, fp, lr) and so syscalls and functions may modify 
    // their values
    mov x0, #1  //stdout
    adr x1, world
    mov x2, #7
    mov x8, #64
    svc #0

    // Exit cleanly
    mov x0, #0
    mov x8, #93
    svc #0
