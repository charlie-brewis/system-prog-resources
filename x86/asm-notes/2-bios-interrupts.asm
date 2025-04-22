

; In asm_x86 we can use BIOS interrupts in order to get the system to respond to things
; There is many different types of BIOS interrupts with different modes, which can be found here:
; https://en.wikipedia.org/wiki/BIOS_interrupt_call
; Obviously we can't talk about every interrupt type and every mode, so they will be explained as they become needed
; For now the important thing to grasp is this concept.
; This is how we implement it:

; CPU's have very fast pieces of memory called registers.
; There are many registers with different uses in x86 which can be found here:
; https://en.wikibooks.org/wiki/X86_Assembly/X86_Architecture
; In assembly, we can manipulate these registers manually.
; For BIOS interrupts we use the accumulator (ax).
; ax is a 16-bit register which is actually split into 2 8-bit registers: (a-high [ah]; and a-low [al])
; Before calling an interrupt, if the interrupt has multiple modes it can take, we must specify the mode by moving the mode code into ah:
mov ah, 0x00
; The above line moves (sets) the value of 0x00 to register ah 
; This means when an interrupt is called the system will see that ah is in mode 0x00 and so perform that functionality

; Now we can perform a BIOS interrupt:
int 0x16
; The above line uses the `int` keyword followed by an interrupt code.
; Looking at the wikipedia artical on line 5, we can see interupt code 0x16 is the keyboard services interrupt
; Now we can see that mode 0x00 of interrupt 0x16 is called 'Read Character'
; This specific interrupt + mode will wait for a keyboard input and then return the output to al 

; There will be many more interrupts to come so this is absoultely not a complete file.
; However, so long as you grasp this concept of interrupts + modes you should be set.


; booting hehe
jmp $ 
times 510 - ($ - $$) db 0
db 0x55, 0xaa