;include Irvine32.inc
.586
.model flat, c
system PROTO, pComand:PTR BYTE
printf PROTO, pString:PTR BYTE, args:VARARG
scanf  PROTO, pFormat:PTR BYTE, pBuffer:PTR BYTE, args:VARARG
.data
pauseStr Byte "dir/w", 0
double1 REAL8 1234567.890123
foramtStr BYTE "%0.3f",0dh,0ah,0
str4    BYTE "%s", 0
fileName BYTE 60 DUP(0)
.code
asm_main PROC c
    INVOKE printf, ADDR foramtStr, double1
    INVOKE system, ADDR pauseStr
    ;INVOKE scanf, ADDR str4, ADDR fileName
    ret
asm_main ENDP
end