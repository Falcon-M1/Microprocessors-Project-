        EXTRN DrawTarget:FAR
        PUBLIC X,Y,Color
.model small
.stack 64
.data
  X db 0
  Y db 15
  Color db 4h
  c1 db 5
  c2 db 2

.code
main proc far
  mov ax,@data
  mov ds,ax
  
  mov ax,0600h
  mov bh,07
  mov cx,0
  mov dx,184fh
  int 10h

  mov ah,0
  mov al,13h
  int 10h
  
  Loop1:
    mov X,0
    mov c2,2
    Loop2:
      mov Color,4h
      call DrawTarget
      add X,51
      mov Color,1h
      call DrawTarget
      add X,51
      dec c2
      jnz Loop2
    mov Color,4h
    call DrawTarget
    add Y,19
    dec c1
    jnz Loop1

  mov ah,4ch
  int 21h
  ret
main endp
end main

