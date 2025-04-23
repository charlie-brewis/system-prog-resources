/*
Write a program that returns 42 as exit code

Use mov x0, #42 before the exit syscall.
Then check `echo $?` in the shell after running it
*/

.section .text 
.global _start
_start:
    mov x0, #42  // exit code = 42
    mov x8, #93  // syscall: exit
    svc #0
