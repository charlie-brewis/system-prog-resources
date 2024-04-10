

; For keyboard inputs we need to use a different type of interrupt + mode pair to printing characters
; We must use interrupt 0x16 (Keyboard Services) in mode 0x00 (Read Character)
mov ah, 0x00
int 0x16
; This will now wait for a keyboard input and set al to the value of the entered key

; We can then print the value of al just like before:
mov ah, 0x0e
int 0x10

;* Challenge: Use a loop to make it so that you can type whole words into the terminal


; However, in order to do anything really useful with keyboard inputs we need to be able to save them to variables
; First we will start with a single character:
char:           ; We define an empty cell in memory with a pointer, 'Char'
    db 0    
mov bx, char    ; As before we use register bx to act as the pointer to this variable

;? From now on, I will sometimes use labels to denote explicitally what certain blocks of code are doing, even when not used in a loop or as a pointer
inputChar:
    mov ah, 0x00
    int 0x16
    mov [bx], al
; In the code block above we have gotten an input character and used dereferencing to set the value that bx points at to said character
; If this is unclear to you, please go over 4-variables.asm again
; Now we can do anything we want with this saved character, like print it:
printChar:
    mov al, [bx]
    mov ah, 0x0e
    int 0x10


; Sometimes we might want to be able to enter whole strings, rather than just a character
; This is a little trickier as we need to save the string across multiple memory addresses.
; To do this, we first define a buffer of a set length to hold our string - a buffer is just an empty space in memory of multiple cells
buffer:             
    times 10 db 10  ; This defines an empty space in memory of 10 cells.
mov bx, buffer      ; Again we use bx as a pointer to the first cell in buffer

mov ah, 0x00
inputStringStart:
    int 0x16
    cmp al, 0x0d 
    je inputStringEnd       ; If the last input character was enter, end the string input
    mov [bx], al            ; Set the value of the cell that bx points to to the last input character
    inc bx                  ; Increment bx
    jmp inputStringStart    ; Loop
inputStringEnd:
; Now we have an input string stored in memory under the variable name 'buffer'
; We can move our pointer back to the start of the string like this:
mov bx, buffer 
; Now we can do anything we want with this string.

;* Challenge: Create a program that allows you to enter a string of length 10 and prints the string back when you press enter. Use a loop so it does this forever.


jmp $ 
times 510 - ($ - $$) db 0
db 0x55, 0xaa