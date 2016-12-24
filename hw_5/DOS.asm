;MASMPlus 代码模板 - 纯 DOS 程序

.model small
.stack 200h
.data
	szMsg db 'Hello World!',13,10,'$'
	gradelist dw 20 dup(?)
	ranklist dw 20 dup(?)
	input_buf db '????'
	bin_num dw ?
	dec_num db '22'
.CODE
START:
	MAIN proc
		mov ax,@data
		mov ds,ax
		lea dx,szMsg
		mov ah,9
		int 21h
		
		call PrintDec
		
		mov bx,35
		mov bin_num,bx
		call BINDEC
		call PrintDec
		call DECIBIN
		call BINDEC
		call PrintDec
		
		mov bx,9
		mov bin_num,bx
		call BINDEC
		call PrintDec
		call DECIBIN
		call BINDEC
		call PrintDec
	
		mov bx,39
		mov bin_num,bx
		call BINDEC
		call PrintDec
		
		;暂停,任意键关闭
		mov ah,1
		int 21h
		mov ah,4ch     ;结束,可以修改al设置返回码
		int 21h
	MAIN endp
	
	INPUT proc
		
	INPUT endp
	
	RANKP proc
		mov cx,20
		s_rank:
			push cx
			mov si,cx		;use si to save current pos
			sub si,1		
			mov di,1			;use di to save rank
			mov cx,20
			s_cmp:
				mov bp,cx
				sub bp,1		;use bp to save the position that is being compared
				mov ax,gradelist[si]
				mov bx,gradelist[bp]
				cmp ax,bx
				ja cmp_next
				inc di
				cmp_next:
			loop s_cmp
			pop cx
			mov ranklist[si],di
		loop s_rank
		
	RANKP endp
	
	OUTPUT proc
		
	OUTPUT endp
	
	DECIBIN proc
		mov bh,dec_num[0]
		mov bl,dec_num[1]
		sub bl,'0'
		sub bh,'0'
		mov al,10
		mul bh
		mov bh,0
		add ax,bx
		mov bin_num,ax
		ret
	DECIBIN endp
	
	BINDEC proc
		;mov dx,0
		mov ax,bin_num
		mov bx,10
		div bl
		add ah,'0'
		mov dec_num[1],ah
		add al,'0'
		mov dec_num[0],al
		ret
	BINDEC endp
	
	PrintDec proc
		mov ah,2
		mov dl,dec_num[0]
		cmp dl,'0'
		jne p_next
		mov dl,' '
		p_next:
		int 21h
		mov dl,dec_num[1]
		int 21h
		mov dl,10
		int 21h
		mov dl,13
		int 21h
		ret
	PrintDec endp
END START