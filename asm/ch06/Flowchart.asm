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
array   dword 10, 60, 20, 33, 72, 89, 45, 65, 72, 18
sample  dword 50
.code
main proc
    mov ecx, lengthof array                         ; arraySize
    mov edx, 0                                      ; index
    mov eax, 0                                      ; sum
beginwhile:
    cmp edx, ecx                                    ; index, arraySize
    jae endwhile                                    ; if index >= arraySize, jmp endwhile
    mov ebx, array[edx * type array]
    cmp ebx, sample                                 ; array[index], sample
    jbe L1                                          ; jmp to L1
    add eax, array[edx * type array]                ; sum += array[index]
L1:
    inc edx
    jmp beginwhile
endwhile:
call DumpRegs
exit
main endp
end main