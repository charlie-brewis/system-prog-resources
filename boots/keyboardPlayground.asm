


[org 0x7c00] ; Fix pointer offset

;* Saving an input char to a variable
; Define a varaible of a single byte, initialised with 0
; char:
;     db 0

; mov ah, 0x00
; int 0x16
; mov [char], al ; Set's char's value to the value of al

;* Saving an input string to memory
; stringBuffer:
;     times 10 db 0 ; Initialise a space in memory of 10 empty bytes for the string
;     mov bx, stringBuffer ; set bx to a pointer to the beggining of the buffer
;     mov [bx], al ; Save the input string to the location of the pointer to the buffer 
;     inc bx ; Increment buffer pointer
;     jmp inputLoop


;* Typing Exercise
; typingLoop:
;     mov ah, 0x00
;     int 0x16
;     mov ah, 0x0e
;     int 0x10
;     cmp al, 8
;     je backspacePressed
;     endBackspacePressed:
;     jmp typingLoop

; backspacePressed:
;     mov al, 32 ; Space
;     int 0x10
;     mov al, 8 ; Another backspace
;     int 0x10
;     jmp endBackspacePressed


mov ah, 0x00
int 0x16
mov [char], al
printChar:
    mov al, [char]
    mov ah, 0x0e
    int 0x10
char:
    db 0

jmp $ ; Infinate loop at end of boot
times 510 - ($ - $$) db 0 ; define 0 as many times as needed to fill boot sector (512B)
db 0x55, 0xaa ; Validate boot sector


