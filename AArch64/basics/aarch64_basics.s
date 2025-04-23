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