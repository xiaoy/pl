include Irvine32.inc
include macros.inc
; -------------------------------------------------------------------------------------
; function DumpMem ESI->address, ECX->number of units, EBX->unit size
; function DumpRegs
; funciton MsgBox EBX->title(0 title is empty), EDX->content
; function ShowFpuStack
; function ReadFloat
; function WriteFloat
; function WriteString, EDX->address
; function WriteChar, al->char value
; function Crlf --> new line
; function Clrscr --> clear screen
; function GetMSeconds --> return millionseconds to eax
; -------------------------------------------------------------------------------------
; macro mWrite [str]
; macro mShowRegister name, register
; mShow
; 使用特定格式显示寄存器或变量名字或内容
; inputs: arg1->变量或寄存器名字
;         arg2->"HDIBN"
; H = hexadecimal
; D = unsigned decimal
; I = signed decimal
; B = binary
; N = append a newline
; 参数二的默认值为:"HIN"，此参数可以任意组合格式
; -------------------------------------------------------------------------------------
.386
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
first REAL8 123.456
second REAL8 10.0
third REAL8 ?
.code
main proc
fld first
fld second
call ShowFpuStack

mWrite "input float value:"
call ReadFloat

mWrite "input float value:"
call ReadFloat

fmul ST(0), ST(1)

mWrite "the mul ret is:"
call WriteFloat
exit
main endp
end main