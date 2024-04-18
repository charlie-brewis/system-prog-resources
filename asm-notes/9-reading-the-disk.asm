

; As mentioned in 1-booting.asm, memory is split into multiple sectors - each 512 bytes long.
; Sometimes we may want to access more than just the boot sector while in real mode.
; To do this we need to be able to load other sectors from the disk (hdd) to memory (ram)

; x86 architechture comes with a simple way to do this, again using BIOS interrupts
; But First we must understand how the hard drive is layed out:
;   - Hard drives are composed of multiple platters stacked on top of each other
;   - Each platter has a corresponding head that can read or write to any section of that platter
;   - Each platter is composed of cylinders (or concentric rings)
;   - Here sectors are stored - the smallest readable unit of data from a hardrive

; Therefore, in order to select a sector we use a system called CHS addressing -
;   C - Cylinder
;   H - Head
;   S - sector
; Note: CHS is nowadays considered a legacy system as it was designed to work with traditional magnetic hardrives.
;       Nowadays, there are other methods like LBA, but we will use CHS to learn the concept

; To read a sector we need to know 4 pieces of information:
;   1) What disk do we want to read?
;   2) The CHS address of the sector
;   3) How many sectors starting from that sector do we want?
;   4) Where in main memory do we want to load this data to?

; Lets answer these questions for our example:
;   1)
;     The sector we want to read is on the same disk as our boot sector (see the last line).
;     Therefore we want the same disk as our boot sector
;     The disk from which the boot sector was loaded is stored in the register dl
;   2)
;     As the boot sector is the first sector of head 0, cylinder 0, we want to read the second sector of head 0, cylinder 0
;     Therefore, our CHS address is:    C = 0;  H = 0;  S = 2;          Note: sector indexing starts at 1
;   3)
;     For our example we are only going to read 1 sector
;   4)
;     We can store this whereever we want, however to keep our memory continuous we should try to keep it to just after the memory we are using
;     We have set the origin to 0x7c00 and our boot sector is 512 bytes, therefore the next available address is:
;     0x7c00 + 0x0016 = 0x7e00


; Now that we have all this information, we can go about implementing it - using interrupt 0x13
[org 0x7c00]
mov [diskNumber], dl   ; Store the drive number that the boot sector is stored in to a variable

mov ah, 2   ; First, set it in interrupt mode "Read Sectors"
mov al, 1   ; al is the number of sectors we want to read - as explained above, 1
mov ch, 0   ; ch stores the cylinder number we want to read from, again explained above
mov cl, 2   ; cl is the sector number that we want to read from
mov dh, 0   ; dh is the head number that we want to read from
mov dl, [diskNumber]    ; dl is the drive number we want to read from 
; es:bx is the address that we want to load the data to, however since 0x7e00 is accessible with 16-bit addressing, we can set es to 0:
setEsBx:
    mov bp, 0x8000  ; Setting up the stack to save ax before using it to set ex
    mov sp, bp
    push ax
    mov ax, 0
    mov es, ax
    pop ax
    mov bx, 0x7e00
; Now finally we can call interrupt 0x13 (Low Level Disk Services) which will read the data from
int 0x13

; The next 512 Bytes (1 sector) from physical address 0x7e00 should now be filled with 'A's
; To check this we can print the value of 0x7e00
mov ah, 0x0e
mov al, [0x7e00]
int 0x10


jmp $ 

diskNumber: db 0    ; Set up a pointer for our variable driveNumber
times 510 - ($ - $$) db 0
db 0x55, 0xaa
times 512 db 'A'    ; Here i have filled the sector after our boot sector with A's so that we have something to read from the other sectors for the example



; One thing we could use this for is to extend the amount of real-mode code we can write to be more than 512 Bytes
;* Challenge:
;*      Sometimes, reading from a harddisk can go wrong. When it does, 2 things can happen:
;*      1) The carry flag (cf)