


; So far we have been working in Real Mode
; Real mode is a legacy mode that is used primarily for bootloaders
; Once our bootloading is finished, we will switch to protected or long mode

; In Real Mode we are working with 16-bit addressing
; This means we can only access 2^16 memory locations
; Which is equal to 65536 Bytes (or 64 KiB)
; This isn't a lot and so we need to be able to reach different parts of the memory.
; This is why we introduce segmentation.

; Segmentation splits the memory into different segments, each with a maximum size of 64 KiB so that we can reference the whole segment
; There are many segments, but the 3 we care about right now are the Data, Code, and Stack segments.
; It comes as no surprise that the data is stored in the data segment, instructions in the code segment, and stack in stack.
; For each of these we have a segment register: ds, cs, and ss respectively.
;       Note: there is also an extra segment register (es) and we will be using that soon
; The segment registers will point to the physical address of the base of the segment.

; The physical address of any memory location we want to access could be well above 64 KiB
; This is why we need the segment registers.
; For example, to represent the memory location of the physical address 75200 in the data segment we use this equation:
; 75200 = 16 * ds + offset, where offset is just the difference between the physical address and ds (i.e., the distance from the segment base to the target)
; This equation is represented by this notation: 75200 = ds : offset
; So in this example the hard numbers would be 75200 = 800 : 62400
; More generally we can write:
;       physical_address = 16 * segment_register + offset
;       physical_address = segment_register : offset
; This increases the amount of memory we can access by 16 times - becoming a bit over a megabyte

; We have actually used this concept already, just without realising:

variablePointer:
    db "Hello World!", 0

mov 0x0e
mov al, [variablePointer]
int 0x10
; In the above code [variablePointer] is actually internally assessed as [ds : variablePointer] since variables are stored in the data segment
; However, in this case ds was 0, so the physical address = 16 * 0 + variablePointer, so the address really was just variablePointer

; This means another way set the origin of our data segement memory addressing is to move ds to 0x7c0
mov ds, 0x7c0
; This works as 0x7c0 * 16 = 0x7c00 which is the origin we need to avoid conflicts with our interrupt look up table
; I.e., mov ds, 0x7c0 is functionally identical to [org 0x7c00]


; This also means that when we use the stack, the physical address of the base isn't bp, but is actually ss:bp


; Since we are going to be spending so little time in real mode, we can use the 'Tiny Memory Model' to simplify things
; In this we will set all the segment registers to 0, meaning all 3 segments will occupy the same space in memory
; This will again restrict us back to 64 KiB but since we won't be doing much in real mode this is acceptable
