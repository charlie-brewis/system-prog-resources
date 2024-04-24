; Hold your horses, this is a big one.

;* WHAT IS PROTECTED MODE
; Protected mode is a 32-bit addressing mode of the CPU
; This means we can now use roughly 4GB of addressable memory.
; However, we can no longer use BIOS interrupts, hence "protected", so it's not going to be as simple as before
; Protected mode (PM) also lets us implement things like paging and multitasking, although that is outside of our scope for now
; The main reason we are going to switch to PM is because it means we can finally start writing in C!
; Woo hoo!


; So, how do we switch to PM?
; Well....

;* SEGMENTATION IN PROTECTED MODE
; First of all we need to define our memory segmentation
; We looked at this in real mode in 8-segmentation.asm, however it's not as simple as just using segment registers in PM
; In PM, every segment has a bunch of properties that we need to set to define its usage.
; The datastructure these properties are stored in is called the Global Descriptor Table (GDT)
; The structure of the GDT is a mess, so lets have a look at it:

;* The GDT
; We need to define a "Descriptor" for each segment that we are going to use in PM.
; A descriptor is simply a stored list of properties of the segment.
; There are several memory management models which we can choose from, determining the structure of these descriptors 
; the most common of which being "Paging".
; However, to keep things simple for now we will look at the "Flat Memory Model" (FMM)
; FMM simply means we will treat memory as one single contiguous address space - (meaning we're not really going to use segmentation... shhh).


; The GDT must contain at least 2 segment descriptors: The Code Segment Descriptor, and The Data Segment Descriptor

;* The Code Segment Descriptor
; The first 2 things we need to define is the location, and size of our memory segment, i.e.:
;   Base  (32b) - Describes the starting location of our segment                                    ;? We will start our CSD at 0x00
;   Limit (20b) - Describes the size of our segment                                                 ;? We will set our CSD to it's maximum size - 0xfffff (since it's 20b)

; Our next 3 properties to describe are: 
;   Present   (1b) - Describes whether the segment is used (1 if used, 0 if unused)                 ;? We will be using our code segment, so we will set this to 1
;   Privalege (2b) - Used to define a segment hierarchy, and implement memory protection            ;? We want our code segment to be the highest privalege, so we will set this to 00
;   Type      (1b) - Type is used to determine whether this segement is the code OR data segments   ;? This is the code segment, so we will set this to 1

; The other properties of the segment are stored as flags (i.e., a single bit representing a boolean property):
; We actually have 2 sets of flags, both of which being 4 bits long:
; 1) Type Flags (4b):
;       - Will this segment contain code? (code)                                                    ;? Since this is the code segment, yes, thus we set this flag to 1
;       - Can this code be executed from lower-privalege segments? (conforming)                     ;? As this is the highest privaledge segment, no, so we will set this flag to 0
;       - Can this segment be read (1) or is it only executable (0)? (readable)                     ;? We will set this to 1 in order to read constants in our c-code
;       - Controlled by the CPU, set to 1 whilst this segment is being managed. (accessed)          ;? Intially, we will set this to 0 and then let the CPU do it's thing
; 2) Other Flags (4b):
;       - When this is set to 1, the limit is multiplied by 0x1000 - allowing us to span 4GB
;         of memory. (granularity)                                                                  ;? This is useful, so we will set it to 1
;       - Is this segment going to use 32-bit memory? (D - default operand size)                    ;? yes, 1
;       - Is this segment going to use 64-bit memory? - D must be 0 if 1 (Long)                     ;? We have set D to 1, so 0
;       - Is this segment available for software used, i.e., system dependant flag (Available)      ;? 0

; That's it for our code segment descriptor! For clarification this is what it looks like:
;? 00000000000000000000000000000000,11111111111111111111,1       ,00        ,1    ,1010       ,1100
;? Base;                            Limit;               Present; Privalege; Type; Type-Flags; Other-Flags

;* The Data Segment Descriptor
; The Data Segment Descriptor (DSD) is very similar, so to keep it as brief as possible I will only point out its differences with the CSD:
;? Firstly, our first type flag we will change to 0, as the data segement does not contain code
; The second type flag is no longer the conforming flag, but is now the direction flag:
;       - Does the segment expand downwards? (direction)                                            ;? We will have our data segement expand upwards, so 0
; The third type flag is now writable instead of readable:
;       - If the segment is read only, set this to 0. (writable)                                    ;? We will have a read/write data segment, so we will set this to 1

; That's it. Those are the only differences.


;* Implementation
; Now that we understand our segment descriptors, we need to look at how to go about implementing them using assembly
; To do this we will mainly use 3 pseudo-instructions:
;   db: define bytes            (We've used this already)
;   dw: define words            (This is actually just defining 2 bytes)
;   dd: define double words     (Defines 4 bytes duh)

; First, lets keep this organised using labels
; Note this GDT definition must be at the end of any real mode code, therefore since im doing it first to keep the train of logic clear, this file won't boot.
; I will provide a working example of this with minimal comments in the next file.
GDT_Start:
    ; At the begining of every GDT, there must be a null descriptor
    ; To define it, we will simplt fill 8 bytes with 0's:
    null_descriptor:
        dd 0
        dd 0
    
    ; Next, define the code segment descriptor which we structured earlier
    ;todo This is really confusing how it's layed out and i need to figure out why
    code_descriptor:
        ; Define the first 16 bits (2B) of the limit
        dw 0xffff   
        ; Define the first 24 bits (3B) of the base
        dw 0
        db 0
        ; Define the present, privaledge, type, and type flags  - Which together have a size of 1B
            ; Note: the '0b' suffix denotes a binary number in NASM, like how 0x denotes a hex number
        db 0b10011010
        ; Define the other flag + the last 4 bits of the limit  - 1B
        db 0b11001111
        ; Define the last 8 bits (1B) of the base
        db 0
    
    ; We do the same with the data segment descriptor, being careful to remember the changes we made from the CSD
    data_descriptor:
        dw 0xffff
        dw 0
        db 0
        ; Remember the diffences in type flags between the CSD and the DSD
        db 0b10011010
        db 0b11001111
        db 0        
GDT_End:


; Now, we need to define a GDT descriptor with 2 entries: the size of the GDT, and the start of the GDT
; Luckily, we can use our labels as pointers to help with this:
GDT_Descriptor:
    dw GDT_End - GDT_Start - 1  ; Size
    dd GDT_Start                ; Start

; Here we are just setting some constants to store the offset of the segment descriptors, relative to the GDT
CODE_SEG equ code_descriptor - GDT_Start
DATA_SEG equ data_descriptor - GDT_Start
       ; equ is used to set constants in asm


; We are now ready to switch to 32-bit protected mode.


; First, disable all interrupts by using the `cli` command
cli
; Now we can easily load the GDT using the `lgdt` command
lgdt [GDT_Descriptor]

; Now to make the actual switch, we need to change the last bit of a special 32-bit register (called cr0) to 1
; This is one of the registers we cannot access directly, so we will use a general-purpose 32-bit register to help us
; There are 4 of these: eax, ebx, ecx, edx  - where 'e' just means extended
; The 16-bit registers we've been using so far are actually just the lower half of these registers!
mov eax, cr0 
or eax, 1   ; Change the last bit to 1
mov cr0, eax


; Yayyyy! The CPU is now officially in 32-bit protected mode!!!
; Have a glass of water


; We now just need to perform a 'far jump' (i.e., a jmp to another segment)
jmp CODE_SEG:start_protected_mode

; Change the addressing mode to 32-bits
[bits 32]
start_addressing_mode:
    ; Now we can print a character to screen to check whether everything has worked
    ; Except we can't use interrupts... so how?
    ; Well we have to now write to video memory directly
    ; In text mode, video memory starts at 0xb8000
    ; We just need to write 2 adjacent bytes:
    ;   - First Byte:  character
    ;   - Second Byte: colour
    mov al, 'A'
    mov ah, 0x10 ; black on blue - https://wiki.osdev.org/Text_mode look here for more information on this
    ; Now just move ax to the begining of video memory
    mov [0xb8000], ax 

; Hopefully you can see the colourful 'A' in the top left hand corner of the terminal

