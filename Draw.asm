       EXTRN X:BYTE
       EXTRN Y:BYTE
       EXTRN Color:BYTE
       PUBLIC DrawTarget
.model small
.code
DrawTarget proc far
  mov cl,X
  mov dl,Y
  mov al,Color
  mov ah,0ch
  mov bl,18
  mov bh,50
  Loop1:
    mov bh,50
    mov cl,X
    Loop2:
      int 10h
      inc cx
      dec bh
      jnz Loop2
    inc dx
    dec bl
    jnz Loop1
  ret     
DrawTarget endp
END 