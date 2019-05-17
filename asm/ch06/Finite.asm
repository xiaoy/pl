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

ENTER_KEY = 13
.data
InvalidInputMsg BYTE "Invalid input", 13, 10, 0

.code
; confirm input is singed value,so "+/-" is valid
main proc
StateA:
    call GetNext
    cmp al, '+'
    jz StateB
    cmp al, '-'
    jz StateB
    call IsDigit
    jz StateC
    call DisplayErrorMsg
    jmp Quit
StateB:
    call GetNext
    call IsDigit
    jz StateC
    call DisplayErrorMsg
    jmp Quit
StateC:
    call GetNext
    call IsDigit
    jz StateC
    cmp al, ENTER_KEY
    jz Quit
    call DisplayErrorMsg
Quit:
    exit
main endp
GetNext proc
    call ReadChar
    call WriteChar
    ret
GetNext endp

DisplayErrorMsg proc
    mov edx, offset InvalidInputMsg
    call WriteString
    ret
DisplayErrorMsg endp 
end main