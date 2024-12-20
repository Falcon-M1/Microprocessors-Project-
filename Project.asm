.Model small
.stack 64

.data
    ;adjust those numbers if required

    ;screen info
    Xstart         db 0
    Ystart         db 0
    Xend           dw 319
    Yend           db 199

    ;player paddle info
    Paddlex1       dw 140
    Paddlex2       dw 180
    paddley1       dw 194
    paddley2       dw 199
    PaddleSpeed    dw 3
    PaddleW        dw 41
    PaddleH        dw 6
    Paddlemid      dw 20

    ;ball  info
    vx             dw 0
    vy             dw 1
    ballIsMoving   db 0
    ballx1         dw 158
    bally1         dw 188
    ballx2         dw 162
    bally2         dw 192
    ballSlow       dw 2000
    ballSize       db 5
    ballmid        dw 2

    ;Bricks info 23(brick) 10(space)
    brickW         dw 23
    brickH         dw 12
    SpaceinBetween dw 10
    BricksCount    dw 40
    IsDestroied    db 40 Dup(0),'$'                                                                        ;(isdestroied1,isdestroied2,isdestroied3,....,isdestroiedn,'$')
    brickXY        dw 0,0
    ;(x0,y0)

    ;Game status
    lives          dw 3
    needrestart    db 0
    result         db ?                                                                                    ; 1 win, 0 lose
    WiningMessage  db "You win!","$"
    LosingMessage  db "You lost!","$"
    RestartMessage db "Press r to restart or any other key to exit ",10,13,"$"
    StartMessage   db "Press s for single player mode and any other key for multiplayer mode",10,13,"$"
    NewLine        db 10,13,"$"
.code
Main proc far
                    mov   ax, @DATA
                    mov   ds,ax

                    mov   ah, 9
                    mov   dx, offset StartMessage
                    int   21h

                    mov   ah,0
                    int   16h
                    cmp   al, 73h
                    jnz   Multiplayer

    SinglePlayer:   
                    call  GraphicsMode
                    call  DrawBricks

    restart:        
                    mov   needrestart,0
                    call  DrawPaddle
                    call  SetBallValues
                    call  DrawBall


    ReadInput:      
                    mov   ah, 01h
                    int   16h
                    jz    noKey
                    mov   ah, 00h
                    int   16h                          ;the input now in al do what u want
        
       
    ;moving the paddle
                    mov   cx,PaddleSpeed
                    cmp   al,97
                    je    molf
                    cmp   al,100
                    je    mort
        
    noKey:          
                    call  MoveBall
                    cmp   needrestart,1
                    je    restart



                    jmp   ReadInput                    ; Continue checking for input

    molf:           
    l:              call  Moveleft
                    dec   cx
                    jnz   l
                    jmp   noKey
    mort:           
    r:              call  Moveright
                    dec   cx
                    jnz   r
                    jmp   noKey
    
    Waiting:        
                    mov   ah,07h
                    int   21h
    Multiplayer:    
    ; add multiplayer mode here

    exit:           
                    mov   ah, 4ch
                    int   21h
Main Endp


GraphicsMode proc
                    push  ax
                    mov   ah,0h
                    mov   al,13h
                    int   10h
                    pop   ax
                    RET
GraphicsMode Endp

DrawPaddle proc
                    push  cx
                    push  dx
                    push  ax
                    mov   cx,Paddlex1
    LoopOnX:        
                    mov   dx,Paddley1
    LooponY:        
                    mov   al,04h
                    mov   ah,0ch
                    int   10h                          ;pix(cx,dx) = color
                    inc   dx
                    cmp   dx,Paddley2
                    jbe   LooponY
                    inc   cx
                    cmp   cx,Paddlex2
                    jbe   LoopOnX
                    mov   ballIsMoving,0
                    pop   ax
                    pop   dx
                    pop   cx
                    RET
DrawPaddle Endp



Moveleft proc
                    cmp   Paddlex1,0
                    je    returnr
    
                    push  cx
                    push  dx
    
    ;remove the old part
                    mov   cx,Paddlex2
                    mov   dx,Paddley1

    delYr:          
                    mov   al,00h
                    mov   ah,0ch
                    int   10h                          ;pix(cx,dx) = color
                    inc   dx
                    cmp   dx,Paddley2
                    jbe   delYr
   
    ;new paddle coordinanets
                    dec   Paddlex1
                    dec   Paddlex2
   
    ;draw the new part
                    mov   cx,Paddlex1
                    mov   dx,Paddley1

    drwYr:          
                    mov   al,04h
                    mov   ah,0ch
                    int   10h                          ;pix(cx,dx) = color
                    inc   dx
                    cmp   dx,Paddley2
                    jbe   drwYr

                    pop   dx
                    pop   cx

    returnr:        RET
Moveleft Endp

Moveright proc
                    cmp   Paddlex2,319
                    je    returnl
    
                    push  cx
                    push  dx
                    push  ax

    ;remove the old part
                    mov   cx,Paddlex1
                    mov   dx,Paddley1

    delYl:          
                    mov   al,00h
                    mov   ah,0ch
                    int   10h                          ;pix(cx,dx) = color
                    inc   dx
                    cmp   dx,Paddley2
                    jbe   delYl
   
    ;new paddle coordinanets
                    inc   Paddlex1
                    inc   Paddlex2
   
    ;draw the new part
                    mov   cx,Paddlex2
                    mov   dx,Paddley1

    drwYl:          
                    mov   al,04h
                    mov   ah,0ch
                    int   10h                          ;pix(cx,dx) = color
                    inc   dx
                    cmp   dx,Paddley2
                    jbe   drwYl

                    pop   ax
                    pop   dx
                    pop   cx

    returnl:        RET
Moveright Endp

MoveBall proc
                    push  cx
                    push  dx
                    dec   ballSlow
                    jnz   skipball
                    mov   ballslow,2000
                    mov   cx,vx
                    mov   dx,vy
                    call  DeleteBall
                    add   ballx1,cx
                    add   ballx2,cx
                    add   bally1,dx
                    add   bally2,dx
                    call  DrawBall
                    call  BallColliding
    skipball:       
                    pop   dx
                    pop   cx
                    RET
MoveBall Endp
                    


DrawBall proc
                    push  cx
                    push  dx
                    push  ax
                    mov   cx,ballx1
    drawballx:      
                    mov   dx,bally1
    drawbally:      
                    mov   al,0Fh
                    mov   ah,0ch
                    int   10h
                    inc   dx
                    cmp   dx,bally2
                    jbe   drawbally
                    inc   cx
                    cmp   cx,ballx2
                    jbe   drawballx
                    pop   ax
                    pop   dx
                    pop   cx
                    RET
DrawBall Endp

DeleteBall proc
                    push  cx
                    push  dx
                    push  ax
                    mov   cx,ballx1
    deleteballx:    
                    mov   dx,bally1
    deletebally:    
                    mov   al,00h
                    mov   ah,0ch
                    int   10h
                    inc   dx
                    cmp   dx,bally2
                    jbe   deletebally
                    inc   cx
                    cmp   cx,ballx2
                    jbe   deleteballx
                    pop   ax
                    pop   dx
                    pop   cx
                    RET
DeleteBall Endp

BallColliding proc
                    push  ax
                    push  cx
                    push  dx
    
    losing:         
                    mov   ax,bally2
                    cmp   ax,paddley1
                    jbe   paddleCheck
                    sub   lives,1
                    call  AreNoLives
                    mov   needrestart,1
                    jmp   ColideFound

    paddleCheck:    
                    mov   ax,ballx1
                    cmp   ax,paddlex2
                    ja    leftWallCheck
                    mov   ax,ballx2
                    cmp   ax,paddlex1
                    jb    leftWallCheck
                    mov   ax,bally2
                    add   ax,1
                    cmp   ax,paddley1
                    jb    leftWallCheck
                    mov   vy,-1
        
                    mov   dx,ballx1
                    add   dx,ballmid
                    mov   cx,Paddlex1
                    add   cx,Paddlemid
                    cmp   dx,cx
                    je    EqualBallPaddle
                    ja    ApoveBallPaddle
                    jb    BelowBallPaddle

    EqualBallPaddle:
                    mov   vx,0
                    jmp   ColideFound

    ApoveBallPaddle:
                    mov   vx,1
                    jmp   ColideFound

    BelowBallPaddle:
                    mov   vx,-1
                    jmp   ColideFound


    leftWallCheck:  
                    cmp   ballx2,319
                    jb    rightWallCheck
                    mov   vx,-1
                    jmp   ColideFound

    rightWallCheck: 
                    cmp   ballx1,0
                    ja    upperWallCheck
                    mov   vx,1
                    jmp   ColideFound

    upperWallCheck: 
                    cmp   bally1,0
                    ja    BricksCheck
                    mov   vy,1
                    jmp   ColideFound

    BricksCheck:    
                    call  BricksColliding

    ColideFound:    
                    pop   dx
                    pop   cx
                    pop   ax
                    RET
BallColliding Endp


SetBallValues proc
                    mov   vy,1
                    mov   ballx1,158
                    mov   bally1,188
                    mov   ballx2,162
                    mov   bally2,192
                    RET
SetBallValues Endp

DrawBricks proc                                        ;(23,9)
                    push  ax
                    push  dx
                    push  cx
                    push  bx
    
                    mov   cx,0
                    mov   ax,0h
                    mov   bx,0h
    BricksX:        
                    mov   dx,0
    BricksY:        
                    push  ax
                    add   cx,ax
                    add   dx,bx
                    mov   al,09h
                    mov   ah,0ch
                    int   10h                          ;pix(cx,dx) = color
                    pop   ax
                    sub   cx,ax
                    sub   dx,bx
                    inc   dx
                    cmp   dx,11
                    jbe   BricksY
                    inc   cx
                    cmp   cx,23
                    jbe   BricksX
                    add   ax,33
                    mov   cx,0
                    cmp   ax,320
                    jb    ContinueBricks
                    mov   ax,0
                    add   bx,20
    ContinueBricks: 
                    cmp   bx,80
                    jne   BricksX
        


                    pop   bx
                    pop   cx
                    pop   dx
                    pop   ax
                    RET
DrawBricks Endp

FinishGame proc
                    cmp   result,0
                    jnz   win
    lose:           
                    mov   bh, 0                        ; Set display page to 0
                    mov   al, 0                        ; Black color

    ; Outer loop for Y-coordinates
                    mov   dx, 0                        ; Start Y-coordinate at 0
    DrawRows1:      
                    cmp   dx, 200                      ; If Y-coordinate >= 200, we're done
                    jge   LosingDone

    ; Inner loop for X-coordinates
                    mov   cx, 0                        ; Start X-coordinate at 0
    DrawColumns1:   
                    cmp   cx, 320                      ; If X-coordinate >= 320, go to next row
                    jge   NextRow1

    ; Draw pixel at (CX, DX) with color AL (black)
                    mov   ah, 0Ch                      ; BIOS function: Write Pixel
                    int   10h                          ; Call BIOS interrupt

                    inc   cx                           ; Increment X-coordinate
                    jmp   DrawColumns1                 ; Repeat for the next pixel in the row

    NextRow1:       
                    inc   dx                           ; Increment Y-coordinate
                    jmp   DrawRows1                    ; Repeat for the next row



    win:            
                    mov   bh, 0                        ; Set display page to 0
                    mov   al, 0                        ; Black color

    ; Outer loop for Y-coordinates
                    mov   dx, 0                        ; Start Y-coordinate at 0
    DrawRows2:      
                    cmp   dx, 200                      ; If Y-coordinate >= 200, we're done
                    jge   WiningDone

    ; Inner loop for X-coordinates
                    mov   cx, 0                        ; Start X-coordinate at 0
    DrawColumns2:   
                    cmp   cx, 320                      ; If X-coordinate >= 320, go to next row
                    jge   NextRow2

    ; Draw pixel at (CX, DX) with color AL (black)
                    mov   ah, 0Ch                      ; BIOS function: Write Pixel
                    int   10h                          ; Call BIOS interrupt

                    inc   cx                           ; Increment X-coordinate
                    jmp   DrawColumns2                 ; Repeat for the next pixel in the row

    NextRow2:       
                    inc   dx                           ; Increment Y-coordinate
                    jmp   DrawRows2                    ; Repeat for the next row

    LosingDone:     
    ; Return to text mode or exit
                    mov   ah, 0                        ; Set video mode
                    mov   al, 03h                      ; Text mode 3 (80x25)
                    int   10h                          ; Call BIOS interrupt
                    mov   ah, 02h                      ; Set Cursor Position function
                    mov   bh, 0                        ; Display page 0
                    mov   dh, 0                        ; Middle row (12th row)
                    mov   dl, 0                        ; Middle column (40th column)
                    int   10h                          ; Call BIOS interrupt
    ; Display string
                    lea   si, LosingMessage            ; Load address of the string
                    mov   bh, 0                        ; Display page 0
                    mov   bl, 04h                      ; Red text on black background

    PrintLoop1:     
                    lodsb                              ; Load next character from the string
                    cmp   al, "$"                      ; Check for null terminator
                    je    LDone                        ; If null, end loop

    ; Write the character with attribute
                    mov   ah, 09h                      ; Write Character and Attribute function
                    mov   cx, 1                        ; Write character once
                    int   10h                          ; Call BIOS interrupt

    ; Move cursor to next position
                    inc   dl                           ; Increment column
                    cmp   dl, 80                       ; Check if column exceeds screen width
                    jl    UpdateCursor1                ; If not, update cursor
                    mov   dl, 0                        ; Reset column to 0
                    inc   dh                           ; Move to the next row
                    cmp   dh, 25                       ; Check if row exceeds screen height
                    jl    UpdateCursor1                ; If not, update cursor
                    jmp   LDone                        ; End if screen is full

    UpdateCursor1:  
                    mov   ah, 02h                      ; Set Cursor Position function
                    int   10h                          ; Call BIOS interrupt
                    jmp   PrintLoop1                   ; Repeat for the next character
    LDone:          
                    mov   ah, 9
                    mov   dx, offset NewLine
                    int   21h
                    mov   ah, 9
                    mov   dx, offset RestartMessage
                    int   21h
                    mov   ah,0
                    int   16h
                    cmp   al,72h                       ; restart
                    jnz   ext
                    mov   lives,3
                    call  Main
    WiningDone:     
    ; Return to text mode or exit
                    mov   ah, 0                        ; Set video mode
                    mov   al, 03h                      ; Text mode 3 (80x25)
                    int   10h                          ; Call BIOS interrupt
                    mov   ah, 02h                      ; Set Cursor Position function
                    mov   bh, 0                        ; Display page 0
                    mov   dh, 0                        ; Middle row (12th row)
                    mov   dl, 0                        ; Middle column (40th column)
                    int   10h                          ; Call BIOS interrupt
    ; Display string
                    lea   si, WiningMessage            ; Load address of the string
                    mov   bh, 0                        ; Display page 0
                    mov   bl, 02h                      ; Green text on black background

    PrintLoop2:     
                    lodsb                              ; Load next character from the string
                    cmp   al, "$"                      ; Check for null terminator
                    je    WDone                        ; If null, end loop

    ; Write the character with attribute
                    mov   ah, 09h                      ; Write Character and Attribute function
                    mov   cx, 1                        ; Write character once
                    int   10h                          ; Call BIOS interrupt

    ; Move cursor to next position
                    inc   dl                           ; Increment column
                    cmp   dl, 80                       ; Check if column exceeds screen width
                    jl    UpdateCursor2                ; If not, update cursor
                    mov   dl, 0                        ; Reset column to 0
                    inc   dh                           ; Move to the next row
                    cmp   dh, 25                       ; Check if row exceeds screen height
                    jl    UpdateCursor2                ; If not, update cursor
                    jmp   WDone                        ; End if screen is full

    UpdateCursor2:  
                    mov   ah, 02h                      ; Set Cursor Position function
                    int   10h                          ; Call BIOS interrupt
                    jmp   PrintLoop2                   ; Repeat for the next character
    WDone:          
                    mov   ah, 9
                    mov   dx, offset NewLine
                    int   21h
                    mov   ah, 9
                    mov   dx, offset RestartMessage
                    int   21h
                    mov   ah,0
                    int   16h
                    cmp   al,72h                       ; restart
                    jnz   ext
                    mov   lives,3
                    call  Main
    ext:            
                    mov   ah, 4ch
                    int   21h
                    RET
FinishGame Endp

AreNoLives proc
                    cmp   lives,0
                    jnz   return
                    mov   result,0
                    call  FinishGame
    return:         
                    RET
AreNoLives Endp

BricksColliding proc
                    RET
BricksColliding Endp

End Main

