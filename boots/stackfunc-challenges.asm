
;* Stack challenge
setupStack:
    mov bp, 0x800
    mov sp, bp 


inputLoop:
    getInput:
        mov ah, 0x00    ; Need to reset as after int 0x16 ah is set to the scan code of the input char
        int 0x16

    pushInputToStack:
        push ax

    checkIfEnter:
        cmp al, 13
        je setupPrint
    jmp inputLoop


setupPrint:
    mov ah, 0x0e

printStack:
    pop ax
    mov ah, 0x0e
    int 0x10
    cmp bp, sp
    jne printStack




jmp $ 
times 510 - ($ - $$) db 0
db 0x55, 0xaa