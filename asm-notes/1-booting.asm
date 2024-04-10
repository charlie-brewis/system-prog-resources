; Assembler Command:
;       nasm -f bin boot.asm -o boot.bin
; VM Command:
;       qemu-system-x86_64 boot.bin


; First, we need our OS to actually do something in order to boot.
; Since this file focuses on booting exclusively, we will simply make it infinately loop:
jmp $ 
; The above is jmp command - this command lets us jump to any specified label in the program.
; The dollar sign ($) is a special label in asm_x86, it points to the address of the current line.
; Thus `jmp $` simply jumps to the same line over and over again - an infinate loop.


; Memory on a computer is split up into different sectors, the code for booting is stored in the 'Boot Sector'.
; Since a boot is the first thing that happens, the boot sector is the first sector on any drive.
; A boot sector is always exactly 512 Bytes long, and the last 2 bytes are always the numbers 85, 176 (or 0x55, 0xaa in hex)
; To achieve this 512B requirement we can fill up the remaining bytes with zeros using the define byte command (db)
; db will set the next availably memory cell to the specified value:
times 510 - ($ - $$) db 0
; The above line is quite scary so lets break it down:
;   1) times : this keyword takes 2 values, a number (510 - ($ - $$)) and an operation (db 0). The operation is simply repeated as many times as the number
;   2) 510 - ($ - $$) : as stated above this is just a number. We already know that $ is the address of the current line,
;                       and $$ is just the address of the start of the current sector. Therefore,
;                       ($ - $$) is just the number of cells (bytes) used so far in our boot script.
;   3) db 0 : this is an operation that sets the value of the next empty memory cell to 0
;
; Overall this line will set all empty memory cells following our boot script to 0 - up to memory address 510


; We go up to 510, rather than 512 to leave space for the 2 important bytes at the end of our boot sector, which validate the sector as a boot sector
db 0x55, 0xaa