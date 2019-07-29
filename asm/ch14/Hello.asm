.MODEL small
.STACK 100h
.386

.data
message BYTE "Hello, world!", 0dh, 0ah

.code
main proc
    mov ax, @data
    mov ds, ax
    mov ah, 40h
    mov bx, 1
    mov cx, sizeof message
    mov dx, offset message
    int 21h
    .EXIT
main endp
end main