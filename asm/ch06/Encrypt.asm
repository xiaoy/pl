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

KEY = 239
BUFMAX = 128

.data
sPrompt         BYTE "Enter the plain text:", 0
sEncryptByte    BYTE "Cipher text:          ",0
sDecrypt        BYTE "Decrypted:            ",0
buffer          BYTE BUFMAX + 1 DUP(0)
bufSize         DWORD ?

.code
main proc
call ReadBuffer

call TransferByte
mov edx, offset sEncryptByte
call OutPutBuffer

call TransferByte
mov edx, offset sDecrypt 
call OutPutBuffer

exit
main endp

; Prompts user for a plaintext string. save the string and it's length
; input:  none 
; return: none 
ReadBuffer proc uses edx ecx eax
    pushad
    mov edx, offset sPrompt
    call WriteString
    mov edx, offset buffer
    mov ecx, BUFMAX + 1
    call ReadString
    mov bufSize, eax
    popad
    ret
ReadBuffer endp

; print a give string and buffer content
; inptut: edx->output string address
; return: none
OutPutBuffer proc uses edx
    pushad
    call WriteString
    mov edx, offset buffer
    call WriteString
    call Crlf
    popad
    ret
OutPutBuffer endp

; xor a byte arr
; input: none
; output: none
TransferByte proc uses ecx esi
    pushad
    mov ecx, bufSize
    mov esi, offset buffer
    L1: xor byte ptr[esi], key 
        inc esi
        loop L1
    popad
    ret
TransferByte endp
end main