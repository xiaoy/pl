ExitProcess         proto
WriteHex64          proto       ; rax as argument
Crlf                proto       ; new line
WriteString         proto       ; rdx as argument

.data
intarray QWORD 1000000000000000h, 2000000000000000h,
               3000000000000000h, 4000000000000000h
.code
main proc
    ; main function
    mov rax, 0
    mov rcx, lengthof intarray
    mov rdi, offset intarray
    L1:
        add rax, [rdi]
        add rdi, type intarray
        loop L1
    call WriteHex64
    mov ecx, 0
    call ExitProcess
main endp
end