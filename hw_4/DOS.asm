;MASMPlus 代码模板 - 纯 DOS 程序

.model small
.stack 200h
.data
	szMsg db 'Hello World!',13,10,'$'
	
.CODE
START:
	mov ax,@data
	mov ds,ax
	lea dx,szMsg
	mov ah,9
	int 21h
	
	;暂停,任意键关闭
	mov ah,1
	int 21h
	mov ah,4ch     ;结束,可以修改al设置返回码
	int 21h
	
END START