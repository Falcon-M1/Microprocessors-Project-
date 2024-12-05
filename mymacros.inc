DrawTarget MACRO X,Y,Color
  local Loop1,Loop2
  mov cx,X
  mov dx,Y
  mov al,Color
  mov ah,0ch
  mov bl,18
  mov bh,50
  Loop1:
    mov bh,50
    mov cx,X
    Loop2:
      int 10h
      inc cx
      dec bh
      jnz Loop2
    inc dx
    dec bl
    jnz Loop1
      
    

ENDM DrawTarget 