
; Jumps to the current memory address
jmp $

/* 
A boot sector is always bytes (i.e., assembly lines) long. 

Therefore this command 'define byte 0's the exact number of times needed to get to 510 lines 
- (i.e., makes it so that every blank line is actually just 0 up to 510 lines).

This is done as $ = current address, and $$ = section start address,
therefore $ - $$ = the number of lines of code before this one.
*/
times 510-($-$$) db 0
; The last 2 lines in a boot sector are always 0x55 0xaa, therefore we db them at the end.
; 0x is simply a prefix, stating that the following number is in hexadecimal
db 0x55, 0xaa