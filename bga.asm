;Credits BGA
;Code by DT9025A

assume cs:code,ds:data,ss:stack

;栈段
stack segment
	STACKSPACE db 1024 dup(0)
stack ends
	
;数据段
data segment
	;基础偏移: 显示区域最左边
	ZOFFSET db 24
	
	;两种0, 偷懒不想用算法实现
	Z0S1 db '0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0   ',0
	Z1S0 db ' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  ',0
	;每页0的停留时间
	ZERODELAY dw 80
	
	;显示信息
	;行,列,行,列,...  列未加基础偏移
	;第一页
	P1OFFSET db 2,1,4,18
	P1L1 db 'THE BMS OF FIGHTERS ULTIMATE',0
	P1L2 db 'Smith au Lait',0
	;第三页
	P3OFFSET db 6,1,8,21
	P3L3 db 'Music: Frums',0
	P3L4 db 'BGA: Frums',0
	;第五页
	P5OFFSET db 10,1,12,23
	P5L5 db 'Genre: OTHER TIME',0
	P5L6 db 'BPM: 179',0
	;第七页
	P7OFFSET db 14,1
	P7L7 db 'Credits',0
	;每页信息的停留时间
	PAGEDELAY dw 2000
	
	;音符记录顺序从上到下, 列未加基础偏移
	;第一个出现的音符的偏移
	GROUP1OFFSET db 4,14,5,10,6,8,7,8,8,6,9,20,10,18,11,16,12,16,13,16
	;第二个出现的音符的偏移
	;其实只是反序的关系
	;但还是懒
	GROUP2OFFSET db 4,16,5,16,6,16,7,18,8,20,9,6,10,8,11,8,12,10,13,14
	;单八分音符, 偷懒
	HFNT2 db 0dh,0dh,0 
	HFNT6 db 0dh,0dh,0dh,0dh,0dh,0dh,0
	HFNT8 db 0dh,0dh,0dh,0dh,0dh,0dh,0dh,0dh,0
	;双八分音符
	QTNT2 db 0eh,0eh,0
	QTNT6 db 0eh,0eh,0eh,0eh,0eh,0eh,0
	QTNT8 db 0eh,0eh,0eh,0eh,0eh,0eh,0eh,0eh,0
	
	;音符圆内图案, 偷懒
	;图案的偏移, 列未加基础偏移
	SHAPEOFFSET db 7,14,8,12,9,12,10,14
	; 'Ω' O
	OMEGA4 db 0eah,0eah,0eah,0eah,0
	OMEGA8 db 0eah,0eah,0eah,0eah,0eah,0eah,0eah,0eah,0
	; '.' D
	DOT4 db '....',0
	DOT8 db '........',0
	; '≈' P
	PEQU4 db 0f7h,0f7h,0f7h,0f7h,0
	PEQU8 db 0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0
	; '±' PM
	PORM4 db 0f1h,0f1h,0f1h,0f1h,0
	PORM8 db 0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0
	;O,D,P停留时间
	SHAPEDELAY_ODP dw 120
	;PM停留时间
	SHAPEDELAY_PM dw 40
	
	;括号偏移, 列未加基础偏移
	BRACKETOFFSET db 4,4,4,26,5,3,5,27,6,3,6,27,7,2,7,28,8,2,8,28,9,2,9,28,10,2,10,28,11,3,11,27,12,3,12,27,13,4,13,26
	;三级括号
	BRACKET1 db 0b0h,0b0h,0
	BRACKET2 db 0b1h,0b1h,0
	BRACKET3 db 0b2h,0b2h,0
	;三级括号在O,D切换时间
	BRACKETDELAY_OD_3 dw 40
	;二级括号在PORM切换时间
	BRACKETDELAY_PM_2 dw 20
data ends

;程序段
code segment
;程序入口
start:
	;初始化栈
	;在stack段, 长度1024
	mov ax,stack
	mov ss,ax
	mov sp,1024
	;第一段
	call cls
	mov bx,offset PAGEDELAY
	mov ah,0
	;显示文字
	call music_info
	call delay_offset
	;画0
	call fz_print_series
	;下一页文字
	inc ah
	call cls
	;显示文字
	call music_info
	call delay_offset
	;画0
	call fz_print_series
	;下一页文字
	inc ah
	call cls
	;显示文字
	call music_info
	call delay_offset
	;画0
	call fz_print_series
	;下一页文字
	inc ah
	call cls
	;显示文字
	call music_info
	call delay_offset
	;画0
	call fz_print_series
	;第二段
	call cls
	;动画
	call shape_anim
	call shape_anim
	call shape_anim
	call shape_anim
	mov ax,4c00h
	int 21h

;-------------------;
;子函数: shape_anim ;
;那个圆里面的动画   ;
;一遍               ;
;-------------------;
shape_anim proc
	push ax
	push bx
	push cx
	mov ah,0
	;画圆
	call draw_circle
	call shape_anim_odp
	call shape_anim_odp
	mov bx,offset SHAPEDELAY_ODP
	mov ah,0
	call draw_shape
	call delay_offset
	mov ah,1
	call draw_shape
	call delay_offset
	call shape_anim_odp
	mov ah,1
	call draw_circle
	mov ah,0
	call draw_shape
	call delay_offset
	mov ah,1
	call draw_shape
	call delay_offset
	mov cx,7
	mov bx,offset SHAPEDELAY_PM
SHAPE_ANIM_PM_LOOP:
	push cx
	mov ah,3
	call draw_shape
	call delay_offset
	mov ah,1
	call draw_shape
	call delay_offset
	pop cx
	loop SHAPE_ANIM_PM_LOOP
	pop cx
	pop bx
	pop ax
	ret
shape_anim endp

;----------------------;
;子函数: shape_anim_odp;
;omega dot pequal      ;
;一遍                  ;
;----------------------;
shape_anim_odp proc
	push ax
	push bx
	mov bx,offset SHAPEDELAY_ODP
	mov ah,0
	call draw_shape
	call delay_offset
	mov ah,1
	call draw_shape
	call delay_offset
	mov ah,2
	call draw_shape
	call delay_offset
	pop bx
	pop ax
	ret
shape_anim_odp endp

;-------------------;
;子函数: draw_shape ;
;画那个圆里的图案   ;
;AH: 哪个图案       ;
;0:O 1:D 2:P 3:PM   ;
;-------------------;
draw_shape proc
	push ax
	push bx
	push dx
	push si
	push bp

	mov bp,sp
	test ah,ah
	;0 OMEGA
	jz DRAWSHAPE_OMEGA
	dec ah
	test ah,ah
	;1 DOT
	jz DRAWSHAPE_DOT
	dec ah
	test ah,ah
	;2 PEQU
	jz DRAWSHAPE_PEQU
	mov ax,offset PORM4
	push ax
	jmp DRAWSHAPE_CONTINUE
	
DRAWSHAPE_OMEGA:
	mov ax,offset OMEGA4
	push ax
	jmp DRAWSHAPE_CONTINUE
DRAWSHAPE_DOT:
	mov ax,offset DOT4
	push ax
	jmp DRAWSHAPE_CONTINUE
DRAWSHAPE_PEQU:
	mov ax,offset PEQU4
	push ax
	
DRAWSHAPE_CONTINUE:
	mov ax,data
	mov ds,ax
	mov bx,offset ZOFFSET
	mov ch,ds:[bx]
	mov cl,00001111b
	mov bx,offset SHAPEOFFSET
	mov si,ss:[bp-2]
	;发现DRAWCIRCLE_SHOWBX可以复用
	call DRAWCIRCLE_SHOWBX
	add si,5
	call DRAWCIRCLE_SHOWBX
	call DRAWCIRCLE_SHOWBX
	sub si,5
	call DRAWCIRCLE_SHOWBX
	
	;恢复栈
	pop ax
	
	pop bp
	pop si
	pop dx
	pop bx
	pop ax
	ret
draw_shape endp

;-------------------;
;子函数: draw_circle;
;画那个圆           ;
;AH: 哪个音符在前   ;
;0:单八分音符在前/HF;
;-------------------;
draw_circle proc
	push ax
	push bx
	push dx
	push bp
	
	;SS:[SP-2] 音符1 SS:[SP-4] 音符2
	mov bp,sp
	test ah,ah
	jz DRAWCIRCLE_HFNT
	mov ax,offset QTNT2
	push ax	;QTNT2在SS:SP
	mov ax,offset HFNT2
	push ax	;HFNT2在SS:SP-2
	jmp DRAWCIRCLE_CONTINUE
	
DRAWCIRCLE_HFNT:
	mov ax,offset HFNT2
	push ax
	mov ax,offset QTNT2
	push ax
	
DRAWCIRCLE_CONTINUE:
	mov ax,data
	mov ds,ax
	mov bx,offset ZOFFSET
	mov ch,ds:[bx]
	mov cl,00001111b
	;Credits
	mov bx,offset P1OFFSET
	mov dl,ds:[bx+1]
	mov dh,ds:[bx]
	add dl,ch
	mov si,offset P7L7
	call show_str
	;Frums
	mov dl,26
	mov dh,15
	add dl,ch
	mov si,offset P3L4
	add si,5
	call show_str
	;音符1
	mov bx,offset GROUP1OFFSET
	mov si,ss:[bp-2]
	call DRAWCIRCLE_SHOWBP
	;音符2
	mov bx,offset GROUP2OFFSET
	mov si,ss:[bp-4]
	call DRAWCIRCLE_SHOWBP
	;两次popax弹出不同音符偏移
	pop ax
	pop ax
	pop si
	pop dx
	pop bx
	pop ax
	ret
draw_circle endp

DRAWCIRCLE_SHOWBP:
;函数内子函数
;显示BP相关数据
	;行1
	call DRAWCIRCLE_SHOWBX
	;行2
	add si,3
	call DRAWCIRCLE_SHOWBX
	;行3
	add si,7
	call DRAWCIRCLE_SHOWBX
	;行4
	sub si,7
	call DRAWCIRCLE_SHOWBX
	;行5
	call DRAWCIRCLE_SHOWBX
	;行6
	call DRAWCIRCLE_SHOWBX
	;行7
	call DRAWCIRCLE_SHOWBX
	;行8
	add si,7
	call DRAWCIRCLE_SHOWBX
	;行9
	sub si,7
	call DRAWCIRCLE_SHOWBX
	;行10
	sub si,3
	call DRAWCIRCLE_SHOWBX
	ret
DRAWCIRCLE_SHOWBX:
;函数内子函数
;显示BX相关数据
	mov dh,ds:[bx]
	mov dl,ds:[bx+1]
	add dl,ch
	call show_str
	add bx,2
	ret


;------------------;
;子函数: music_info;
;输出开头段音乐信息;
;AH: 分段(从0)     ;
;------------------;
music_info proc
	push ax	;传参, 传基址
	push bx	;变址
	push cx	;偏移, 颜色
	
	push ax
	mov cl,00001111b
	mov ax,data
	mov ds,ax
	mov bx,offset ZOFFSET
	mov ch,ds:[bx]
	pop ax
	test ah,ah
	jz MUSICINFO_SEG1
	dec ah
	test ah,ah
	jz MUSICINFO_SEG2
	dec ah
	test ah,ah
	jz MUSICINFO_SEG3
	
	;SEG4
	mov bx,offset P7OFFSET
	;Credits
	mov dl,ds:[bx+1]
	mov dh,ds:[bx]
	add dl,ch
	mov si,offset P7L7
	call show_str
	
	;SEG3
MUSICINFO_SEG3:
	mov bx,offset P5OFFSET
	;Genre
	mov dh,ds:[bx]
	mov dl,ds:[bx+1]
	add dl,ch
	mov si,offset P5L5
	call show_str
	;BPM
	mov dh,ds:[bx+2]
	mov dl,ds:[bx+3]
	add dl,ch
	mov si,offset P5L6
	call show_str
	
	;SEG2
MUSICINFO_SEG2:
	mov bx,offset P3OFFSET
	;Music
	mov dh,ds:[bx]
	mov dl,ds:[bx+1]
	add dl,ch
	mov si,offset P3L3
	call show_str
	;BGA
	mov dh,ds:[bx+2]
	mov dl,ds:[bx+3]
	add dl,ch
	mov si,offset P3L4
	call show_str
	
	;SEG1
MUSICINFO_SEG1:
	mov bx,offset P1OFFSET
	;THE
	mov dh,ds:[bx]
	mov dl,ds:[bx+1]
	add dl,ch
	mov si,offset P1L1
	call show_str
	;Smith
	mov dh,ds:[bx+2]
	mov dl,ds:[bx+3]
	add dl,ch
	mov si,offset P1L2
	call show_str
	pop cx
	pop bx
	pop ax
	ret
music_info endp


;--------------;
;子函数: cls   ;
;清屏          ;
;--------------;
cls proc
	push bx
	push cx
	push dx
	push es
	mov bx,0b800h
	mov es,bx
	mov bx,0
	mov cx,4000
CLS_LOOP:
	mov dl,0
	mov dh,0
	mov es:[bx],dx        
	add bx,2
	loop CLS_LOOP
	pop es
	pop dx
	pop cx
	pop bx
	ret
cls endp

;------------------------;
;子函数: delay_offset    ;
;延迟偏移地址在BX中的时间;
;BX:16位延迟时间偏移地址 ;
;------------------------;
delay_offset proc
	push ax
	push bx
	push cx
	push dx
	mov ax,data
	mov ds,ax
	mov ax,ds:[bx]
	mov cx,1000
	mul cx
	mov cx,dx
	mov dx,ax
	mov ax,8600h
	int 15h
	pop dx
	pop cx
	pop bx
	pop ax
	ret
delay_offset endp

;---------------------------;
;子函数: fz_print_1_line    ;
;显示一行0                  ;
;CL: 循环变量,决定位置和属性;
;CH: 决定第一行0的属性      ;
;---------------------------;
fz_print_1_line proc
	push ax
	push bx
	push cx
	push dx
	mov ax,cx
	test ch,ch
	jz FZ_DIV
	add ax,1
FZ_DIV:
	mov dl,2
	div dl
	test ah,ah
	jz FZ_SF
	mov si,offset Z1S0
	jmp FZ_PRINT
FZ_SF:
	mov si,offset Z0S1
FZ_PRINT:
	mov ax,data
	mov ds,ax
	mov bx,offset ZOFFSET
	mov dh,cl
	mov dl,ds:[bx]
	mov cl,00001111b
	call show_str
	pop dx
	pop cx
	pop bx
	pop ax
	ret
fz_print_1_line endp
	
;-----------------------;
;子函数: fz_print_series;
;显示8张0               ;
;-----------------------;
fz_print_series proc
	push ax
	push bx
	push cx
	mov cx,8
FZ_PR_LOOP:
	push cx
	mov ax,cx
	inc ax
	mov ch,2
	div ch
	mov ch,ah
	mov cl,10h
FZ_PR_1L:
	call fz_print_1_line
	mov ch,0
	jcxz FZ_PR_O
	mov ch,ah
	dec cx
	jmp short FZ_PR_1L
FZ_PR_O:
	mov bx,offset ZERODELAY
	call delay_offset
	;call delay125ms
	pop cx
	loop FZ_PR_LOOP
	pop cx
	pop bx
	pop ax
	ret
fz_print_series endp

;-------------------;
;子函数: show_str   ;
;显示以0结尾的字符串;
;DH: 行数           ;
;DL: 列数           ;
;CL: 颜色           ;
;DS:SI 字符串地址   ;
;-------------------;
show_str proc
	;保存用到的寄存器值
	push ax
	push bx
	push di
	push cx
	push dx
	push es
	push si
	;计算行
	mov al,0a0h  ;每行的偏移是0ah
	dec dh  ;第一行的地址是0b800h
	mul dh
	mov bx,ax  ;转移ax数据以便下一次计算
	;计算列
	mov ax,2  ;每个字符及显示属性占2字节
	dec dl  ;第一列的偏移是0
	mul dl
	;计算总偏移
	add ax,bx
	;置偏移
	mov di,ax
	mov ax,0b800h
	mov es,ax  ;es:[di]定位数据
	mov ch,0  ;ch置零以便jcxz
	mov al,cl  ;转移设置项,作用同上
SHOW_STR_LOOP:
	mov cl,ds:[si]  ;data段数据移动一个字节到cl
	jcxz SHOW_STR_OUT  ;若遇到结尾则跳出子程序
	mov byte ptr es:[di],cl  ;传输字符
	mov byte ptr es:[di+1],al  ;传输显示属性
	inc si  ;字符指针+1
	add di,2  ;显示缓冲区指针+2
	jmp short SHOW_STR_LOOP  ;继续循环
SHOW_STR_OUT:
	;恢复寄存器值
	pop si
	pop es
	pop dx
	pop cx
	pop di
	pop bx
	pop ax
	ret
show_str endp

code ends
end start

