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
CaseTable BYTE 'A'
          DWORD Process_A
EntrySize = ($ - CaseTable)
          BYTE 'B'
          DWORD Process_B
          BYTE 'C'
          DWORD Process_C
          BYTE 'D'
          DWORD Process_D
NumberOfEntries = ($ - CaseTable) / EntrySize
prompt BYTE "Press capital A, B, C or D: ", 0
msgA   BYTE "Process_A", 0
msgB   BYTE "Process_B", 0
msgC   BYTE "Process_C", 0
msgD   BYTE "Process_D", 0

.code
main proc
    mov edx, offset prompt
    call WriteString
    call ReadChar
    mov ecx, NumberOfEntries
    mov esi, offset CaseTable
L1:
    cmp al, [esi] 
    jne L2
    call near ptr[esi + 1]
    call WriteString
    jmp L3 
L2:
    add esi, EntrySize
    loop L1
L3:
exit
main endp
Process_A proc
    mov edx, offset msgA
    ret
Process_A endp
Process_B proc
    mov edx, offset msgB
    ret
Process_B endp
Process_C proc
    mov edx, offset msgC
    ret
Process_C endp
Process_D proc
    mov edx, offset msgD
    ret
Process_D endp
end main