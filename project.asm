org 100h
jmp start


next_shape: db 'NEXT SHAPE'
score_text: db 'SCORE'
score: db '6969'
time_text: db 'TIME'
time: db '04:44'
shape: db ' '
color: db 40			;current block color
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;shapes generation data;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shape1: dw 0x40,0x40,0x00,0x00,0x00,0x00,0x40,0x40,0x00,0x00,0x00,0x00,0x40,0x40,0x40,0x40,0x40,0x40,0x03,0x03  ;L shape
shape2: dw 0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x00,0x00,0x00,0x00,0x00,0x00,0x04,0x04  ;horizontal rectangle
shape3: dw 0x40,0x00,0x00,0x00,0x00,0x00,0x40,0x00,0x00,0x00,0x00,0x00,0x40,0x00,0x00,0x00,0x00,0x00,0x05,0x05  ;vertical straight
shape4: dw 0x40,0x40,0x40,0x40,0x40,0x40,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x06,0x06  ;horizontal straight
tempcounter: dw 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




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

randGen:
push bp
mov bp, sp
push cx
push dx
push ax
rdtsc                   
xor dx,dx             
mov cx, [bp + 4]
div cx                 
mov [randNum], dl      
pop ax
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
 
nextminute:
inc word [minutes]
mov word [seconds],0
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




pop si
pop di
pop cx
pop ax
pop es
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
mov al,'R'
mov ah,00001111b
mov [es:di],ax
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
;add di, 4
;add di, 320				;check the line under


; mov al,'R'
; mov ah,00001111b
; mov [es:di],ax
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
black:
mov bx, [piecewidth]
shl bx, 1
add di, bx
mov ax, [es:di]
cmp ah, 0x00

jne is_not_black

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




start:
call clearscreen
call draw_play_area

push 4
call randGen
mov byte [randNum],0

cmp byte [randNum],3
jge setshape4
cmp byte [randNum],2
je setshape3
cmp byte [randNum],1
je setshape2
cmp byte [randNum],0
je setshape1
setshape1:
mov ax,shape1
jmp shapedecided
setshape2:
mov ax,shape2
jmp shapedecided
setshape3:
mov ax,shape3
jmp shapedecided
setshape4:
mov ax,shape4
jmp shapedecided



shapedecided:
mov word [currentshape],ax

mov bx,[currentshape+38]
push 0
push bx
call printnum
mov word [piecewidth],bx
mov bx,[currentshape+40]

push 4
push bx
call printnum
mov word [pieceheight],bx


push ax
mov ax, [xpos]		;bp+6
push ax
mov ax, [ypos]		;bp+4
push ax

call draw_shape

; push 0
; push word [pieceheight]
; call printnum

; push 4
; push word [piecewidth]
; call printnum

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



mainloop: 	;game main loop

pieceloop:



cmp byte [reachdown], 1
jne pieceloop


mov word [xpos], 26
mov word [ypos], 3
mov word [reachdown], 0
jmp pieceloop



;call draw_shape


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


mov ax, 0x4c00
int 0x21