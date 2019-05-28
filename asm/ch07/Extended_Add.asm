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
op1 BYTE 34h, 12h, 98h, 74h, 06h, 0A4h, 0B2h, 0A2h
op2 BYTE 02h, 45h, 23h, 00h, 00h, 87h, 10h, 80h
sum BYTE 9 dup(0)

.code
main proc
    mov esi, offset op1
    mov edi, offset op2
    mov ebx, offset sum
    mov ecx, lengthof op1
    call Extend_Sum

    mov esi, offset sum
    mov ecx, lengthof sum
    call Display_sum
exit
main endp
;----------------------------------
; sum byte array
; input: ESI-> array 1 addr
;        EDI-> array 2 addr
;        EBX-> sum array addr
;        ECX-> num of array
; output: null
;----------------------------------
Extend_Sum proc
    pushad
    clc
L1:
    mov al, [esi]
    adc al, [edi]
    mov [ebx], al
    pushfd
    inc esi
    inc edi
    inc ebx
    popfd
    loop L1
    adc byte ptr[ebx], 0

    popad
    ret
Extend_Sum endp

;----------------------------------
; dipslay array by hex
; input: esi-> source array addr
;        ecx-> source array length
; output: null
;----------------------------------
Display_sum proc
    pushad
    add esi, ecx
    mov ebx, type byte
    sub esi, type byte
L1:
    mov al, [esi]
    call WriteHexB
    sub esi, type byte
    loop L1

    popad
    ret
Display_sum endp

end main