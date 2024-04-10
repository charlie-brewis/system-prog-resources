
; Assembler Command:
;       nasm -f bin boot.asm -o boot.bin
; VM Command:
;       qemu-system-x86_64 boot.bin



;* PRINTING 
; We set the high section of the ax register to 0x0e to put the OS in teletype mode, allowing us to print
mov ah, 0x0e
; We set the low section of the ax register to the character we want to print
mov al, 'A'
; Call an interrupt of vector 10h, which puts us in video services - service 0eh in ah is a service contained in this
; This is the line that interrupts the cpu and actually prints the string
int 0x10

; We can print multiple chars by interrupting with video services after every time we change al,
; so long as ah stays in Write Character in TTY Mode (0eh)
; mov al, 'C'
; int 0x10
; mov al, 'E'
; int 0x10

; Instead we can use ascii Values, this lets us easily print the alphabet in very few lines:
ALPH_LOOP_START:
    inc al  ; First, increment al by 1
    cmp al, 'Z' + 1
    je ALPH_LOOP_END ; If al is equal to Z+1, don't print interrupt and jump to the end of the loop
    int 0x10
    jmp ALPH_LOOP_START
ALPH_LOOP_END:

; Challenge to make a program that outputs the alphabet in alternating caps
mov al, 10 ; New Line
int 0x10
mov al, 13 ; Carraige return
int 0x10

mov al, 65 
int 0x10
ALPH_CHALLENGE_LOOP_START:
    cmp al, 91 ; a
    jl add32
    sub al, 32
    jmp skipadd
    add32:
        add al, 32
    skipadd:
    inc al 
    int 0x10
    cmp al, 'z'
    jne ALPH_CHALLENGE_LOOP_START


mov al, 10 ; New Line
int 0x10
mov al, 13 ; Carraige return
int 0x10

;* STRINGS
; We can declare strings with variable names using labels and db
myHelloVariable:
    db "Hello World!", 0 ; the 0 indidcates the end of the string in memory - null-ended

mov ah, 0x0e ; again we put the system into TTY mode
; mov al, [myHelloVariable] ; the square brackets returns the value at the pointer - called dereferencing
; This actually doesnt work as pointers in asm are initially ofset by 0x7c00
; We could solve this issue using this line:
; mov al, [myHelloVariable + 0x7c00]
; However a better way to do this is to first set the origin of our memory addressing to 0x7c00 like so:
[org 0x7c00]
; mov al, [myHelloVariable] ; Now that we have set the pointer origin, this correctly prints the correct first character 'H'
; However to print the whole string we have to use a loop:
mov bx, myHelloVariable ; bx is a general use register

printString:
    mov al, [bx]
    cmp al, 0
    je endPrintString
    int 0x10
    inc bx
    jmp printString
endPrintString:
int 0x10
; See helloWorld.asm for a more consise example of string declaration and printing

; Newline + carraige return
mov al, 10 
int 0x10
mov al, 13 
int 0x10


;* KEYBOARD INPUTS
mov ah, 0x00 ; wait to read character from keyboard mode - char gets saved to al, scancode to ah
int 0x16 ; call a keyboard services interrupt 

; So now we can print the input character like so
mov ah, 0x0e
int 0x10

; Or we can save the value to a variable
mov [char], al
char: 
    db 0

; Or we can use a loop to store a whole string
; Defines a buffer variable of 10 empty memory cells
buffer:
    times 10 db 0

mov bx, buffer ; bx now points to the first cell of our buffer
mov ah, 0x00 ; Enter mode 0x00 (Read Character)

inputString:
    int 0x16 ; Call BIOS interrupt 0x16 (wait for keyboard input, set al to input character)
    cmp al, 13 ; If the input character is enter, end input 
    je endInput 
    mov [bx], al ; Set the value that bx is pointing to to al (the input character)
    inc bx ; Increment bx to point to the next cell
    jmp inputString
endInput:


;* STACK
; There are 2 special registers we can use:
;   The base pointer (bp) points to the address of the base of the stack
;   The stack pointer (sp) points to the address of the top of the stack
; The rest of the stack is contiguous between the 2
; Example:
mov bp, 0x800   ; Set the base pointer to 0x800
mov sp, bp      ; Since the stack is empty we can set the stack pointer to the base pointer
mov bh, 'A'
push bx         ; Give bx some value and push it to the stack
mov bh, 'B'
print:
    mov ah, 0x0e
    mov al, bh 
    int 0x10
    ; Prints bh - 'B'
pop bx 
print:
    mov ah, 0x0e
    mov al, bh 
    int 0x10
    ; Prints bh -'A'

; `pusha` and `popa` are 2 very useful operations that push and pop these 8 registers to the stack:
; ax, cx, dx, bx, sp, bp, si, di
; They are pushed in this order and popped in reverse
; This is useful when the program needs to do another procedure with these registers but wants to save the state for after said procedure
; ... like a function





;* BOOTING
; Jumps to the current memory address - i.e., The boot will infinately loop
jmp $

; A boot sector is always 512 bytes (i.e., assembly lines) long. 
; Therefore this command 'define byte 0's the exact number of times needed to get to 510 lines 
; - (i.e., makes it so that every blank line is actually just 0 up to 510 lines).
; This is done as $ = current address, and $$ = section start address,
; therefore $ - $$ = the number of lines of code before this one.
times 510-($-$$) db 0

; The last 2 lines in a boot sector are always 0x55 0xaa, therefore we db them at the end.
; 0x is simply a prefix, stating that the following number is in hexadecimal
db 0x55, 0xaa