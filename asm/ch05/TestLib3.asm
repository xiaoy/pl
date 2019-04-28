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
OUTER_LOOP_COUNT = 3
startTime DWORD ?
msg1 BYTE "Please wait ...", 0dh, 0ah, 0
msg2 BYTE "Elapsed milliseconds: ",0

.code
main proc
    mov edx, OFFSET msg1
    call WriteString

    ; Save the starting time
    call GetMSeconds
    mov startTime, eax
    ; Start the outer loop
    mov ecx, OUTER_LOOP_COUNT
L1:
    call innerLoop
    loop L1

    ; Calculate the elapsed time
    call GetMSeconds
    sub eax, startTime

    ; Display the elapsed time
    mov edx, OFFSET msg2
    call WriteString
    call WriteDec
    call Crlf
exit
main endp
innerLoop proc
    push ecx
    mov ecx, 0FFFFFFFFh
L1:
    mul eax
    mul eax
    mul eax
    loop L1
    pop ecx
    ret
innerLoop endp
end main