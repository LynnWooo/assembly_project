;MASMPlus 代码模板 - 纯 DOS 程序
.model small

.stack 200h					;set stack segment

.data							;set data segment
	
	hwdmsg db 'Hello World!',13,10,'$'		;helloworldmessage
	
.code
START:
	;clear the screen
	mov al,03h
	int 10h
	
	
	;set WORD position
	mov ah,2
	mov bh,0
	mov dh,8				;set row pos
	mov dl,32			;set line pos
	int 10h
	
	;show words at positon set
	mov ax,@data
	mov ds,ax
	lea dx,hwdmsg
	mov ah,9
	int 21h
	
	;暂停,任意键关闭
	mov ah,1
	int 21h
	mov ah,4ch     ;结束,可以修改al设置返回码
	int 21h
	
END START