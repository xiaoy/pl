ExitProcess         proto
WriteHex64          proto       ; rax as argument
WriteInt64          proto       ; rax
Crlf                proto       ; new line
WriteString         proto       ; rdx as argument

.data
line_str byte "--------------------", 0
.code
main proc
    ; main function
    sub rsp, 8
    sub rsp, 20h

    mov rcx, 1
    mov rdx, 2
    mov r8, 3
    mov r9, 4

    call AddFour
    call WriteInt64

    mov ecx, 0
    call ExitProcess
main endp
AddFour proc
    mov rax, rcx
    add rax, rdx
    add rax, r8
    add rax, r9
    ret
AddFour endp

ShowRsp proc
    mov rdx, offset line_str
    call WriteString
    call Crlf
    mov rax, rsp
    call WriteHex64
    call WriteString
    call Crlf
    ret
ShowRsp endp
end