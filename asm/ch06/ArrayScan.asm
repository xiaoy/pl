include Irvine32.inc
include macros.inc
; -----------------
; function DumpMem ESI->address, ECX->number of units, EBX->unit size
; function DumpRegs
; funciton MsgBox EBX->title(0 title is empty), EDX->content
; function ShowFpuStack
; macro mWrite [str]
; function ReadFloat
; function WriteFloat
; function WriteString, EDX->address
; function WriteChar, al->char value
; function Crlf --> new line
; function Clrscr --> clear screen
; function GetMSeconds --> return millionseconds to eax
; -----------------
.386
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
word_arr word 0, 0, 0, 0, -1, 12
;word_arr word 0, 5, 0, 0, -1, 12
;word_arr word 0, 0, 0, 0, 8, 12
.code
main proc
    mov esi, offset word_arr
    mov ecx, lengthof word_arr
L1: cmp word ptr [esi], 0
    jnz find 
    add esi, 2
    loop L1
    jmp not_find
find:
    movsx eax, word ptr [esi]
    call WriteInt
    jmp over
not_find:
    mWrite "A non-zero value was not fond", 0
over:
    exit
main endp
end main