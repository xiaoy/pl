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

FILE_NAME_LEN = 80
FILE_CONTENT_LEN = 512

.data
fileHandle DWORD ?
fileName BYTE FILE_NAME_LEN dup(0)
fileContent BYTE FILE_CONTENT_LEN dup(0)

.code
main proc
    ; input file name
    mWrite <"input file name:",0>
    mov ecx, FILE_NAME_LEN
    mov edx, offset fileName
    call ReadString

    ; open file
    mov edx, offset fileName
    call OpenInputFile
    mov fileHandle,eax

    ; check file open success
    cmp eax, INVALID_HANDLE_VALUE
    jne file_ok
    mWrite <"Can not open file", 0dh,0ah,0>
    jmp quit
    ; read file content
file_ok:
    mov edx, offset fileContent
    mov ecx, FILE_CONTENT_LEN
    call ReadFromFile
    jnc check_buffer_size
    mWrite "Error reading file."
    call WriteWindowsMsg
    jmp close_file
    ; check read success
check_buffer_size:
    cmp eax, FILE_CONTENT_LEN
    jb show_content
    mWrite <"the buffer can not store file content", 0dh, 0ah, 0>
    jmp close_file
    ; show content
show_content:
    mov fileContent[eax], 0
    mWrite "File size:"
    call WriteDec
    call Crlf
    mWrite <"Buffer:", 0dh, 0ah, 0dh, 0ah>
    mov edx, offset fileContent
    call WriteString
    call Crlf
close_file:
    mov eax, fileHandle
    call CloseFile
quit:
    exit
main endp
end main