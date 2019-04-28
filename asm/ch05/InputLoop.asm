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
; -----------------

; Library Test #1: Integer I/O (InputLoop.asm)
; Tests the Clrscr, Crlf, DumpMem, ReadInt, SetTextColor,
; WaitMsg, WriteBin, WriteBin, and WriteString procedures.

.386
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
COUNT = 4
BlueTextOnGray = blue + (lightGray * 16)
DefaultColor = lightGray + (black * 16)
arrayD SDWORD 12345678h, 1A4B2000h, 3434h, 7AB9h
prompt BYTE "Enter a 32-bit signed integer: ", 0

.code
main proc
; Select blue text on a light gray background
mov eax, BlueTextOnGray
call SetTextColor
call Clrscr

; Dispaly an array using DumpMem
mov esi, offset arrayD
mov ecx, lengthof arrayD
mov ebx, type arrayD
call DumpMem

; Ask the user to input a sequence of signed integers
call Crlf
mov ecx, COUNT

L1:
    mov edx, offset prompt
    call WriteString
    call ReadInt
    call Crlf

    ; display the integer in decimal, heaxadecimal, and binary
    call WriteInt
    call Crlf

    call WriteHex
    call Crlf

    call WriteBin
    call Crlf
    call Crlf
    loop L1

; return the console windows to default colors
call WaitMsg
mov eax, DefaultColor
call SetTextColor
call Clrscr
exit
main endp
end main