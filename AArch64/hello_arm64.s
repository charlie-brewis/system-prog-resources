// Note that 64-bit ARM is often referred to as AArch64

.section .data
msg: .asciz "Hello AArch64!\n"

.section .text
.global _start

_start:
    mov x0, #1      // stdout (file descriptor)
    ldr x1, =msg    // address of msg 
    mov x2, #15     // length of msg
    mov x8, #64     // syscall: write (64)
    svc #0          // trap into kernel

    mov x0, #0      // exit code
    mov x8, #93     // syscall: exit (93)
    svc #0          // trap into kernel

// Assemble to assembly file (.s) to object file (.o)
//     `aarch64-linux-gnu-as -o hello_arm64.o hello_arm64.s`

// Statically link the object file (.o) to create an executable
//     `aarch64-linux-gnu-ld -static -o hello_arm64 hello_arm64.o`
//         - Here we can statically link (and thus use QEMU) as there are no shared (dynamic) libaries

// Run the executable using QEMU
//     `qemu-aarch64 ./hello_arm64`



/// More AArch64 syscall numbers (0-291) can be found here: 
///   https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md#arm64-64_bit


// Also note we can combine assembling and linking into a single command in gcc, just like with c code
//     `aarch64-linux-gnu-gcc -static -nostartfiles -o hello_again hello_arm64.s`
//         - We need to specify `-nostartfiles` as gcc expects a .c file which expects a `main` function
