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
sysTime SYSTEMTIME <>
XYPos COORD <10, 5>
consoleHandle DWORD ?

.code
main proc
call Clrscr
INVOKE GetStdHandle, STD_OUTPUT_HANDLE
mov consoleHandle, eax

INVOKE SetConsoleCursorPosition, consoleHandle, XYPos
INVOKE GetLocalTime, addr sysTime
movzx eax, sysTime.wHour
call WriteDec
mWrite ":"
movzx eax, sysTime.wMinute
call WriteDec
mWrite ":"
movzx eax, sysTime.wSecond
call WriteDec
call Crlf
call WaitMsg
exit
main endp
end main