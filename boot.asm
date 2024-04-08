
; Assembler Command:
;       nasm -f bin boot.asm -o boot.bin
; VM Command:
;       qemu-system-x86_64 boot.bin


;* Printing 
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





;* Booting
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