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
	headline		db "x y",10,13,'$'		
	err_msg		db '0',' ','0',"wrong",10,13,'$'
	
.CODE
START:
	mov ax,@data
	mov ds,ax
	mov bx,0
	mov cx,9
	a:
	mov si,0
	push cx 
	mov cx,9
		s:
		mov dl,usr_table[si][bx]
		add dl,'a'
		inc bx
		mov ah,2
		int 21h
		loop s
	pop cx
	inc si
	mov dl,10
	int 21h
	mov dl,13
	int 21h
	loop a
	
	;暂停,任意键关闭
	mov ah,1
	int 21h
	mov ah,4ch     ;结束,可以修改al设置返回码
	int 21h
	
END START