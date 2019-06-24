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

mCalc_row_sum MACRO index, arrayOffset, rowSize, eltType
; calculates the sum of a row in a two-dimensional array.
;
; receives:row index, offset of the array, number of bytes
; in each batle row, and the array type(byte, word, or dword)
; returns: EAX = sum.
    LOCAL L1
    push ebx
    push ecx
    push esi

    mov eax, index
    mov ecx, rowSize
    mov ebx, arrayOffset

    mul ecx
    add ebx, eax
    mov esi, 0 
    mov eax, 0

    shr ecx, (type eltType) / 2     ; address add 1 byte by one byte

L1:
    IFIDNI <eltType>, <DWORD>
        mov edx, eltType ptr [ebx + esi * type eltType]
    ELSE
        movzx edx, eltType ptr [ebx + esi * type eltType]
    ENDIF
    inc esi
    add eax, edx
    LOOP L1

    pop esi
    pop ecx
    pop ebx
ENDM
.data
tableB      BYTE    10h,    20h,    30h,    40h,    50h
RowSizeB    = ($ - tableB)
            BYTE    60h,    70h,    80h,    90h,    0AH
            BYTE    0B0h,   0C0h,   0D0h,   0E0h,   0F0h

tableW      WORD    10h,    20h,    30h,    40h,    50h
RowSizeW    = ($ - tableW)
            WORD    60h,    70h,    80h,    90h,    0AH
            WORD    0B0h,   0C0h,   0D0h,   0E0h,   0F0h

tableD      DWORD   10h,    20h,    30h,    40h,    50h
RowSizeD    = ($ - tableD)
            DWORD   60h,    70h,    80h,    90h,    0AH
            DWORD   0B0h,   0C0h,   0D0h,   0E0h,   0F0h
.code
main proc
mCalc_row_sum 2, offset tableB, RowSizeB, BYTE
call WriteHex
call Crlf
mCalc_row_sum 2, offset tableW, RowSizeW, WORD 
call WriteHex
call Crlf
mCalc_row_sum 2, offset tableD, RowSizeD, DWORD 
call WriteHex
call Crlf
exit
main endp
end main