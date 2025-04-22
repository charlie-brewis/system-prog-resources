

; Variables are parts of memory that we access multiple times.
; This means we can store, fetch, and modify data in our program.
; In assembly, we have to do variable memory management ourselves.
; To do this, we store data in memory cells and use named pointers to access the values of those cells.
; A pointer is simply an integer that happens to be a memory address.

myCharacter:    ; We use labels to act as our pointer (variable) names
    db 'A'      ; This variable holds the value 69 in a memory address pointed to by the label myCharacter
mov ah, 0x0e
mov al, [myCharacter]   ; Putting a pointer in square brackets is called dereferencing - 
                        ; this means the value of whatever is at that pointer, rather than the pointer itself (e.g., 'A' here)
int 0x10
; The code above should print the value of our variable (i.e., 'A').
; However, this unfortunately doesn't work and will instead print a seemingly random character instead.
; This is beacuse the BIOS stores a lookup table of interrupt codes, which is loaded before any other program,
; so of course it takes up some space in memory.
; Thus, for safety, pointer origin is taken as 0x7c00 rather than 0x0000.
; Therefore, to fix this bug we need to offset our pointer by 0x7c00:
mov al, [myCharacter + 0x7c00]
int 0x10

; The above is a completely valid way to do this and works. However, it is quite clunky.
; A better way to do this is to first redefine the origin of memory addressing to 0x7c00 for the whole program
; This is done with the following command:
[org 0x7c00]
; It is considered good practise to put this at the start of your bootloader.
; Now the following code will correctly print 'A'
mov al, [myCharacter]
int 0x10


; We can also use varaibles to store strings
; Strings are better thought of as arrays of characters and so take up multiple memory cells - 1 per character
; We also need a flag to define when the string stops in memory for when we iterate over the characters
; We use ASCII code 0 (or NULL) to signify the end of a string - this is called a null-ended string
myStringVariable:
    db "Hello World!", 0
; The above variable takes up exactly 12 memory cells + 1 NULL cell

; To print a string, we must again use a pointer
; To keep the code neat, we will assign the Base Register (bx) to be the pointer:
mov bx, myStringVariable

printStringStart:
    mov al, [bx]            ; Assign al to the value that bx is pointing to
    cmp al, 0               ; If the value of al is NULL, we have reached the end of the string
    je printStringEnd       ; Jump to the end
    int 0x10                
    inc bx                  ; Increment the string pointer by 1 - it now points to the next memory cell (i.e., next character)
    jmp printStringStart    ; Loop
printStringEnd:

jmp $ 
times 510 - ($ - $$) db 0
db 0x55, 0xaa