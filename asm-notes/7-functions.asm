

; In assembly, a function is just a subroutine that jumps back to where it was called after it has finished executing
; This should hopefully be a simple concept as the concept is exactly the same as in high-level languages


; This is done internally using the stack.
; The computer will pusha, jmp to the function, execute until return, jmp back to the function all, and popa
; We can absolutely code this manually using pusha and procedures, but functions just makes the code a little cleaner
; How we differentiate between a function and a procedure is that a function always has a return (`ret`)
; We also use `call` instead of `jmp` to invoke a function


mov ah, 0x0e
printA:
    mov al, 'A'
    int 0x10

call printNewlineFunction   ; We use the call keyword to invoke the function

printB:
    mov al, 'B'
    int 0x10


printNewlineFunction:
    mov ah, 0x0e
    mov al, 10
    int 0x10
    mov al, 13
    int 0x10
    ret     ; We use the ret keyword to signal a return to the function call





jmp $ 
times 510 - ($ - $$) db 0
db 0x55, 0xaa