
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

; printStackBackwards:
;     pop ax
;     mov ah, 0x0e
;     int 0x10
;     cmp bp, sp
;     jne printStackBackwards

printStackForward:
    decrementStackBase:
        sub bp, 2   ; Need to sub first as the base (0x800) is empty
    printValueAtStackBase:
        mov al, [bp]
        int 0x10
    exitIfStackEmpty:
        cmp bp, sp
        jne printStackForward

newLine:
    mov al, 10
    int 0x10
  




jmp $ 
times 510 - ($ - $$) db 0
db 0x55, 0xaa