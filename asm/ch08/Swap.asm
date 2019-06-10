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
Swap proto, pXval:ptr dword, pYval:ptr dword

.data
wordArr dword 1000h, 2000h

.code
main proc
    mov esi, offset wordArr
    mov ecx, lengthof wordArr 
    mov ebx, type wordArr 
    call DumpMem
    INVOKE Swap, ADDR wordArr, ADDR [wordArr + 4]

    call DumpMem
exit
main endp
;-------------------------
;swap two value at two diffent address
;input: pXval -> the first value address
;       pYval -> the second value address
; output:nothing
Swap PROC uses eax esi edi,
          pXval:ptr dword,
          pYval:ptr dword
          mov esi, pXval
          mov edi, pYval
          mov eax, [esi]
          xchg eax, [edi]
          mov [esi], eax
          ret
Swap ENDP
end main