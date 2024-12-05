include mymacros.inc
.model small
.stack 64
.data
  X dw 0
  Y dw 15
  red db 4h
  blue db 1h
  c1 db 5
  c2 db 3

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
    mov c2,3
    Loop2:
      DrawTarget X,Y,red
      add X,51
      DrawTarget X,Y,blue
      add X,51
      dec c2
      jnz Loop2
    add Y,19
    dec c1
    jnz Loop1

  mov ah,4ch
  int 21h
  ret
main endp
end main

