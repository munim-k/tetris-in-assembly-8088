org 100h
jmp start

game_over_text: db 'GAME OVER'
next_shape: db 'NEXT SHAPE'
score_text: db 'SCORE'
score_digit: dw 0
time_text: db 'TIME'
xpos: dw 26	;current block xpos
ypos: dw 3	;current block ypos
piecewidth: dw 3
pieceheight: dw 3
temp: dd 0
oldisrtimer:  dd 0
oldisrkeyboard: dd 0
tickcount: dw 0
totaltimer: dw 0
gameover: db 0
reachdown: dw 0
seconds: dw 0
minutes: dw 0
randNum: db 0
currentshape: dw 0
nextshape: dw 0
nextshapeXpos: dw 64
nextshapeYpos: dw 18
linebool: dw 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;shapes generation data;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shape1: dw 0x00,0x00,0x00,0x00,0x00,0x00,0x40,0x40,0x00,0x00,0x00,0x00,0x40,0x40,0x40,0x40,0x40,0x40  ;L shape
shape2: dw 0x50,0x50,0x50,0x50,0x00,0x00,0x50,0x50,0x50,0x50,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00  ;horizontal rectangle
shape3: dw 0x20,0x20,0x00,0x00,0x00,0x00,0x20,0x20,0x00,0x00,0x00,0x00,0x20,0x20,0x00,0x00,0x00,0x00  ;vertical straight
shape4: dw 0x10,0x10,0x10,0x10,0x10,0x10,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00  ;horizontal straight
shape5: dw 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30  ;reverse L shape
tempcounter: dw 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Main Screen Text;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameName: db 'TREETRIS'
press_any_key: db 'Press Any Key to Play'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

checkline:            ;bp+4 has di
push bp
mov bp, sp
push ax
push es
push cx


mov word [linebool], 1
mov ax, 0xb800
mov es, ax
mov cx, 43
;mov di, [bp+4]

loopline:
xor ax, ax
mov ax, [es:di]
cmp ah, 0x00

je exitfunc


add di, 2
loop loopline

jmp skipfunc

exitfunc:
mov word [linebool], 0


skipfunc:
pop cx
pop es
pop ax
pop bp
ret 


deleteline:
push bp
mov bp, sp
push ax
push cx
push dx
push es
push ds
push si
push di
push bx

call add_score

mov ax, 0xb800
mov ds, ax
mov es, ax


mov di, [bp+4]
mov si, [bp+4]
sub si, 160

mov cx, 13
loopity:

push cx
xor cx, cx
mov cx, 44
rep movsw
pop cx


sub si, 248
sub di, 248

loop loopity

pop bx
pop di
pop si
pop ds
pop es
pop dx
pop cx
pop ax
pop bp
ret 



check_line_completion:

push bp
mov bp, sp
push ax
push cx
push es
push di

mov ax, 0xb800
mov es, ax
mov di, 492
mov cx, 19


loopscreen:
xor ax, ax
mov ax, [es:di]
;mov word [es:di], 0x4444
cmp ah, 0x00

je skipline

push di
call checkline
pop di

cmp word [linebool], 1            ;1 if line full
jne skipline                ;if 0, skip line


push di
call deleteline                ;else call deleteline
pop di


skipline:
add di, 160
loop loopscreen


pop di
pop es
pop cx
pop ax
pop bp
ret

randGen:
push bp
mov bp, sp
push cx
push dx
rdtsc                  
xor dx,dx               
mov cx, [bp + 4]
div cx                  
mov byte [randNum], dl      
pop dx
pop cx
pop bp
ret 2

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

remove_second:
push ax
push es
mov ax,0xb800
mov es,ax
mov ax,0x0720
mov [es:1740],ax
mov [es:1742],ax 
pop es
pop ax
ret

nextminute:
inc word [minutes]
mov word [seconds],0
call remove_second
push 1730
push word [minutes]
call printnum
jmp _jmpback

nextsecond:

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

mov di,492
mov al,' '
mov ah,0
mov si,0
play_area:
mov cx,44
cld                                 ;play area black box
rep stosw
add di,72
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

push 936
mov ax,[score_digit]
push ax
call printnum

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




pop si
pop di
pop cx
pop ax
pop es
ret

draw_main_screen:
mov ax,0xb800
mov es,ax

mov di,978
mov al,' '
mov ah,70
mov si,0
start_area:
mov cx,60
cld                                 ;end screen area red box
rep stosw
add di,40
inc si
cmp si,10
jbe start_area

push 35
push 8
push 01001111b
push GameName
push 8
call print

push 28
push 12
push 11001111b
push press_any_key
push 21
call print
mov ah,00h
int 0x16

call clearscreen

ret



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
push 5
call print


mov ax,23
push ax
mov ax,12
push ax
mov ax,01001111b
push ax                              ;time game over text
mov ax,time_text
push ax
push 4
call print

push 1980                                       ;time game over 
mov ax,[minutes]
push ax
call printnum
mov ah,0x07
mov al,':'
mov [es:1982],ax
push 1984                                       ;time game over 
mov ax,[seconds]
push ax
call printnum

ret

draw_black_shape:
push bp
mov bp, sp
push ax
push bx
push si
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
mov al, ' '
mov ah,40h ;attribute
mov word [tempcounter],0
mov si,0
mov bx,[bp+8]
_main_black_loop:
mov cx, 6
lineloopZ:
mov ah,[bx+si]
add si,2
cmp ah,0x00
je dontprint
mov ah,0x00
mov [es:di], ax
dontprint:
add di, 2
loop lineloopZ
add di,148
inc word [tempcounter]
cmp word [tempcounter],2
jbe _main_black_loop

pop cx
pop di
pop es
pop si
pop bx
pop ax
pop bp
ret 6



draw_shape:
push bp
mov bp, sp
push ax
push bx
push si
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
mov al, ' '
mov ah,40h ;attribute
mov word [tempcounter],0
mov si,0
mov bx,[bp+8]
_mainloop:
mov cx, 6
lineloopin:
mov ah,[bx+si]
add si,2
cmp ah,0x00
je dontprint_
mov [es:di], ax
dontprint_:
add di, 2
loop lineloopin
add di,148
inc word [tempcounter]
cmp word [tempcounter],2
jbe _mainloop

pop cx
pop di
pop es
pop si
pop bx
pop ax
pop bp
ret 6

add_score:
add word [score_digit],100
ret


move_left:
push bp
mov bp, sp
push ax

mov ax, [currentshape]	;att
push ax
mov ax, [xpos]
push ax,
mov ax, [ypos]
push ax
call draw_black_shape

mov ax, [currentshape]
push ax
mov ax, [xpos]


mov al, 80
mov bx, [ypos]             ;left boundary check
mov [temp], bx

mul byte [temp] ;ypos under shape
add ax, [xpos] ;xpos
shl ax, 1
mov di, ax
sub di,2
; mov al,'L'
; mov ah,00001111b
; mov [es:di],ax
xor ax, ax
mov ax, [es:di]
cmp ah, 0x00
jne skip2


mov ax, [xpos]
sub ax, 2
mov [xpos], ax

skip2:
mov ax, [xpos]
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

mov ax, [currentshape]
push ax
mov ax, [xpos]
push ax,
mov ax, [ypos]
push ax
call draw_black_shape

mov ax, [currentshape]
push ax
mov ax, [xpos]

mov al, 80
mov bx, [ypos]             ;left boundary check
mov [temp], bx
mul byte [temp] ;ypos under shape
add ax, [xpos] ;xpos
add ax,[piecewidth]
shl ax, 1
mov di, ax
add di,4
; mov al,'L'
; mov ah,00001111b
; mov [es:di],ax
xor ax, ax
mov ax, [es:di]
cmp ah, 0x00
jne skip

mov ax, [xpos]
add ax, 2

mov [xpos], ax

skip:
mov ax, [xpos]
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

mov ax, [currentshape]
push ax
mov ax, [xpos]
push ax,
mov ax, [ypos]
push ax
call draw_black_shape

mov ax, [currentshape]
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
		                            	;check the line under
; mov al,'L'
; mov ah,00001111b                  ;bounds checker
; mov [es:di],ax
;;if es:di is not black inc ax, else keep ax same, place object and call next shape
xor ax, ax
mov ax, [es:di]
cmp ah, 0x00
jne is_not_black

;;second check
black:
mov bx, [piecewidth]
shl bx, 1
add di, bx
; mov al,'R'
; mov ah,00001111b
; mov [es:di],ax
mov ax, [es:di]
cmp ah, 0x00
jne is_not_black

thirdcheck:
cmp word [piecewidth],5
jne pass
sub di,4
; mov al,'M'
; mov ah,00001111b                  ;bounds checker
; mov [es:di],ax
mov ax, [es:di]
cmp ah, 0x00
jne is_not_black
sub di,2
; mov al,'M'
; mov ah,00001111b                  ;bounds checker
; mov [es:di],ax
mov ax, [es:di]
cmp ah, 0x00
jne is_not_black
 


pass:
pop ax		;original ypos 
add ax, 1
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

_assignshape:
cmp byte [randNum],4
jge _setshape5
cmp byte [randNum],3
je _setshape4
cmp byte [randNum],2
je _setshape3
cmp byte [randNum],1
je _setshape2
cmp byte [randNum],0
je _setshape1
_setshape1:
mov ax,shape1
jmp _shapedecided
_setshape2:
mov ax,shape2
jmp _shapedecided
_setshape3:
mov ax,shape3
jmp _shapedecided
_setshape4:
mov ax,shape4
jmp _shapedecided
_setshape5:
mov ax,shape5
jmp _shapedecided

_shapedecided:

ret


assignshape:
cmp byte [randNum],4
jge setshape5
cmp byte [randNum],3
je setshape4
cmp byte [randNum],2
je setshape3
cmp byte [randNum],1
je setshape2
cmp byte [randNum],0
je setshape1
setshape1:
mov ax,shape1
mov word [piecewidth],5
mov word [pieceheight],3
jmp shapedecided
setshape2:
mov ax,shape2
mov word [piecewidth],3
mov word [pieceheight],2
jmp shapedecided
setshape3:
mov ax,shape3
mov word [piecewidth],1
mov word [pieceheight],3
jmp shapedecided
setshape4:
mov ax,shape4
mov word [piecewidth],5
mov word [pieceheight],1
jmp shapedecided
setshape5:
mov ax,shape5
mov word [piecewidth],5
mov word [pieceheight],3
jmp shapedecided
shapedecided:

ret

check_top_row_for_gameend:
push ax
push di
push cx

mov ax,0xb800
mov es,ax
mov di,492
mov cx,44
check_loop:
mov ax,[es:di]
add di,2
cmp ah,0x00
jne game_over_kardo
loop check_loop
jmp end_func
game_over_kardo:
mov byte [gameover],1
end_func:
pop cx
pop di
pop ax
ret



start:
call clearscreen
call draw_main_screen
call draw_play_area

mov word [score_digit],0

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

xor ax, ax														;keyboard hook
mov es, ax ; point es to IVT base
cli ; disable interrupts
mov word [es:9*4], kbisr; store offset at n*4
mov [es:9*4+2], cs ; store segment at n*4+2
sti 


push 5
call randGen
mov word [randNum],4               ;manually select first shape
call assignshape
mov word [currentshape],ax


push word [pieceheight]
pop ax
                                              ;; unexplainable phenomenon
push word [piecewidth]
pop ax


push 5
call randGen
call assignshape
mov word [nextshape],ax

mov ax,[nextshape]
push ax
mov ax,[nextshapeXpos]
push ax
mov ax,[nextshapeYpos]
push ax
call draw_shape

mainloop: 	;game main loop

pieceloop:

cmp byte [reachdown], 1
jne pieceloop
call check_line_completion
call assignshape
mov ax,[nextshape]
mov word [currentshape], ax

mov word [xpos], 26
mov word [ypos], 3
mov word [reachdown], 0
push 5
call randGen
call _assignshape
mov word [nextshape],ax

mov ax,[currentshape]
push ax
mov ax,[nextshapeXpos]
push ax
mov ax,[nextshapeYpos]
push ax
call draw_black_shape


mov ax,[nextshape]
push ax
mov ax,[nextshapeXpos]
push ax
mov ax,[nextshapeYpos]
push ax
call draw_shape


push 936
mov ax,[score_digit]
push ax
call printnum

call check_top_row_for_gameend
push 0
push word [gameover]
call printnum

cmp byte [gameover], 1
jne mainloop
jmp end_program


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

end_program:
call draw_end_screen
mov ax, 0x4c00
int 0x21