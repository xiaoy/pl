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

BUFFER_COUNT = 512
.data
filename BYTE "output.txt",0
fileHandle DWORD ?
bytesWrite DWORD ?
buffer BYTE BUFFER_COUNT DUP(0)
.code
main proc
    mov edx, offset filename
    call CreateOutputFile
    cmp eax, INVALID_HANDLE_VALUE
    jne file_ok
    mWrite <"create falled",0dh,0ah, 0>
    jmp Quit
file_ok:
    mov fileHandle, eax
    mWrite <"create success",0dh,0ah,0>
    mWrite <"input string:">
    mov ecx, BUFFER_COUNT
    mov edx, offset buffer
    call ReadString
    mov ecx, eax
    mov eax, fileHandle
    mov edx, offset buffer
    call WriteToFile
    mov bytesWrite, eax 
    mov eax, fileHandle
    call CloseFile

    mWrite <"Bytes written:">
    mov eax, bytesWrite
    call WriteDec
    call Crlf 
Quit:
    exit
main endp
end main