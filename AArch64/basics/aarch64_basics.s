/// Please note this file is not designed to be run

// Registers
//   - General Purpose (64-bit): `x0` to `x30`
//   - Lower 32-bit half: `w0` to `w30`
//   - Specials:
//       - `x30` = link register (return address), also called `lr`
//       - `sp`  = stack pointer
//       - `xzr` = zero register (returns 0 on read, discards writes) [64b]



// Basic Instructions

// Data Movement
mov x0, #123       // Set x0 to 123
mov x1, x0         // Copy the value of x0 into x1

// Arithmetic
add x0, x1, x2     // x0 = x1 + x2
sub x0, x1, x2     // x0 = x1 - x2

// Logical
and x0, x1, x2     // x0 = x1 && x2
orr x0, x1, x2     // x0 = x1 || x2
eor x0, x1, x2     // x0 = x1 ^  x2

// Comparisons
cmp x0, x1         // Sets flags based on x0 - x1
b.eq label         // Branch to `label` if equal (x0 == x1)
b.ne label         // Branch to `label` if not equal (x0 != x1)
b.lt label         // Signed less than
b.ge label         // Signed greater or equal
b.hi label         // Unsigned >
b.ls label         // Unsigned <=

cset w0, eq        // Set w0 = 1, if equal, else 0

// Memory Access
ldr x0, [x1]       // Load the value of the memory pointed to by x1 to x0
str x0, [x1]       // Store x0 to the memory pointed to by x1
ldr x0, [x1, #8]   // Offset - load from x1 + 8



// Function Calls (convention)
//     - First 8 args: x0 - x7
//     - Return value: x0
//     - Caller saves: x0 - x17  
//          -> These register values are not preserved across function calls and so must be saved to the stack beforehand
//     - Callee must preserve: x19 - x28, sp, fp, lr
//          -> A function must restore these values before returning - they are long-term "safe" registers
//     - Call a function with `bl` ("branch with link" - saves return address in x30), e.g.:
//         - bl some_function
//           !
//             Remember here the `lr` (x30) stores the address the program should return back to,
//             while x0 stores the return value of the function. 
//           !



// System Calls (Linux)
//     - Syscall number in `x8`
//     - Args in x0 - x5
//     - `svc #0` to trigger trap
// Example:
mov x0, #1   // stdout
ldr x1, =msg
mov x2, #15
mov x8, #64  // write
svc #0



// Stack Frame Management
//
// When a function is called it needs:
//     - Space to store temporary variables
//     - To save certain registers so it can restore them before returning
//     - To maintain a predictable structure
// This workspace is called the "stack frame", which lives on the stack
//
// Key Registers:
// - 'stack pointer' (`sp`)  -> Points to the top of the stack
// - 'frame pointer' (`x29`) -> Points to the base of this function's frame 
// - 'link register' (`x30` / `lr`) -> Stores the return address for the `ret` instruction
//
//
// Example:
// 1. Function Prologue:
stp x29, x30, [sp, #-16]!  // Step 1: Save x29 (frame pointer) and x30 (link register) to memory
                                    // Note its 16 bytes because each 64 bit register is 8 bytes
mov x29, sp                // Step 2: Set up new frame pointer
//  Some notes about this syntax:
//      - `stp` = 'store pair' (saves 2 registers to memory at once), so here the values of x29 and 
//         x30 are being stored at [sp - 16] and [[sp - 16] + 8] respectively
//      - [sp, #-16]! = subtract 16 from sp and store at that new location (sp -= 16) -> Note we 
//          subtract because the stack grows downward
//      - Note the bang just updates `sp` with this new value
// `stp x29, x30, [sp, #-16]!` == `sp -= 16; str x29, sp; str x30, [sp + 8];`
//
// 2. Function Epilogue
ldp x29, x30, [sp], #16  // Step 1: Restore x29 and x30, and move sp back up
ret                      // Step 2: Return to the call address (stored in x30)
//  Notice the syntax is very similar:
//      - Step 1 loads from sp and adds 16 after this time
//      - This puts back our frame pointer, return address, and stack pointer to what they were before the function was called
//
//
// So why do we do all this?
// This precise methodology ensures that:
//     - The function can safely call other functions (because it has preserved x30 in memory)
//     - The calling function's stack frame stays intact
//     - The stack is cleaned up correctly when returning
//
// We can also reserve space for local variables:
sub sp, sp, #32  // Reserve 32 bytes for local vars
// Use [sp] ... [sp + 31] for tempoarary storage
add sp, sp, #32  // Clean up before epilogue


my_function:
    // Function Prologue //
    stp x29, x30, [sp, #-16]!   // Save frame pointer (x29) and return address (x30), adjust sp down
    mov x29, sp                 // Set new frame pointer (x29 = sp)

    sub sp, sp, #32             // Reserve 32 bytes for local variables (optional)

    // Function Body //
    // ... use [sp] to [sp+31] for local variables if needed ...

    add sp, sp, #32             // Free local variable space

    ldp x29, x30, [sp], #16     // Restore old frame pointer and return address, adjust sp up
    ret                         // Return to caller using x30



// Assembling, Linking, and Executing
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



//-------------------------------------------------------------------------------------------------
// A Clarification on Moving immediate values

// In AArch64, you cant load arbitary 64-bit constants directly to registers with a single instructions
// So the instruction:
mov x0, 0x123456789ABCDEF0
// is invalid and must instead be written with a sequence of specialised instructions

// 'Move with zero' - `movz`
// Loads a 16-bit immediate to a register and zeroes out the rest of the bits
// We can use 'logical shift left' - `lsl` to determine where in the register they are placed
movz x0, #0x1234           // x0 = 0x0000000000001234
movz x0, #0x1234, lsl #16  // x0 = 0x0000000012340000 - Note that since this is hexadecimal a binary lsl of 16 is 4 digits

// 'Move with keep' - `movk`
// Also writes a 16-bit immediate to a register, but keeps the other bits unchanged
// Used to build up large values in pieces

movz x0, #0xABCD, lsl #48  // Set the upper 16 bits
movk x0, #0x1234, lsl #32  // Set the next 16 bits
movk x0, #0x5678, lsl #16  // Set the next 16 bits
movk x0, #0x9ABC           // Set the lower 16 bits
// x0 = 0xABCD123456789ABC

// Note that most assemblers will allow you to write it with a single `mov` instruction but it is important
// to undertstand what's going on under the hood
//--------------------------------------------------------------------------------------------------




