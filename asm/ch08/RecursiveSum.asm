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

.code
main proc
    mov ecx, 6
    mov eax, 0
    call CalcSum
L1: call WriteDec
exit
main endp
CalcSum proc
; ---------------------
; sum of value from 1....n
; input: ecx->n
; output: eax-> sum
; ---------------------
    cmp ecx, 0
    je L2
    add eax, ecx
    dec ecx
    call CalcSum
L2:
    ret
CalcSum endp
end main