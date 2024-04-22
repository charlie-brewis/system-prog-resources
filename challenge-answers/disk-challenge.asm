[org 0x7c00]
mov [diskNumber], dl    ; Store the drive number of the boot sector

setupStack:
    mov bp, 0x8000
    mov sp, bp 

defineRegisters:
    mov ah, 2               ; "Read Sectors" mode
    mov al, [numSectors]    ; Number of sectors to read
    mov ch, 0               ; Cylinder number to read from  - C
    mov cl, 2               ; Sector number to read from    - S
    mov dh, 0               ; Head number to read from      - H
    mov dl, [diskNumber]    ; Drive number to read from
    defineLoadLocation:
        push ax 
        mov ax, 0   ;todo: find out why we shouldn't directly mov 0 into es
        mov es, ax  ; Set es to 0 as 0x7e00 is addressable with 16 bits
        mov bx, 0x7e00      ; Location in memory to load the sector
        pop ax 

int 0x13

checkErrors:
    checkCarryFlag:
        cmp cf, 1       ;! cf is not defined
        jne checkNumSectors
        call printCarryFlagError
    checkNumSectors:
        cmp al, [numSectors]
        je print0x7e00
        call printNumSectorsError

print0x7e00:
    mov ah, 0x0e
    mov al, [0x7e00]
    int 0x10



jmp $ 

; Variables
diskNumber: db 0
numSectors: db 1
carryFlagError: db "Error: Carry Flag returned 1.", 0
numSectorsError: db "Error: Incorrect Number of Sectors Loaded.", 0

; Functions
printCarryFlagError:
    mov ah, 0x0e
    mov bx, carryFlagError
    printCarryFlagErrorLoopStart:
        mov al, [bx]
        cmp al, 0
        je printCarryFlagErrorLoopEnd
        int 0x10
        inc bx
        jmp printCarryFlagErrorLoopStart
    printCarryFlagErrorLoopEnd:
    ret 

printNumSectorsError:
    mov ah, 0x0e
    mov bx, numSectorsError
    printNumSectorsErrorLoopStart:
        mov al, [bx]
        cmp al, 0
        je printNumSectorsErrorLoopEnd
        int 0x10
        inc bx
        jmp printNumSectorsErrorLoopStart
    printNumSectorsErrorLoopEnd:
    ret


fillBootSector:
    times 510 - ($ - $$) db 0
    db 0x55, 0xaa

fillReadSector:
    times 512 db 'A'