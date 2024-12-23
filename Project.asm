.Model small
.stack 64

.data
;adjust those numbers if required

;screen info
Xstart db 0
Ystart db 0
Xend dw 319
Yend db 199

;player paddle info
Paddlex1 dw 140
Paddlex2 dw 180
paddley1 dw 194
paddley2 dw 199
PaddleSpeed dw 3
PaddleW dw 41
PaddleH dw 6
Paddlemid dw 20

;ball  info
vx dw 0
vy dw 0
ballIsMoving db 0
ballx1 dw 158
bally1 dw 188
ballx2 dw 162
bally2 dw 192
ballSlow dw 500
ballSize db 5
ballmid dw 2

;Bricks info 23(brick) 10(space)
brickW dw 23
brickH dw 12
WSpace dw 10
HSpace dw 8
Score db '0','0','$'
BricksCount dw 40
IsDestroied db 40 Dup(0),'$' ;(isdestroied1,isdestroied2,isdestroied3,....,isdestroiedn,'$')
brickXY dw 0,0
        ;(x0,y0)

;Game status
lives dw 3
needrestart db 0
LossMessage     DB 0AH, 0DH, "     ==============================      "
                DB 0AH, 0DH, "     ==============================      "
                DB 0AH, 0DH, "     ====     YOU LOST! :(     ====      "
                DB 0AH, 0DH, "     ==============================      "
                DB 0AH, 0DH, "     ==============================      $"

winMessage      DB 0AH, 0DH, "     ==============================      "
                DB 0AH, 0DH, "     ==============================      "
                DB 0AH, 0DH, "     ====     3ash You Won! :)  ===      "
                DB 0AH, 0DH, "     ==============================      "
                DB 0AH, 0DH, "     ==============================      $"
;random
color db 2

.code
Main proc; Improved code for BricksColliding procedure


    mov ax,@DATA
    mov ds,ax

    call GraphicsMode
    call DrawBricks



    restart:
        call DeleteBall
        mov needrestart,0
        call DrawPaddle
        call SetBallValues
        call DrawBall


    ReadInput:

        cmp lives,0
        je lost
        cmp BricksCount,0
        je win

        mov ah, 01h         
        int 16h     
        jz noKey
        mov ah, 00h        
        int 16h  ;the input now in al do what u want
        
       
        ;moving the paddle
        mov cx,PaddleSpeed
        cmp al,97
        je molf
        cmp al,100
        je mort
        cmp al,20h
        mov vy,1

        noKey:
        call MoveBall
        cmp needrestart,1
        je restart

        call UpdateScore

        jmp ReadInput      ; Continue checking for input

    molf: 
        l: call Moveleft
           dec cx
           jnz l
        jmp noKey
    mort:
        r: call Moveright
           dec cx
           jnz r
        jmp noKey
    
    Waiting:
        mov ah,07h
        int 21h

    lost:
       call GraphicsMode
       call YouLost

    win:
        call GraphicsMode  
        call YouWon 

    exit:
        mov ah, 4ch
        int 21h 
Main Endp


GraphicsMode proc
    push ax
    mov ah,0h
    mov al,13h
    int 10h
    pop ax
    RET
GraphicsMode Endp

UpdateScore proc
    push dx
    push ax
    
    mov dh,23
    mov dl,5
    mov ah,02h
    int 10h

    mov ah,02h
    mov dl,Score[0]
    int 21h

    mov dh,23
    mov dl,6
    mov ah,02h
    int 10h

    mov ah,02h
    mov dl,Score[1]
    int 21h

    pop ax
    pop dx
    ret
UpdateScore Endp

DrawPaddle proc
    push cx
    push dx
    push ax
    mov cx,Paddlex1
    LoopOnX:
        mov dx,Paddley1
        LooponY:
            mov al,04h 
            mov ah,0ch
            int 10h    ;pix(cx,dx) = color
            inc dx
            cmp dx,Paddley2
            jbe LooponY
        inc cx
        cmp cx,Paddlex2
        jbe LoopOnX
    mov ballIsMoving,0    
    pop ax    
    pop dx
    pop cx
    RET
DrawPaddle Endp


YouLost proc
    push ax
    push dx
    LEA DX, LossMessage
    MOV AH, 9
    int 21h
    pop dx
    pop ax
    RET
YouLost Endp

YouWon proc
  push ax
    push dx
    LEA DX, winMessage
    MOV AH, 9
    int 21h
    pop dx
    pop ax
    RET
YouWon Endp


Moveleft proc
    cmp Paddlex1,0
    je returnr
    
    push cx
    push dx
    
    ;remove the old part
    mov cx,Paddlex2
    mov dx,Paddley1

    delYr:
        mov al,00h 
        mov ah,0ch
        int 10h    ;pix(cx,dx) = color
        inc dx
        cmp dx,Paddley2
        jbe delYr
   
    ;new paddle coordinanets
    dec Paddlex1
    dec Paddlex2
   
   ;draw the new part
    mov cx,Paddlex1
    mov dx,Paddley1  

    drwYr:
        mov al,04h 
        mov ah,0ch
        int 10h    ;pix(cx,dx) = color
        inc dx
        cmp dx,Paddley2
        jbe drwYr

    pop dx
    pop cx

    returnr: RET
Moveleft Endp

Moveright proc
    cmp Paddlex2,319
    je returnl
    
    push cx
    push dx
    push ax

    ;remove the old part
    mov cx,Paddlex1
    mov dx,Paddley1

    delYl:
        mov al,00h 
        mov ah,0ch
        int 10h    ;pix(cx,dx) = color
        inc dx
        cmp dx,Paddley2
        jbe delYl
   
    ;new paddle coordinanets
    inc Paddlex1
    inc Paddlex2
   
   ;draw the new part
    mov cx,Paddlex2
    mov dx,Paddley1  

    drwYl:
        mov al,04h 
        mov ah,0ch
        int 10h    ;pix(cx,dx) = color
        inc dx
        cmp dx,Paddley2
        jbe drwYl

    pop ax
    pop dx
    pop cx

    returnl: RET
Moveright Endp

MoveBall proc 
    push cx
    push dx
    dec ballSlow
    jnz skipball
    mov ballslow,500
    mov cx,vx
    mov dx,vy
    call DeleteBall
    add ballx1,cx
    add ballx2,cx
    add bally1,dx
    add bally2,dx
    call DrawBall
    call BallColliding
    skipball:
    pop dx
    pop cx
    RET
MoveBall Endp      
                    


DrawBall proc 
    push cx
    push dx
    push ax
    mov cx,ballx1
    drawballx:
        mov dx,bally1
        drawbally:
            mov al,0Fh
            mov ah,0ch
            int 10h
            inc dx
            cmp dx,bally2
            jbe drawbally
        inc cx
        cmp cx,ballx2
        jbe drawballx    
    pop ax    
    pop dx
    pop cx
    RET
DrawBall Endp

DeleteBall proc
    push cx
    push dx
    push ax
    mov cx,ballx1
    deleteballx:
        mov dx,bally1
        deletebally:
            mov al,00h
            mov ah,0ch
            int 10h
            inc dx
            cmp dx,bally2
            jbe deletebally
        inc cx
        cmp cx,ballx2
        jbe deleteballx    
    pop ax    
    pop dx
    pop cx
    RET
DeleteBall Endp

BallColliding proc 
    push ax
    push cx
    push dx
    
    losing:
        mov ax,bally2
        cmp ax,paddley1
        jbe paddleCheck
        sub lives,1
        mov needrestart,1
        jmp ColideFound

    paddleCheck:
        mov ax,ballx1
        cmp ax,paddlex2  
        ja leftWallCheck
        mov ax,ballx2
        cmp ax,paddlex1
        jb leftWallCheck
        mov ax,bally2
        add ax,1
        cmp ax,paddley1
        jb leftWallCheck
        mov vy,-1
        
        mov dx,ballx1
        add dx,ballmid
        mov cx,Paddlex1
        add cx,Paddlemid
        cmp dx,cx
        je EqualBallPaddle
        ja ApoveBallPaddle
        jb BelowBallPaddle

        EqualBallPaddle:
            mov vx,0
            jmp ColideFound

        ApoveBallPaddle:
            mov vx,1
            jmp ColideFound

        BelowBallPaddle:
            mov vx,-1
            jmp ColideFound


    leftWallCheck:
        cmp ballx2,319
        jb rightWallCheck
        mov vx,-1
        jmp ColideFound

    rightWallCheck:
        cmp ballx1,0
        ja upperWallCheck
        mov vx,1
        jmp ColideFound

    upperWallCheck:
        cmp bally1,0
        ja BricksCheck
        mov vy,1
        jmp ColideFound

    BricksCheck:
        call BricksColliding

    ColideFound:
        pop dx
        pop cx
        pop ax
        RET        
BallColliding Endp


SetBallValues proc
    mov vx,0
    mov vy,0
    mov ballx1,158
    mov bally1,188
    mov ballx2,162
    mov bally2,192 
    RET
SetBallValues Endp

DrawBricks proc ;(23,9)
    push ax
    push dx
    push cx
    push bx
    
    mov cx,0
    mov ax,0h
    mov bx,0h
    BricksX:
        mov dx,0
        BricksY:
            push ax
            add cx,ax
            add dx,bx
            mov al,color 
            mov ah,0ch
            int 10h    ;pix(cx,dx) = color
            pop ax
            sub cx,ax
            sub dx,bx 
            inc dx
            cmp dx,11
            jbe BricksY    
        inc cx
        cmp cx,23
        jbe BricksX
        add ax,33
        mov cx,0
        cmp ax,320
        jb ContinueBricks
        mov ax,0
        add color,2
        add bx,20
        ContinueBricks:
            cmp bx,80
            jne BricksX
        


    pop bx
    pop cx
    pop dx
    pop ax
    RET
DrawBricks Endp

BricksColliding proc
    push ax
    push cx
    push bx
    push dx
    push si

    mov si,0
    mov cx,0
    forBrickX:
        mov dx,0
        forBrickY:
            inc si
            cmp IsDestroied[si],1 
            je Helper3

            DownSide:
            mov ax,ballx1
            mov bx,cx
            add bx,brickW
            dec bx
            cmp ax,bx
            ja UpSide

            mov ax,ballx2
            mov bx,cx
            cmp ax,bx
            jb UpSide

            mov ax,bally1
            mov bx,dx
            add bx,brickH
            dec bx
            cmp ax,bx
            jne UpSide

            call DestroyBricK
            mov ax,vy
            sub vy,ax
            sub vy,ax
            jmp BrickCollided

           
           
            
            UpSide:
            mov ax,ballx1
            mov bx,cx
            add bx,brickW
            dec bx
            cmp ax,bx
            ja RightSide

            mov ax,ballx2
            mov bx,cx
            cmp ax,bx
            jb RightSide

            mov ax,bally2
            mov bx,dx
            cmp ax,bx
            jne RightSide

            call DestroyBricK
            mov ax,vy
            sub vy,ax
            sub vy,ax
            jmp BrickCollided

            
           Helper3:jmp BrickIsAllreadyCollided
           
            RightSide:
            mov ax,bally1
            mov bx,dx
            add bx,brickH
            cmp ax,bx
            ja LeftSide

            mov ax,bally2
            mov bx,dx
            cmp ax,bx
            jb LeftSide

            mov ax,ballx1
            mov bx,cx
            add bx,brickW
            dec bx
            cmp ax,bx
            jne LeftSide

            call DestroyBricK
            mov ax,vx
            sub vx,ax
            sub vx,ax
            jmp BrickCollided

            Helper1:jmp forBrickY
            Helper2:jmp forBrickX
            

            LeftSide:
            mov ax,bally1
            mov bx,dx
            add bx,brickH
            cmp ax,bx
            ja BrickIsAllreadyCollided

            mov ax,bally2
            mov bx,dx
            cmp ax,bx
            jb BrickIsAllreadyCollided

            mov ax,ballx2
            mov bx,cx
            cmp ax,bx
            jne BrickIsAllreadyCollided

            call DestroyBricK
            mov ax,vx
            sub vx,ax
            sub vx,ax
            jmp BrickCollided


            BrickIsAllreadyCollided:
                add dx,brickH
                add dx,HSpace
                cmp dx,80
                jb Helper1
        add cx,brickW
        add cx,WSpace
        cmp cx,320
        jb Helper2

    BrickCollided:
        pop si
        pop dx
        pop bx
        pop cx
        pop ax
        RET
BricksColliding Endp


DestroyBricK proc ; destroies the brick (cx,dx)
    push cx
    push dx
    push si
    push ax
    push bx
    mov IsDestroied[si],1
    dec BricksCount
    
    cmp Score[1],'9'
    jne NormalAdd
    mov Score[1],'0'
    dec Score[1]
    inc Score[0]
    NormalAdd: inc Score[1]

    mov ax,cx
    add ax,brickW
    
    mov bx,dx
    add bx,brickH


    DeleteBrickX:
        push dx
        DeleteBrickY:
            push ax
            mov al,0h 
            mov ah,0ch
            int 10h    ;pix(cx,dx) = color
            pop ax
            inc dx 
            cmp dx,bx
            jbe DeleteBrickY
        pop dx    
        inc cx
        cmp cx,ax
        jbe DeleteBrickX   

    pop bx
    pop ax    
    pop si
    pop dx
    pop cx
    RET
DestroyBricK Endp


End Main

