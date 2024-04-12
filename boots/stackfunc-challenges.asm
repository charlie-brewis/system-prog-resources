
;* Stack challenge
setupStack:
    mov bp, 0x800
    mov sp, bp 

getInput:
    mov ah, 0x00
    int 0x16

pushInputToStack:
    push ax 

printStack:
    pop ax
    mov ah, 0x0e
    int 0x10



jmp $ 
times 510 - ($ - $$) db 0
db 0x55, 0xaa