

; The stack is an area of volitile memory which can be used by programs
; A stack data structure works on a first-in, last-out basis - like a stack of plates
; We have 2 operations we can do to the stack - push and pop
; Push will place an item on the top of the stack
; Pop will remove the item on the top of the stack

; To implement a stack in assembly we have 2 special registers we can use:
;   - The Base Pointer (bp):  Points to the address of the base of the stack
;   - The Stack Pointer (sp): Points to tha address of the top of the stack
; The rest of the memory of the stack is contiguous between the 2 pointers.

; Example:
mov bp, 0x800   ; Set the base pointer to 0x800
mov sp, bp      ; Since the stack is empty on creation, we can initially set the stack pointer equivalent to the base pointer

mov bh, 'A'     ; As an example we are assigning bx some value to push to the stack
push bx         ; The value of bx ('A') is now stored at the top of the stack

;? As an example of the stack in action we will now reassign bh, print bh, pop the stack, and print bh again
printbh1:
    mov bh, 'B'
    mov ah, 0x0e
    mov al, bh
    int 0x10
    ; This will print the current value of bh ('B')

pop bx  ; Now we pop the stack back into bx, overriding [bh] ('B') with what was stored at the top of the stack ('A')

printbh2:
    mov al, bh 
    int 0x10
    ; This will print the current value of bh ('A')



; There are 2 special stack operations called `pusha` and `popa` in x86 asm
; These operations push and pop these 8 registers to the stack respectively:
;   1) Accumulator   (ax)
;   2) Counter       (cx)
;   3) Data          (dx)
;   4) Base          (bx)
;   5) Stack Pointer (sp)
;   6) Base Pointer  (bp)
;   7) Source        (si)
;   8) Destination   (di)
; The resgister are pushed in this order and popped in the reverse

; This is useful when a program needs to pause whatever it is executing, execute another routine, and then come back to executing the previous routine
; In situations like this we can use the stack to save and load these register states before and after jumping
; Another way we can do this is by using functions...


jmp $ 
times 510 - ($ - $$) db 0
db 0x55, 0xaa