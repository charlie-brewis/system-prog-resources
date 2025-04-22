/// Please note this file is not designed to be run

// Registers
//   - General Purpose (64-bit): `x0` to `x30`
//   - Lower 32-bit half: `w0` to `w30`
//   - Specials:
//       - `x30` = link register (return address)
//       - `sp`  = stack pointer
//       - `zr`  = zero register (returns 0 on read, discards writes)



// Basic Instructions

// Data Movement
mov x0, #123    // Set x0 to 123
mov x1, x0      // Copy the value of x0 into x1

// Arithmetic
add x0, x1, x2  // x0 = x1 + x2
sub x0, x1, x2  // x0 = x1 - x2

// Logical
and x0, x1, x2  // x0 = x1 && x2
orr x0, x1, x2  // x0 = x1 || x2
eor x0, x1, x2  // x0 = x1 ^  x2

// Comparisons
cmp x0, x1      // Sets flags based on x0 - x1
b.eq label      // Branch to `label` if equal (x0 == x1)
b.ne label      // Brancg to `label` if not equal (x0 != x1)
/// etc



// Function Calls (convention)
//     - First 8 args: x0 - x7
//     - Return value: x0
//     - Caller saves: x0 - x17  
//          -> These register values are not preserved across function calls and so must be saved to the stack beforehand
//     - Callee must preserve: x19 - x28, sp, fp, lr
//          -> A function must restore these values before returning - they are long-term "safe" registers



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
