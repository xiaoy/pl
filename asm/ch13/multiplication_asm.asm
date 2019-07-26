INCLUDE Irvine32.inc

askForInteger PROTO C
showInt PROTO C, value:SDWORD, outWidth:DWORD
newLine PROTO C

OUT_WIDTH = 8
ENDING_POWER = 10

.data
intVal DWORD ?

.code
SetTextOutColor PROC C, color:DWORD
    mov eax, color
    call SetTextColor
    call Clrscr
    ret
SetTextOutColor ENDP

DisplayTable PROC C
    INVOKE askForInteger
    mov intVal, eax
    mov ecx, ENDING_POWER
L1:
    push ecx
    shl intVal, 1
    INVOKE showInt, intVal, OUT_WIDTH
    INVOKE newLine
    pop ecx
    loop L1
    ret
DisplayTable ENDP
END