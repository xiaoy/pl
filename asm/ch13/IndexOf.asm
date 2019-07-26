.586
.model flat, c
IndexOf PROTO,
    srchVal:DWORD, arrayPtr:PTR DWORD, count:DWORD

.code
IndexOf PROC USES ecx esi edi,
    srchVal:DWORD, arrayPtr:PTR DWORD, count:DWORD
    NOT_FOUND = -1

    mov eax, srchVal
    mov ecx, count
    mov esi, arrayPtr
    mov edi, 0
L1:
    cmp [esi + edi * 4], eax
    je found
    inc edi
    loop L1
notFound:
    mov al, NOT_FOUND
    jmp short exit

found:
    mov eax, edi

exit:
    ret
IndexOf ENDP
END