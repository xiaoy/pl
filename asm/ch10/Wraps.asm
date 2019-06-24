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
array DWORD 1,2,3,4,5,6,7,8
firstName BYTE 31 DUP(?)
lastName BYTE 31 DUP(?)
.code
main proc
; main function
call Clrscr
mGotoxy 0, 0
mWrite <"Sample Macro Program", 0dh, 0ah>
mGotoxy 0, 5
mWrite "Please enter you first name:"
mReadString firstName
call Crlf

mWrite "Please enter you last name:"
mReadString lastName
call Crlf

mWrite "Your name is:"
mWriteString firstName
mWriteSpace
mWriteString lastName
call Crlf

mDumpMem OFFSET array, LENGTHOF array, TYPE array
exit
main endp
end main