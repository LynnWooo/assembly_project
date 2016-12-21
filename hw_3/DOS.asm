;MASMPlus 代码模板 - 纯 DOS 程序

.model small
.stack 200h
.data
	usr_table 	db 7,2,3,4,5,6,7,8,9
					db 2,4,7,8,10,12,14,16,18
					db 3,6,9,12,15,18,21,24,27 
					db 4,8,12,16,7,24,28,32,36 
					db 5,10,15,20,25,30,35,40,45 
					db 6,12,18,24,30,7,42,48,54 
					db 7,14,21,28,35,42,49,56,63 
					db 8,16,24,32,40,48,56,7,72 
					db 9,18,27,36,45,54,63,72,81
	
	corr_table	db 1,2,3,4,5,6,7,8,9
					db 2,4,6,8,10,12,14,16,18
					db 3,6,9,12,15,18,21,24,27 
					db 4,8,12,16,20,24,28,32,36 
					db 5,10,15,20,25,30,35,40,45 
					db 6,12,18,24,30,36,42,48,54 
					db 7,14,21,28,35,42,49,56,63 
					db 8,16,24,32,40,48,56,64,72 
					db 9,18,27,36,45,54,63,72,81	
	
	;debug_number	db "00	$"
	headline		db "x y",10,13,'$'		
	err_msg		db '0',' ','0',"	error",10,13,'$'
	;debug_msg	db	"printed!",10,13,'$'
.CODE
START:
	;basic settings
	mov ax,@data
	mov ds,ax
	
	;print basic info
	lea dx,headline
	mov ah,9
	int 21h
	;set outer loop
	mov cx,9
	mov si,0
	s:
	;set innner loop,use stack to save cx_value to achive 2 loops
	mov di,0
	push cx
	mov cx,9
		a:
		;set error message
		mov ax,si
		add al,'1'
		mov err_msg[0],al
		mov ax,di
		add al,'1'
		mov err_msg[2],al
		;calculate current position in array,save value in bx
		mov ax,si
		mov bl,9
		mul bl
		mov bx,di
		add al,bl
		mov bx,0
		mov bl,al
		;get user value and correct value
		mov al,usr_table[bx]
		mov bp,ax
		mov al,corr_table[bx]
		mov dx,ax
		cmp bp,dx
		;do not print anything if they are equal
		je next
		lea dx,err_msg
		mov ah,9
		int 21h
		
		next:
		inc di
		loop a
	pop cx
	inc si
	loop s
	
	;暂停,任意键关闭
	mov ah,1
	int 21h
	mov ah,4ch     ;结束,可以修改al设置返回码
	int 21h

END START

