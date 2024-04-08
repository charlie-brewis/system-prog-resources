
[org 0x7c00]

myString:
    db "Hello World!", 0

mov ax, 10

mov ah, 0x0e
mov bx, myString
printString:
    mov al, [bx]
    cmp al, 0
    je endPrintString
    int 0x10
    inc bx 
    jmp printString
endPrintString:

jmp $

times 510 - ($ - $$) db 0
db 0x55, 0xaa