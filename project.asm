org 100h
jmp start


next_shape: db 'NEXT SHAPE'
score_text: db 'SCORE'
score: db '6969'
time_text: db 'TIME'
time: db '04:44'
shape: db ' '
color: db 40
xpos: dd 62
ypos: dd 17

clearscreen:
push es
push ax
push cx
push di

mov ax,0xb800
mov es,ax
xor di,di
mov al,' '
mov ah,120
mov cx,2000
cld
rep stosw

pop di
pop cx
pop ax
pop es
ret

print:
push bp
mov bp,sp
push es
push ax
push cx
push si
push di

mov ax,0xb800
mov es,ax
mov al,80
mul byte [bp+10]
add ax,[bp+12]
shl ax,1
mov di,ax
mov si,[bp+6]
mov cx,[bp+4]
mov ah,[bp+8]

next:
cld
lodsb
stosw
loop next

pop di
pop si
pop cx
pop ax
pop es
pop bp
ret 10

draw_play_area:
push es
push ax
push cx
push di
push si

mov ax,0xb800
mov es,ax
mov di,162                ;top line
mov al,'-'
mov ah,0x000000
mov cx,78
cld
rep stosw

mov di,162
mov cx,23
vertical:                           ;vertical line left
mov [es:di],ax
add di,160
loop vertical

mov di,316
mov cx,23
vertical_r:                             ;vertical line right
mov [es:di],ax
add di,160
loop vertical_r

mov di,270
mov cx,23
vertical_m:                           ;vertical line middle 
mov [es:di],ax
add di,160
loop vertical_m

mov di,3682
mov al,'-'                    ;bottom line
mov ah,0x000000
mov cx,78
cld
rep stosw

mov di,2190
mov al,'-'                       ;segment partition line
mov ah,0x000000
mov cx,23
cld
rep stosw

mov di,490
mov al,' '
mov ah,0
mov si,0
play_area:
mov cx,47
cld                                 ;play area black box
rep stosw
add di,66
inc si
cmp si,18
jbe play_area


mov ax,65
push ax
mov ax,3
push ax
mov ax,120
push ax                              ;score text
mov ax,score_text
push ax
push 5
call print

mov di,680
mov al,' '
mov ah,0
mov si,0
score_area:
mov cx,15                          ;score black area
cld
rep stosw
add di,50
inc si
cmp si,5
jbe score_area


mov ax,62
push ax
mov ax,15
push ax
mov ax,120
push ax                              ;next shape text
mov ax,next_shape
push ax
push 10
call print


mov di, 2680
mov al, ' '
mov ah, 0
mov si, 0
nextshape_area:
mov cx,15                          ;next shape black area
cld
rep stosw
add di,50
inc si
cmp si,10
jbe nextshape_area

mov ax,65
push ax
mov ax,5
push ax
mov ax,07                 ;sample score
push ax
mov ax,score
push ax
push 4
call print

mov ax,65
push ax
mov ax,8
push ax
mov ax,120
push ax                              ;time text
mov ax,time_text
push ax
push 4
call print

mov di,1480
mov al,' '
mov ah,0
mov si,0
time_area:
mov cx,15                          ;time black area
cld
rep stosw
add di,50
inc si
cmp si,5
jbe time_area

mov ax,65
push ax
mov ax,10
push ax
mov ax,07                 ;sample time
push ax
mov ax,time
push ax
push 5
call print


pop si
pop di
pop cx
pop ax
pop es
ret


shape1:
push bp
mov bp, sp
push ax
push es
push di
push cx

mov ax, 0xb800
mov es, ax
mov al, 80
mul byte [bp+4] ;ypos
add ax, [bp+6] ;xpos
shl ax, 1
mov di, ax
mov al, [shape]
mov ah, [bp+8] ;attribute


mov cx, 12 
lineloop:

mov [es:di], ax
add di, 2

loop lineloop

add di, 136

mov cx, 12
lineloop2:

mov [es:di], ax
add di, 2

loop lineloop2

add di, 136

mov cx, 4
lineloop3:

mov [es:di], ax
add di, 2

loop lineloop3

add di, 152

mov cx, 4
lineloop4:

mov [es:di], ax
add di, 2

loop lineloop4

pop cx
pop di
pop es
pop ax
pop bp
ret


shape2:

push bp
mov bp, sp
push ax
push es
push di
push cx

mov ax, 0xb800
mov es, ax
mov al, 80
mul byte [bp+4] ;ypos
add ax, [bp+6] ;xpos
shl ax, 1
mov di, ax
mov al, [shape]
mov ah, [bp+8] ;attribute

xor bx, bx
mov bx, 8
tallloop:

mov cx, 4 
lineloopB:

mov [es:di], ax
add di, 2

loop lineloopB

add di, 152
dec bx
cmp bx, 0
jne tallloop





pop cx
pop di
pop es
pop ax
pop bp
ret



shape3:

push bp
mov bp, sp
push ax
push es
push di
push cx

mov ax, 0xb800
mov es, ax
mov al, 80
mul byte [bp+4] ;ypos
add ax, [bp+6] ;xpos
shl ax, 1
mov di, ax
mov al, [shape]
mov ah, [bp+8] ;attribute

mov dx, 2
linerepeat:

mov cx, 16 
lineloopC:

mov [es:di], ax
add di, 2

loop lineloopC

add di, 128
dec dx
cmp dx, 0
jne linerepeat







pop cx
pop di
pop es
pop ax
pop bp
ret






start:
call clearscreen
call draw_play_area

mov ax, [color]		;range from 10, 20, 30, 40, 50, 60, 70
push ax
mov ax, [xpos]
push ax
mov ax, [ypos]
push ax

call shape1

mov ax, 60			;color
push ax
mov ax, 33			;xpos
push ax
mov ax, 7			;ypos
push ax

call shape2

mov ax, 90			;color
push ax
mov ax, 5			;xpos
push ax,
mov ax, 20			;ypos
push ax

call shape3


mov ax, 0x4c00
int 0x21