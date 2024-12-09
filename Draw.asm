       EXTRN X:BYTE
       EXTRN Y:BYTE
       EXTRN Color:BYTE
       EXTRN BallX:BYTE
       EXTRN BallY:BYTE
       EXTRN BallColor:BYTE
       EXTRN PaddleX:BYTE
       EXTRN PaddleY:BYTE
       EXTRN PaddleColor:BYTE
       PUBLIC DrawTarget
       PUBLIC DrawBall
       PUBLIC DrawPaddle
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


DrawBall proc far
  mov cl,BallX
  mov dl,BallY
  mov al,BallColor
  mov bl,7
  mov dh,5
  LoopB1:
    mov bh,7
    mov cl,BallX
    LoopB2:
      int 10h
      inc cl
      dec bh
      jnz LoopB2
    inc dl
    dec bl
    jnz LoopB1
  ret
DrawBall endp

DrawPaddle proc far
  mov cl,PaddleX
  mov dl,PaddleY
  mov al,PaddleColor
  mov bl,7
  mov dh,5
  LoopP1:
    mov bh,55
    mov cl,PaddleX
    LoopP2:
      int 10h
      inc cl
      dec bh
      jnz LoopP2
    inc dl
    dec bl
    jnz LoopP1
  ret
DrawPaddle endp
END 