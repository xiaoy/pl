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
; -----------------
.386
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
TAB = 9

.code
main proc
    call Randomize
    call Rand1
    call Rand2
exit
main endp
Rand1 proc 
    mov ecx, 10
L1:
    call Random32
    call WriteDec
    mov al, TAB
    call WriteChar
    loop L1
    ret
Rand1 endp

Rand2 proc
    mov ecx, 10
L1:
    mov eax, 100
    call RandomRange
    sub eax, 50
    call WriteInt
    mov al, TAB
    call WriteChar
    loop L1
    call Crlf
    ret
Rand2 endp
end main