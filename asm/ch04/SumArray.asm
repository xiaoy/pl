include Irvine32.inc
include macros.inc
; -----------------
; function DumpMem
; function DumpRegs
; function ShowFpuStack
; macro mWrite [str]
; function ReadFloat
; function WriteFloat
; function Crlf --> new line
; function Clrscr --> clear screen
; -----------------
.386
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
intarray DWORD 1000h, 2000h, 3000h, 4000h

.code
main proc
mov ecx, lengthof intarray
mov esi, 0
mov eax, 0

Loop1:
    add eax, intarray[esi * sizeof DWORD]
    inc esi
    loop Loop1

call DumpRegs
exit
main endp
end main