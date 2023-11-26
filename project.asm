org 100h
jmp start

game_over_text: db 'GAME OVER'
next_shape: db 'NEXT SHAPE'
score_text: db 'SCORE:'
score: db '6969'
time_text: db 'TIME:'
time: db '04:44'
shape: db ' '
<<<<<<< HEAD
color: db 40			;current block color
xpos: dw 26	;current block xpos
ypos: dw 3	;current block ypos
piecewidth: dd 4
pieceheight: dd 1
temp: dd 0
oldisrtimer:  dd 0
oldisrkeyboard: dd 0
tickcount: dw 0
totaltimer: dw 0
gameover: db 0
reachdown: dw 0
=======
color: db 40
xpos: dd 62
ypos: dd 17
oldisr: dd 0 
tickcount: dw 0
>>>>>>> 6abc8d829e184dca5d1dc7c75b4ca67382981f52
seconds: dw 0
minutes: dw 0


<<<<<<< HEAD






kbisr: 
push ax
push es
in al, 0x60 ; read a char from keyboard port
cmp al, 0x4D ; is the right key pressed
jne nextcmp ; no, try next comparison
call move_right
jmp nomatch ; leave interrupt routine
nextcmp: 
cmp al, 0x4B ; is the left key pressed
jne nextcmp2 ; no, leave interrupt routine
call move_left

nextcmp2:
cmp al, 0x50
jne nomatch
call move_down
nomatch: 
mov al, 0x20
out 0x20, al
pop es
pop ax
iret 



printnum: 
push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov ax, 0xb800
mov es, ax 
mov ax, [bp+4] 
mov bx, 10 
mov cx, 0
nextdigit: 
mov dx, 0 
div bx 
add dl, 0x30 
push dx
inc cx 
cmp ax, 0
jnz nextdigit 
mov di, [bp+6]
nextpos: pop dx 
mov dh, 0x07 
mov [es:di], dx
add di, 2 
loop nextpos 
pop di
pop dx
pop cx
pop bx
pop ax 
pop es
pop bp
ret 4
=======
kbisr: 
push ax
 push es
 mov ax, 0xb800
 mov es, ax 
 in al, 0x60 
 cmp al, 0x4b 
 jne nextcmp 
 mov byte [es:0], 'L' 
 jmp nomatch 
nextcmp:
 cmp al, 0x4d 
 jne nomatch
 mov byte [es:0], 'R' 
nomatch:
 pop es
 pop ax
 jmp far [cs:oldisr] 

printnum: 
push bp
 mov bp, sp
 push es
 push ax
 push bx
 push cx
 push dx
 push di
 mov ax, 0xb800
 mov es, ax 
 mov ax, [bp+4] 
 mov bx, 10 
 mov cx, 0
nextdigit: mov dx, 0 
 div bx 
 add dl, 0x30 
 push dx
 inc cx 
 cmp ax, 0
 jnz nextdigit 
 mov di, [bp+6]
nextpos: pop dx 
 mov dh, 0x07 
 mov [es:di], dx
 add di, 2 
 loop nextpos 
 pop di
 pop dx
 pop cx
 pop bx
 pop ax 
 pop es
 pop bp
 ret 4
>>>>>>> 6abc8d829e184dca5d1dc7c75b4ca67382981f52
 
nextminute:
inc word [minutes]
mov word [seconds],0
push 1730
push word [minutes]
call printnum
jmp _jmpback

nextsecond:
<<<<<<< HEAD

inc word [seconds]
push 1740
push word [seconds]
call printnum
mov word [cs:totaltimer],0
jmp jmpback


timer: 
push ax
inc word [cs:tickcount]; increment tick count
inc word [cs:totaltimer] ;inc total time

cmp word [cs:totaltimer], 18
jge nextsecond
jmpback:
cmp word [seconds], 59
jge nextminute
_jmpback:


cmp word [cs:totaltimer], 800
jne skip5

mov byte [cs:gameover], 1


skip5:
cmp word [cs:tickcount], 6


jne skip4
mov word [cs:tickcount], 0
call move_down

skip4:

;push word [cs:tickcount]
;call printnum ; print tick count



end:
mov al, 0x20
out 0x20, al ; end of interrupt
pop ax
iret ; return from interrupt

=======
 inc word [seconds]
 push 1740
 push word [seconds]
 call printnum
 mov word [cs:tickcount],0
 jmp jmpback
timer:
 push ax
 inc word [cs:tickcount]
 cmp word [cs:tickcount],18
 jge nextsecond
 jmpback:
 cmp word [seconds],59
 jge nextminute
 _jmpback:
  
  
  
 mov al, 0x20
 out 0x20, al
 
 pop ax
 iret 
>>>>>>> 6abc8d829e184dca5d1dc7c75b4ca67382981f52

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

draw_end_screen:


mov ax,0xb800
mov es,ax

mov di,978
mov al,' '
mov ah,70
mov si,0
end_area:
mov cx,40
cld                                 ;end screen area red box
rep stosw
add di,80
inc si
cmp si,10
jbe end_area

mov ax,24
push ax
mov ax,7
push ax
mov ax,11001111b
push ax                              ;game over text
mov ax,game_over_text
push ax
push 9
call print

mov ax,23
push ax
mov ax,10
push ax
mov ax,01001111b
push ax                              ;score game over text
mov ax,score_text
push ax
push 6
call print

mov ax,30
push ax
mov ax,10
push ax
mov ax,01001111b
push ax                              ;score game over text
mov ax,score
push ax
push 4
call print

mov ax,23
push ax
mov ax,12
push ax
mov ax,01001111b
push ax                              ;time game over text
mov ax,time_text
push ax
push 5
call print

mov ax,30
push ax
mov ax,12
push ax
mov ax,01001111b
push ax                              ;time game over 
mov ax,time
push ax
push 6
call print

ret


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

<<<<<<< HEAD

=======
; mov ax,65
; push ax
; mov ax,10
; push ax
; mov ax,07                 ;sample time
; push ax
; mov ax,time
; push ax
; push 5
; call print
>>>>>>> 6abc8d829e184dca5d1dc7c75b4ca67382981f52


pop si
pop di
pop cx
pop ax
pop es
ret





draw_shape:

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


mov cx, 8 
lineloopZ:

mov [es:di], ax
add di, 2

loop lineloopZ


pop cx
pop di
pop es
pop ax
pop bp
ret 6

move_left:
push bp
mov bp, sp
push ax

mov ax, 00			;att
push ax
mov ax, [xpos]
push ax,
mov ax, [ypos]
push ax
call draw_shape

mov ax, [color]
push ax
mov ax, [xpos]

cmp ax, 5
je skip2

cmp ax, 6
je skip2

sub ax, 2
mov [xpos], ax

skip2:
push ax
mov ax, [ypos]
push ax
call draw_shape


pop ax
pop bp
ret 



move_right:
push bp
mov bp, sp
push ax

mov ax, 00
push ax
mov ax, [xpos]
push ax,
mov ax, [ypos]
push ax
call draw_shape

mov ax, [color]
push ax
mov ax, [xpos]

mov bx, 40
add bx, [piecewidth]

cmp ax, bx
je skip

dec bx
cmp ax, bx
je skip

add ax, 2

mov [xpos], ax

skip:

push ax
mov ax, [ypos]
push ax
call draw_shape


pop ax
pop bp
ret 



move_down:
push bp
mov bp, sp
push ax
push bx

mov ax, 00
push ax
mov ax, [xpos]
push ax,
mov ax, [ypos]
push ax
call draw_shape

mov ax, [color]
push ax
mov ax, [xpos]
mov [xpos], ax
push ax
mov ax, [ypos] ;ypos

;check for color

push ax			

					
mov ax, 0xb800
mov es, ax
mov al, 80
mov bx, [ypos]
add bx, [pieceheight]
;inc bx

mov [temp], bx


mul byte [temp] ;ypos under shape
add ax, [xpos] ;xpos
shl ax, 1
mov di, ax
;add di, 4
;add di, 320				;check the line under



;;if es:di is not black inc ax, else keep ax same, place object and call next shape
xor ax, ax
mov ax, [es:di]
cmp ah, 0x00



;push ax
;mov ah, 0x1C
;mov al, 33
;mov [es:di], ax
;pop ax




jne is_not_black

;;second check

<<<<<<< HEAD




black:
mov bx, [piecewidth]
add bx, 2
shl bx, 1
add di, bx
mov ax, [es:di]
cmp ah, 0x00




jne is_not_black



pop ax		;original ypos 
add ax, [pieceheight]
jmp skip3


is_not_black:
pop ax
mov word [reachdown], 1

skip3:
mov [ypos], ax
push ax
call draw_shape

pop bx
pop ax
pop bp
ret 



=======
pop cx
pop di
pop es
pop ax
pop bp
ret
>>>>>>> 6abc8d829e184dca5d1dc7c75b4ca67382981f52

start:
call clearscreen
xor ax, ax
 mov es, ax ; point es to IVT base
 cli ; disable interrupts
 mov word [es:8*4], timer; store offset at n*4
 mov [es:8*4+2], cs ; store segment at n*4+2
 sti

 xor ax, ax
 mov es, ax 
 mov ax, [es:9*4]
 mov [oldisr], ax 
 mov ax, [es:9*4+2]
 mov [oldisr+2], ax 
 cli 
 mov word [es:9*4], kbisr 
 mov [es:9*4+2], cs 
 sti 
call draw_play_area



mov ax, [color]		;range from 10, 20, 30, 40, 50, 60, 70
push ax
mov ax, [xpos]		;bp+6
push ax
mov ax, [ypos]		;bp+4
push ax

call draw_shape

xor ax, ax														;save state
mov es, ax ; point es to IVT base
mov ax, [es:8*4]
mov [oldisrtimer], ax ; save offset of old routine
mov ax, [es:8*4+2]
mov [oldisrtimer+2], ax

xor ax, ax														;timer hook
mov es, ax ; point es to IVT base
cli ; disable interrupts
mov word [es:8*4], timer; store offset at n*4
mov [es:8*4+2], cs ; store segment at n*4+2
sti 

xor ax, ax														;save state
mov es, ax ; point es to IVT base
mov ax, [es:9*4]
mov [oldisrkeyboard], ax ; save offset of old routine
mov ax, [es:9*4+2]
mov [oldisrkeyboard+2], ax

<<<<<<< HEAD
xor ax, ax														;keyboard hook
mov es, ax ; point es to IVT base
cli ; disable interrupts
mov word [es:9*4], kbisr; store offset at n*4
mov [es:9*4+2], cs ; store segment at n*4+2
sti 



mainloop: 	;game main loop

pieceloop:








cmp byte [reachdown], 1
jne pieceloop


mov word [xpos], 26
mov word [ypos], 3
mov word [reachdown], 0
jmp pieceloop



call draw_shape


cmp byte [gameover], 1
jne mainloop



mov ax, [oldisrtimer] ; read old offset in ax
mov bx, [oldisrtimer+2] ; read old segment in bx
cli ; disable interrupts
mov [es:8*4], ax ; restore old offset from ax
mov [es:8*4+2], bx ; restore old segment from bx
sti ; enable interrupts


mov ax, [oldisrkeyboard] ; read old offset in ax
mov bx, [oldisrkeyboard+2] ; read old segment in bx
cli ; disable interrupts
mov [es:9*4], ax ; restore old offset from ax
mov [es:9*4+2], bx ; restore old segment from bx
sti ; enable interrupts

=======
call shape3
;call draw_end_screen                         ;call subroutine to end game
>>>>>>> 6abc8d829e184dca5d1dc7c75b4ca67382981f52

mov ax, 0x4c00
int 0x21