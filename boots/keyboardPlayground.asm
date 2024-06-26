


[org 0x7c00] ; Fix pointer offset

;* Typing Exercise
typingLoop:
    mov ah, 0x00
    int 0x16
    mov ah, 0x0e
    int 0x10
    cmp al, 8
    je backspacePressed
    endBackspacePressed:
    cmp al, 13
    je enterPressed
    endEnterPressed:
    jmp typingLoop

backspacePressed:
    mov al, 32 ; Space
    int 0x10
    mov al, 8 ; Another backspace
    int 0x10
    jmp endBackspacePressed

enterPressed:
    mov al, 10
    int 0x10
    jmp endEnterPressed



;* Store char exercise
; char:
;     db 0
; mov bx, char

; inputChar:
;     mov ah, 0x00
;     int 0x16
;     mov [bx], al
; printChar:
;     mov al, [bx]
;     mov ah, 0x0e
;     int 0x10



;* Store string exercise
; buffer:
;     times 10 db 0

; mov bx, buffer

; inputString:
;     mov ah, 0x00
;     int 0x16
;     cmp al, 13
;     je setupPrint 
;     mov [bx], al 
;     inc bx
;     jmp inputString

; setupPrint:
;     mov bx, buffer 
;     mov ah, 0x0e

; printString:
;     mov al, [bx]
;     cmp al, 0
;     je end
;     int 0x10
;     inc bx
;     jmp printString

; end:



jmp $ ; Infinate loop at end of boot
times 510 - ($ - $$) db 0 ; define 0 as many times as needed to fill boot sector (512B)
db 0x55, 0xaa ; Validate boot sector


