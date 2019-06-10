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
; main function
push 6
call Factorial
call WriteDec
exit
main endp
;----------------------
; gave a number n, then get the result of n!
; input: stack-> n
; output: eax
;----------------------
Factorial proc
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]          ; argument n
    cmp eax, 0
    je L1 
    sub eax, 1                  ; n - 1
    push eax 
    call Factorial              ; Factorial(n-1)
    jmp L2
L1:
    mov eax, 1
    jmp L3
L2:
    mov ebx, [ebp + 8]          ; argument n
    mul ebx                     ; n * Factorial(n-1)
L3: pop ebp
    ret 4
Factorial endp
end main