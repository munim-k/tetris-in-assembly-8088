org 100h
jmp start

score_text: db 'SCORE'
score: db '0000'
time_text: db 'TIME'
time: db '00:00'

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

mov di,2510
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


mov ax,64
push ax
mov ax,3
push ax
mov ax,120
push ax                              ;score text
mov ax,score_text
push ax
push 5
call print

mov di,840
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

mov ax,65
push ax
mov ax,6
push ax
mov ax,07                 ;sample score
push ax
mov ax,score
push ax
push 4
call print

mov ax,65
push ax
mov ax,9
push ax
mov ax,120
push ax                              ;time text
mov ax,time_text
push ax
push 4
call print

mov di,1800
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
mov ax,12
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





start:
call clearscreen
call draw_play_area




