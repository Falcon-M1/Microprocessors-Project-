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
ballx1 dw 158
bally1 dw 188
ballx2 dw 162
bally2 dw 192
ballslowconst dw 10
ballSlow dw 10
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
brickSend dw 0
        ;(x0,y0)

mode db 0

;Game status
lives db 3
needrestart db 0
LossMessage     db 0AH, 0DH, "     ==============================      "
db 0AH, 0DH, "     ==============================      "
db 0AH, 0DH, "     ====     YOU LOST! :(     ====      "
db 0AH, 0DH, "     ==============================      "
db 0AH, 0DH, "     ==============================      $"


winMessage      db 10, 13, "     ==============================      "
db 10, 13, "     ==============================      "
db 10, 13, "     ====     3ash You Won! :)  ===      "
db 10, 13, "     ==============================      "
db 10, 13, "     ==============================      $"

StartMessage   db "Please select mode!",10,13,"$"

MainMenuMessage db "    S - Single Player           ",10,13
db "              M - Multiplayer             ",10,13
db "              C - Chat                    ","$"




;random
color db 2

;chat
chatX1 db 0
chatX2 db 0
ChatY1 db 0
ChatY2 db 13
ChatLineStart db 12
ChatLineMsg db 80 DUP('-') , '$'
ChatEnded db 0

;Multiplayer

WaitingMessages  db 10, 13, "     ==============================      "
db 10, 13, "     ==============================      "
db 10, 13, "         Waiting For Other Player        "
db 10, 13, "     ==============================      "
db 10, 13, "     ==============================      $"
IsMultiplayer db 0
Score2 db '0','0','$'

;JoinedPaddle
JPaddleX1 dw 140
JPaddleX2 dw 180
JPaddleY1 dw 80
JPaddleY2 dw 85
JPaddleSpeed dw 3
JPaddleW dw 41
JPaddleH dw 6
JPaddlemid dw 20

;Host db 0

;Timer
;Timer db '0','0','$'


.code
Main proc; Improved code for BricksColliding procedure


    mov ax,@DATA
    mov ds,ax

    


    MainMenuStart:
        call GraphicsMode
        mov ah,2
        mov dh,0
        mov dl,120
        int 10h
        mov ah,9
        mov dx,offset StartMessage
        int 21h
        mov ah,2
        mov dx,0A0Ah
        int 10h 
        mov ah,9
        mov dx,offset MainMenuMessage
        int 21h
    PressKey:
        mov ah,01
        int 16h
        jz PressKey
        mov ah,00h
        int 16h
        cmp al,'s'
        jz SMode
        cmp al,'m'
        jz MMode
        cmp al,'c'
        jz CMode
        cmp al,1Bh
        je exit
        jmp PressKey
           
   
    SMode:
        call SinglePlayer
        jmp MainMenuStart
    MMode:
        call Multiplayer
        jmp MainMenuStart
    CMode:    
        call Chat
        jmp MainMenuStart



    

  
 

    

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


WaitingScreen proc
    push ax
    push dx
    LEA DX, WaitingMessages
    MOV AH, 9
    int 21h
    pop dx
    pop ax
    RET 
WaitingScreen Endp


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
    mov cx,ballslowconst
    mov ballslow,cx
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
        ja JoinedPaddleDownSide
        mov ax,ballx2
        cmp ax,paddlex1
        jb JoinedPaddleDownSide
        mov ax,bally2
        add ax,1
        cmp ax,paddley1
        jb JoinedPaddleDownSide
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
            

    

    JoinedPaddleDownSide:
        cmp IsMultiplayer,0
        je leftWallCheckHelper
        mov ax,ballx1
        cmp ax,JPaddleX2
        ja JoinedPaddleUPSide
        mov ax,ballx2
        cmp ax,jpaddlex1
        jb JoinedPaddleUPSide
        mov ax,bally2
        inc ax
        cmp ax,jpaddley1
        jne JoinedPaddleUPSide 
        mov vy,-1
        mov dx,ballx1
        add dx,ballmid
        mov cx,Jpaddlex1
        add cx,JPaddlemid
        cmp dx,cx
        je EqualBallJPaddleDown
        ja ApoveBallJPaddleDown
        jb BelowBallJPaddleDowm

        EqualBallJPaddleDown:
            mov vx,0
            jmp ColideFound

        ApoveBallJPaddleDown:
            mov vx,1
            jmp ColideFound
            
        BelowBallJPaddleDowm:
            mov vx,-1
            jmp ColideFound

    leftWallCheckHelper: jmp leftWallCheck

    JoinedPaddleUPSide:
        mov ax,ballx1
        cmp ax,JPaddleX2
        ja JoinedPaddleLeftSide
        mov ax,ballx2
        cmp ax,jpaddlex1
        jb JoinedPaddleLeftSide
        mov ax,bally1
        dec ax
        cmp ax,jpaddley2
        jne JoinedPaddleLeftSide
        mov vy,1
        mov dx,ballx1
        add dx,ballmid
        mov cx,Jpaddlex1
        add cx,JPaddlemid
        cmp dx,cx
        je EqualBallJPaddleUP
        ja ApoveBallJPaddleUP
        jb BelowBallJPaddleUP
        

        EqualBallJPaddleUP:
            mov vx,0
            jmp ColideFound

        ApoveBallJPaddleUP:
            mov vx,1
            jmp ColideFound
            
        BelowBallJPaddleUP:
            mov vx,-1
            jmp ColideFound

    JoinedPaddleLeftSide:
        mov ax,bally1
        cmp ax,jpaddley2
        ja JoinedPaddleRightSide
        mov ax,bally2
        cmp ax,jpaddley1
        jb JoinedPaddleRightSide
        mov ax,ballx1
        dec ax
        cmp ax,jpaddlex2
        jne JoinedPaddleRightSide
        mov vx,1
        jmp ColideFound
        
    JoinedPaddleRightSide:
        mov ax,bally1
        cmp ax,jpaddley2
        ja leftWallCheck
        mov ax,bally2
        cmp ax,jpaddley1
        jb leftWallCheck
        mov ax,ballx2
        inc ax
        cmp ax,jpaddlex1
        jne leftWallCheck
        mov vx,-1
        jmp ColideFound


    leftWallCheck:
        cmp ballx2,318
        jb rightWallCheck
        mov vx,-1
        jmp ColideFound

    rightWallCheck:
        cmp ballx1,1
        ja upperWallCheck
        mov vx,1
        jmp ColideFound

    upperWallCheck:
        cmp bally1,1
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
    push si
    mov BricksCount,40

    
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
        
    mov si,0
    SetBack:
        mov IsDestroied[si],0
        inc si
        cmp si,40
        jbe SetBack

    mov Score[0],'0'
    mov Score[1],'0'

    pop si
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
            
            mov brickSend,si
            add brickSend,1
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
        mov ah,2
    mov dl,7
    int 21h  
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

    cmp IsMultiplayer,0
    je NotMultiplayer    

    call sendIncScore

    NotMultiplayer:
    pop bx
    pop ax    
    pop si
    pop dx
    pop cx
    RET
DestroyBricK Endp

SinglePlayer proc
    push ax
    push cx

    mov ballslowconst,300

    mov IsMultiplayer,0
    call GraphicsMode
    call DrawBricks
    mov BricksCount,40
    mov lives,3
 
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
        cmp al,1Bh
        je endsingleplayer
        mov cx,PaddleSpeed
        cmp al,97
        je molf
        cmp al,100
        je mort
        cmp al,20h
        jne noKey
        cmp vy,0
        jne noKey
        mov vy,1

        noKey:
        call MoveBall
        cmp needrestart,1
        je restart

        call UpdateScore
        call DrawLives

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
    
        

    lost:
        call GraphicsMode
        call YouLost
        mov cx,1000
        call Delay
        jmp endsingleplayer

    win:
        call GraphicsMode 
        call YouWon 
        mov cx,1000
        call Delay
        jmp endsingleplayer

    endsingleplayer:
        pop cx
        pop ax
        RET    
 
SinglePlayer endp


Delay proc ; put in cx the time in ms
    push ax
    push cx
    push dx            
    MOV DX, 1600  ;1600000 clock tick per second           

    DelayOuterLoop:
        MOV AX, DX              
    DelayInnerLoop:
        DEC AX                  
        JNZ DelayInnerLoop    

        DEC CX                  
        JNZ DelayOuterLoop  
    pop ax
    pop cx
    pop dx
    RET
Delay Endp

TextMode proc
    push ax
        mov ah,0
        mov al,03
        int 10h
    pop ax
    RET
TextMode Endp


DrawMidLine proc
    push ax
    push dx
    mov dl,0
    mov dh,ChatLineStart
    call MoveCursor
    mov ah, 09 
    mov dx, offset ChatLineMsg
    int 21h
    pop dx
    pop ax
    RET
DrawMidLine Endp

    
Chat proc
    push ax
    push bx
    push cx
    push dx
    push si
    call TextMode

    call DrawMidLine

    ; initinalizitions
    mov dx,3fbh 			
    mov al,10000000b		
    out dx,al				
    mov dx,3f8h			
    mov al,0ch			
    out dx,al
    mov dx,3f9h
    mov al,00h
    out dx,al
    mov dx,3fbh
    mov al,00011011b
    out dx,al

  
    SendReceive:
        mov cx,2
        call Send
        cmp ChatEnded,1
        je EndedChat
        call Receive
        loop SendReceive


   
    EndedChat:
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        mov ChatEnded,0
        mov chatX1,0
        mov ChatY1,0
        mov chatX2,0
        mov ChatY2,13
        RET
Chat Endp

Send Proc
    push ax
    push dx

    mov dl,chatX1
    mov dh,ChatY1
    call MoveCursor

    ReadDataToSend:
        mov ah, 01h   
        mov al,0h      
        int 16h  
        cmp al,0h  
        je NothingSent
        mov ah,00h
        int 16h
        cmp al,1Bh
        jne CheckReciverReady
        jmp ESCAPE
        
            

    CheckReciverReady:
        push ax
        mov dx , 3FDH
        in al, dx
        and al, 00100000b
        jnz SendData
        pop ax
        jmp ReciverNotReady
        SendData:
            pop ax
            mov dx , 3F8H
            out dx,al
            
            cmp al,13
            je ENTSend

            mov ah,02
            mov dl,al
            int 21h
            jmp sendchk 

            ENTSend:
                mov dl,10
                int 21h
                mov dl,13
                int 21h
                mov chatX1,-1
                inc chatY1

            sendchk:
                cmp chatX1,79
                jne NextCharInLineSend
                mov chatX1,0
                inc chatY1
                jmp DataSent
            NextCharInLineSend:
                mov al,12
                cmp chatY1,al
                je SScroll
                inc chatX1
                jmp DataSent
            SScroll:
                call ScrollSend
                mov chatX1,0
                mov chatY1,11
                call DrawMidLine
                jmp DataSent

    

    ESCAPE:
        mov ChatEnded,1
    DataSent:
    NothingSent:
    ReciverNotReady:
        pop dx
        pop ax
        RET
Send Endp

Receive proc
    push dx
    push ax
    checkifsomthingtoReceive:
        mov dx , 3FDH		
    	in al , dx 
        AND al , 1
        JZ NothingReceived    
    Receiving:
        mov dx , 03F8H
        in al , dx

        mov dl,chatX2
        mov dh,chatY2
        call MoveCursor 

        mov ah,02
        mov dl,al
        int 21h

        cmp al,13
        je ENTRecive

            mov ah,02
            mov dl,al
            int 21h
            jmp recivechk 

            ENTRecive:
                mov dl,10
                int 21h
                mov dl,13
                int 21h
                mov chatX2,-1
                inc chatY2

        recivechk:
            cmp chatX2,79
            jne NextCharInLineReceive
            mov chatX2,0
            inc chatY2
            jmp DataSent
        NextCharInLineReceive:
            mov al,24
            cmp chatY2,al
            je RScroll
            inc chatX2
            jmp DataSent
        RScroll:
            call ScrollRecive
            mov chatX2,0
            mov chatY2,23
            call DrawMidLine
            jmp DataSent

        


    NothingReceived:
        pop ax
        pop dx
        RET
Receive Endp

MoveCursor proc ;(dl,dh)
    push ax
    mov ah,02
    int 10h
    pop ax
    RET
MoveCursor Endp



ScrollSend proc
    push ax
    push dx
    push cx
    push bx
    mov ax, 0601h
    mov cx,0
    mov DH,11
    mov DL,79
    mov BH, 07h
    int 10H
    pop bx
    pop cx
    pop dx
    pop ax
    RET
ScrollSend Endp



ScrollRecive proc
    push ax
    push dx
    push cx
    push bx
    mov ax, 0601h
    mov ch,0dh
    mov cl,00h
    mov DH,24
    mov DL,79
    mov BH, 07h
    int 10H
    pop bx
    pop cx
    pop dx
    pop ax
    RET
ScrollRecive Endp

Multiplayer proc
    
    push ax
    push bx
    push cx
    push dx
    push si
    mov IsMultiplayer,1

    ; initinalizitions
    mov dx,3fbh 			
    mov al,10000000b		
    out dx,al				
    mov dx,3f8h			
    mov al,0ch			
    out dx,al
    mov dx,3f9h
    mov al,00h
    out dx,al
    mov dx,3fbh
    mov al,00011011b
    out dx,al

    
        

    CheckForPuffer1:
        mov dx , 3FDH		
    	in al , dx
        AND al , 1
        jz HstHelper
        mov dx,3f8h
        in al,dx
        cmp al,00000001b
        je join
    
    HstHelper:
        call GraphicsMode
        call WaitingScreen

    Hst:    
        mov dx,3FDH
        in al,dx
        and al,00100000b
        jz Hst   
        mov dx,3f8h
        mov al,00000001b
        out dx,al
        chkoined:
                mov al,0
                mov ah,01h
                int 16h
            jz noescapeEntered
            mov ah,00h
            int 16h
            cmp al,1Bh
            je EndMultiplayer
            noescapeEntered:
            mov dx , 3FDH		
    	    in al , dx 
            AND al , 1
            jz chkoined
            mov dx,3f8h
            in al,dx
            cmp al,00000010b
            jne chkoined
        call PlayHost
        jmp EndMultiplayer
    join: 
        chkhst:
            mov dx,3FDH
            in al,dx
            and al,00100000b
            jz chkhst
        mov dx,3f8h
        mov al,00000010b
        out dx,al
        call PlayJoined
        jmp EndMultiplayer
       
    EndMultiplayer:
        mov IsMultiplayer,0
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        RET
Multiplayer Endp


PlayHost proc
    push ax
    push cx
    mov ballslowconst,45
    call GraphicsMode
    call DrawBricks
    call DrawJoined
    mov BricksCount,40
    mov lives,3

    restartHost:
        call DeleteBall
        mov needrestart,0
        call DrawPaddle
        call SetBallValues
        call DrawBall
        call DrawJoined


    ReadInputHost:
        cmp lives,0
        je HostLost
        cmp BricksCount,20
        jb HostWin

        mov al,0
        mov ah, 01h         
        int 16h     
        jz CHK_M1
        mov ah, 00h        
        int 16h  ;the input now in al do what u want

        ;moving the paddle
        cmp al,1Bh
        je EndHost
        mov cx,PaddleSpeed
        cmp al,97
        je Hostmolf
        cmp al,100
        je Hostmort
        cmp al,20h
        jne CHK_M1
        cmp vy,0
        jne CHK_M1
        mov vy,1

        ;Check that Data Ready from UART
    CHK_M1:    mov dx , 3FDH		; Line Status Register
    	    in al , dx 
            AND al , 1
            JZ HostnoKey    ; if there is not char in uart go check for key pressed

    ;If Ready read the rec in Receive data register
            mov dx , 03F8H
            in al , dx 
            call MultiplayerHostRecieve

        HostnoKey:
        call MoveBall
        call MultiplayerHostSendNoKey
        cmp needrestart,1
        je restartHost

        call UpdateScore
        call DrawLives
        jmp ReadInputHost      ; Continue checking for input        

        Hostmolf:
            Call Moveleft
            Call MultiplayerHostSendLeft
            dec cx
            jnz Hostmolf
            jmp CHK_M1

        Hostmort:
            call Moveright
            Call MultiplayerHostSendRight
            dec cx
            jnz Hostmort
            jmp CHK_M1

        HostLost:
            call GraphicsMode
            call SendLost  
            call YouLost      
            mov cx,1000
            call Delay
            jmp EndHost

        Hostwin:
            call GraphicsMode
            call SendWin  
            call YouWon
            mov cx,1000
            call Delay
            jmp EndHost    



    EndHost:
        pop cx
        pop ax
        RET
PlayHost Endp
    
PlayJoined proc 
    push ax
    push cx
    
    call GraphicsMode
    call DrawBricks
    call DrawJoined
    mov BricksCount,40
    call Drawpaddle
    mov score2,'0'
    mov score2[1],'0'
    
    restartJoined:
        call DeleteBall
        mov needrestart,0
        call DrawPaddle
        call SetBallValues
        call DrawBall
        call DrawJoined
        

    ReadJoinedInput:
        mov al,0
        mov ah, 01h         
        int 16h     
        jz CHK_M
        mov ah, 00h        
        int 16h  ;the input now in al do what u want

        mov cx,PaddleSpeed
        cmp al,1Bh
        je EndJoined
        cmp al,97
        je Joinedmolf
        cmp al,100
        je Joinedmort
        cmp al,20h
        jne CHK_M
        cmp vy,0
        jne CHK_M
        mov vy,1

        ;Check that Data Ready from UART
    CHK_M:    mov dx , 3FDH		; Line Status Register
    	    in al , dx 
            AND al , 1
            JZ JoinednoKey    ; if there is not char in uart go check for key pressed

    ;If Ready read the rec in Receive data register
            mov dx , 03F8H
            in ax , dx
            cmp al,00000001b
            jz JoinedLost
            cmp al,00000010b
            jz JoinedWin
            cmp al,00000011b
            jz IncScore2_M


            call MultiplayerJoinedRecieve
            jmp JoinednoKey
        IncScore2_M:
          call IncScore2
          

        JoinednoKey:
            call UpdateScore2
            jmp ReadJoinedInput

        Joinedmolf:
            call moveJRight
            call MultiplayerJoinedSendRight
            dec cx
            jnz Joinedmolf
            jmp CHK_M

        Joinedmort:
            call MoveJleft
            call MultiplayerJoinedSendLeft
            dec cx
            jnz Joinedmort
            jmp CHK_M


       

        JoinedLost:
            call GraphicsMode 
            call YouLost
            mov cx,1000
            call Delay
            jmp EndJoined

        JoinedWin:
            call GraphicsMode  
            call YouWon
            mov cx,1000
            call Delay
            jmp EndJoined  
    

    EndJoined:
        pop cx
        pop ax
        RET
PlayJoined Endp


DrawJoined proc
    push cx
    push dx
    push ax
    mov cx,JPaddlex1
    JLoopOnX:
        mov dx,JPaddley1
        JLooponY:
            mov al,09h 
            mov ah,0ch
            int 10h    ;pix(cx,dx) = color
            inc dx
            cmp dx,JPaddley2
            jbe JLooponY
        inc cx
        cmp cx,JPaddlex2
        jbe JLoopOnX 
    pop ax    
    pop dx
    pop cx
    RET
DrawJoined Endp


moveJRight Proc
    cmp JPaddlex1,0
    je Jreturnr
    
    push cx
    push dx
    
    ;remove the old part
    mov cx,JPaddlex2
    mov dx,JPaddley1

    delYrJ:
        mov al,00h 
        mov ah,0ch
        int 10h    ;pix(cx,dx) = color
        inc dx
        cmp dx,JPaddley2
        jbe delYrJ
   
    ;new paddle coordinanets
    dec JPaddlex1
    dec JPaddlex2
   
   ;draw the new part
    mov cx,JPaddlex1
    mov dx,JPaddley1  

    drwYrJ:
        mov al,09h 
        mov ah,0ch
        int 10h    ;pix(cx,dx) = color
        inc dx
        cmp dx,JPaddley2
        jbe drwYrJ

    pop dx
    pop cx

    Jreturnr: RET
moveJRight Endp


MoveJleft proc
    cmp JPaddlex2,319
    je Jreturnl
    
    push cx
    push dx
    push ax

    ;remove the old part
    mov cx,JPaddlex1
    mov dx,JPaddley1

    delYlJ:
        mov al,00h 
        mov ah,0ch
        int 10h    ;pix(cx,dx) = color
        inc dx
        cmp dx,JPaddley2
        jbe delYlJ
   
    ;new paddle coordinanets
    inc JPaddlex1
    inc JPaddlex2
   
   ;draw the new part
    mov cx,JPaddlex2
    mov dx,JPaddley1  

    drwYlJ:
        mov al,09h 
        mov ah,0ch
        int 10h    ;pix(cx,dx) = color
        inc dx
        cmp dx,JPaddley2
        jbe drwYlJ

    pop ax
    pop dx
    pop cx

    Jreturnl: RET
MoveJleft Endp

MultiplayerHostRecieve proc
  cmp al,11111110b
  jz recL
  cmp al,11111111b
  jz recR
  recL:
    call MoveJleft
    jmp exitMHR
  recR:
    call moveJRight
    jmp exitMHR

    exitMHR:
    RET
MultiplayerHostRecieve endp

MultiplayerJoinedRecieve proc
    push ax 
    push bx
    push si
    cmp al,11110100b
    jz recRnB
    cmp al,11110101b
    jz recRB1
    cmp al,11110110b
    jz recRB2
    cmp al,11110111b
    jz recRB3
    cmp al,11111101b
    jz recRB4
    cmp al,11111110b
    jz recRB5
    cmp al,11111111b
    jz recRB6H
    call MultiplayerJoinedRecieve3
    call MultiplayerJoinedRecieve2
    jmp brick_M


    recRnB:
      call Moveright
      mov vy,0
      call DeleteBall
      call SetBallValues
      call DrawBall
      jmp exitMJR

    recRB6H:
     jmp recRB6
    recRB1:
      call Moveright
      mov vy,1
      mov vx,0
      call MoveBall
      jmp exitMJR
    recRB2:
      call Moveright
      mov vy,1
      mov vx,1
      call MoveBall
      jmp exitMJR
    recRB3:
      call Moveright
      mov vy,1
      mov vx,-1
      call MoveBall
      jmp exitMJR
    recRB4:
      call Moveright
      mov vy,-1
      mov vx,0
      call MoveBall
      jmp exitMJR
    recRB5:
      call Moveright
      mov vy,-1
      mov vx,1
      call MoveBall
      jmp exitMJR
    recRB6:
      call Moveright
      mov vy,-1
      mov vx,-1
      call MoveBall
      jmp exitMJR
    
    brick_M:
    cmp ah,0
    jbe exitMJR
    
    mov bx,0
    mov bl,ah
    mov si,bx
    sub si,1
   ; call DestroyBricK 
    
    exitMJR:
    pop si
    pop bx 
    pop ax
    RET
MultiplayerJoinedRecieve endp

MultiplayerJoinedRecieve2 proc
    push ax
    cmp al,11100100b
    jz recNnB
    cmp al,11100101b
    jz recNB1
    cmp al,11100110b
    jz recNB2
    cmp al,11100111b
    jz recNB3
    cmp al,11101101b
    jz recNB4
    cmp al,11101110b
    jz recNB5
    cmp al,11101111b
    jz recNB6
    jmp exitMJR2
    recNnB:
      mov vy,0
      call DeleteBall
      call SetBallValues
      call DrawBall
      jmp exitMJR2
    recNB1:
      mov vy,1
      mov vx,0
      call MoveBall
      jmp exitMJR2
    recNB2:
      mov vy,1
      mov vx,1
      call MoveBall
      jmp exitMJR2
    recNB3:
      mov vy,1
      mov vx,-1
      call MoveBall
      jmp exitMJR2
    recNB4:
      mov vy,-1
      mov vx,0
      call MoveBall
      jmp exitMJR2
    recNB5:
      mov vy,-1
      mov vx,1
      call MoveBall
      jmp exitMJR2
    recNB6:
      mov vy,-1
      mov vx,-1
      call MoveBall
      jmp exitMJR2
    exitMJR2:
    pop ax
    RET
MultiplayerJoinedRecieve2 endp

MultiplayerJoinedRecieve3 proc
    push ax
    cmp al,11110000b 
    jz recLnB
    cmp al,11110001b
    jz recLB1
    cmp al,11110010b
    jz recLB2
    cmp al,11110011b
    jz recLB3
    cmp al,11111001b
    jz recLB4
    cmp al,11111010b
    jz recLB5
    cmp al,11111011b
    jz recLB6H
    jmp exitMJR3

    recLnB:
      call Moveleft
      mov vy,0
      call DeleteBall
      call SetBallValues
      call DrawBall
      jmp exitMJR3

    recLB6H:
      jmp recLB6
    recLB1:
      call Moveleft
      mov vy,1
      mov vx,0
      call MoveBall
      jmp exitMJR3
    recLB2:
      call Moveleft
      mov vy,1
      mov vx,1
      call MoveBall
      jmp exitMJR3
    recLB3:
      call Moveleft
      mov vy,1
      mov vx,-1
      call MoveBall
      jmp exitMJR3
    recLB4:
      call Moveleft
      mov vy,-1
      mov vx,0
      call MoveBall
      jmp exitMJR3
    recLB5:
      call Moveleft
      mov vy,-1
      mov vx,1
      call MoveBall
      jmp exitMJR3
    recLB6:
      call Moveleft
      mov vy,-1
      mov vx,-1
      call MoveBall
      jmp exitMJR3

      exitMJR3:
      pop ax
      RET
MultiplayerJoinedRecieve3 endp


MultiplayerHostSendLeft proc
    push ax
    push dx
    mov dx , 3FDH		; Line Status Register

              sendCheck_M1:  
                In al , dx 			;Read Line Status
                AND al , 00100000b
                JZ sendCheck_M1
           cmp vy,0
           jz movLnB
           cmp vy,1
           jz movLCheck
           cmp vy,-1
           jz movLCheck2

          movLCheck: 
           cmp vx,0
           jz movLB1
           cmp vx,1
           jz movLB2
           cmp vx,-1
           jz movLB3

          movLCheck2:
           cmp vx,0
           jz movLB4
           cmp vx,1
           jz movLB5
           cmp vx,-1
           jz movLB6

           movLnB:
            mov al,11110000b
            jmp movLS
           movLB1:
            mov al,11110001b
            jmp movLS 
           movLB2:
            mov al,11110010b
            jmp movLS
           movLB3:
            mov al,11110011b
            jmp movLS 
           movLB4:
            mov al,11111001b
            jmp movLS 
           movLB5:
            mov al,11111010b
            jmp movLS
           movLB6:
            mov al,11111011b
            jmp movLS
           movLS:
           mov dx , 3F8H		; Transmit data register
           mov ah,byte ptr brickSend
           mov brickSend,0
           out dx , ax
    MHSL_exit:
    pop dx
    pop ax
    RET
MultiplayerHostSendLeft endp

MultiplayerHostSendRight proc
            push ax
            push dx
           mov dx , 3FDH		; Line Status Register

              sendCheck_Mw:  
                In al , dx 			;Read Line Status
                AND al , 00100000b
                JZ sendCheck_Mw
           cmp vy,0
           jz movRnB
           cmp vy,1
           jz movRCheck
           cmp vy,-1
           jz movRCheck2

          movRCheck: 
           cmp vx,0
           jz movRB1
           cmp vx,1
           jz movRB2
           cmp vx,-1
           jz movRB3

          movRCheck2:
           cmp vx,0
           jz movRB4
           cmp vx,1
           jz movRB5
           cmp vx,-1
           jz movRB6

           movRnB:
            mov al,11110100b
            jmp movRS
           movRB1:
            mov al,11110101b
            jmp movRS 
           movRB2:
            mov al,11110110b
            jmp movRS
           movRB3:
            mov al,11110111b
            jmp movRS
           movRB4:
            mov al,11111101b
            jmp movRS 
           movRB5:
            mov al,11111110b
            jmp movRS
           movRB6:
            mov al,11111111b
            jmp movRS 
           movRS:
           mov dx , 3F8H		; Transmit data register
           mov ah,byte ptr brickSend
           mov brickSend,0
           out dx , ax

    pop dx
    pop ax
   RET
MultiplayerHostSendRight endp

MultiplayerHostSendNoKey proc
    push ax
    push dx
    mov dx , 3FDH		; Line Status Register

              sendCheck_M5:  
                In al , dx 			;Read Line Status
                AND al , 00100000b
                JZ sendCheck_M5
           cmp vy,0
           jz movNnB
           cmp vy,1
           jz movNCheck
           cmp vy,-1
           jz movNCheck2

          movNCheck: 
           cmp vx,0
           jz movNB1
           cmp vx,1
           jz movNB2
           cmp vx,-1
           jz movNB3

          movNCheck2:
           cmp vx,0
           jz movNB4
           cmp vx,1
           jz movNB5
           cmp vx,-1
           jz movNB6

           movNnB:
            mov al,11100100b
            jmp movNS
           movNB1:
            mov al,11100101b
            jmp movNS 
           movNB2:
            mov al,11100110b
            jmp movNS
           movNB3:
            mov al,11100111b
            jmp movNS
           movNB4:
            mov al,11101101b
            jmp movNS 
           movNB5:
            mov al,11101110b
            jmp movNS
           movNB6:
            mov al,11101111b
            jmp movNS  
           movNS:
           mov dx , 3F8H		; Transmit data register
           mov ah,byte ptr brickSend
           mov brickSend,0
           out dx , ax
    pop dx
    pop ax
   RET
MultiplayerHostSendNoKey endp

MultiplayerJoinedSendLeft proc
    push ax
    push dx
           mov dx , 3FDH		; Line Status Register

              sendCheck_M3:  
                In al , dx 			;Read Line Status
                AND al , 00100000b
                JZ sendCheck_M3
           mov al,11111110b
           mov dx , 3F8H		; Transmit data register
           out dx , al
    pop dx
    pop ax        
   RET
MultiplayerJoinedSendLeft endp

MultiplayerJoinedSendRight proc
            push ax
            push dx
           mov dx , 3FDH		; Line Status Register

              sendCheck_M4:  
                In al , dx 			;Read Line Status
                AND al , 00100000b
                JZ sendCheck_M4
           mov al,11111111b
           mov dx , 3F8H		; Transmit data register
           out dx , al
    pop dx
    pop ax
   RET
MultiplayerJoinedSendRight endp

SendWin proc
    push ax
    push dx
  mov dx , 3FDH		; Line Status Register

              sendCheck_M6:  
                In al , dx 			;Read Line Status
                AND al , 00100000b
                JZ sendCheck_M6
           mov al,00000001b
           mov dx , 3F8H		; Transmit data register
           out dx , al
    pop dx
    pop ax
   RET
SendWin endp

SendLost proc
push ax
push dx
  mov dx , 3FDH		; Line Status Register

              sendCheck_M7:  
                In al , dx 			;Read Line Status
                AND al , 00100000b
                JZ sendCheck_M7
           mov al,00000010b
           mov dx , 3F8H		; Transmit data register
           out dx , al
   pop dx
    pop ax        
   RET
SendLost endp

DrawLives Proc
    push ax
    push dx
    mov dh,23
    mov dl,36
    mov ah,02h
    int 10h



    mov ah,02h
    mov dl,lives
    add dl,'0'
    int 21h
    pop dx
    pop ax 
    RET
DrawLives Endp

IncScore2 proc
    cmp Score2[1],'9'
    jne NormalAdd2
    mov Score2[1],'0'
    inc Score2[0]
    NormalAdd2: inc Score2[1]
    RET
IncScore2 endp

UpdateScore2 proc
    push dx
    push ax
    
    mov dh,23
    mov dl,5
    mov ah,02h
    int 10h

    mov ah,02h
    mov dl,Score2[0]
    int 21h

    mov dh,23
    mov dl,6
    mov ah,02h
    int 10h

    mov ah,02h
    mov dl,Score2[1]
    int 21h

    pop ax
    pop dx
    ret
UpdateScore2 endp

sendIncScore proc
push ax
    push dx
           mov dx , 3FDH		; Line Status Register

              sendCheck_M9:  
                In al , dx 			;Read Line Status
                AND al , 00100000b
                JZ sendCheck_M9
           mov al,00000011b
           mov dx , 3F8H		; Transmit data register
           out dx , al
    pop dx
    pop ax        
   RET
sendIncScore endp

End Main

