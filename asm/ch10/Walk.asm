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

WalkMax = 50
StartX = 25
StartY = 25
DrunkardWalk STRUCT
    path COORD WalkMAX DUP(<0,0>)
    pathsUsed WORD 0
DrunkardWalk ENDS

DisplayPosition PROTO currX:WORD, currY:WORD
DrawPosition PROTO currX:WORD, currY:WORD
.data
aWalk DrunkardWalk <>
.code
main proc
; main function
call Clrscr
mov esi, offset aWalk
call TakeDrunkenWalk
mWrite "-----------------"
call Crlf
movzx eax, aWalk.pathsUsed
call WriteDec
exit
main endp
TakeDrunkenWalk PROC
    LOCAL curX:WORD, curY:WORD
    pushad
    mov ecx, WalkMAX
    mov curX, StartX
    mov curY, StartY
    mov edi, esi 
Again:
    mov ax, curX
    mov (COORD PTR [edi]).X, ax
    mov ax, curY
    mov (COORD PTR [edi]).Y, ax
    add edi, type COORD
    INVOKE DisplayPosition, curX, curY
    mov eax, 4
    call RandomRange
    ; north
    .IF eax == 0
    inc curY
    ; south
    .ELSEIF eax == 1
    dec curY
    ; west
    .ELSEIF eax == 2
    dec curX
    ;east
    .ELSE
    inc curX
    .ENDIF
    Loop Again
Finished:
    mov (DrunkardWalk PTR [esi]).pathsUsed, WalkMAX
    popad
    ret
TakeDrunkenWalk ENDP
DisplayPosition PROC currX:WORD, currY:WORD
    movzx eax, currX 
    call WriteDec
    mWrite ","
    movzx eax, currY
    call WriteDec
    call Crlf
    ret
DisplayPosition ENDP
end main