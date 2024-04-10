

; To print a character to the screen we use interrupt 0x10 [video services] in mode 0x0e [Teletype Mode]
; This specific interrupt will print the value of al to the screen
mov ah, 0x0e
mov al, 'A'
int 0x10

; We can actually use ascii values in denary or hex as well to signify characters 
; This means we can use a LOOP to print the alphabet:
alphabetLoopStart:          ; This is called a label, it is a line that we can jump to from anywhere in the program
    inc al                  ; First, we increment al by 1
    cmp al, 'Z' + 1         ; We compare al to Z + 1, returning ==, !=, >, <, or a combination of 2
    je alphabetLoopEnd      ; If they are equal (i.e., we have gone past Z), then we will jump to the end of the loop
    int 0x10                ; Print the current value of al
    jmp alphabetLoopStart   ; Jump back to the start of the loop
alphabetLoopEnd:

;* Challenge: Make a loop that prints the alphabet in alternating caps


jmp $ 
times 510 - ($ - $$) db 0
db 0x55, 0xaa