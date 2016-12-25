;MASMPlus 代码模板 - 纯 DOS 程序

.model small

.stack 200h

.data
	initMsg 	db 'select function:',13,10			;initial message
				db	'i = input',10,13
				db	'r = show student rank',10,13
				db 's = show student name in rank sequence',10,13
				db	'q = quit',10,13,'$'
	gradelist db 21 dup(?)								;Array to save grade,gradelist[20] = 1 means grade inited succesfully
	ranklist db 21 dup(?)								;Array to save rank,ranklist[20] = 1 means grade inited succesfully
	ipmsg db 'INPUT student grades below:(divide with SPACE,end with ENTER)',10,13	;input message
	input_buf db 61 dup('$')																			;INPUT buffer
	ofmsg db 13,10,'Input Overflow!',13,10,'$'													;INPUT overflow message,shows when there's no more '$' in INPUT buffer
	bin_num dw ?
	dec_num db '00'
	iwmsg db 'Something wrong with your input!',10,13,'$'		;wrong input message
	ismsg db 'Input success!',10,13,'$'								;show when parse finishes
	rwmsg db 'Grade list has not been initialized yet!',10,13,'$'	;rank wrong message
	rsmsg db 'No.  Grade  Rank',10,13,'$'											;rank SUCCESS message (head line)
	ssmsg db 'Rank  No.  Grade',10,13,'$'
.CODE
START:
	MAIN proc
		;print init message
		mov ax,@data
		mov ds,ax
		mov ax,3
		;int 10h			;clear screen
		lea dx,initMsg
		mov ah,9
		int 21h
		
		;get user command and do jmp instruction
		get_cmd:
		mov ah,0
		int 16h
		cmp al,'i'
		je INPUT
		cmp al,'s'
		je SEQUENCE
		cmp al,'r'
		je SHOWRANK
		cmp al,'q'
		je quit
		jmp get_cmd		;if instruction is invalid, init again
		
		quit:
		mov ah,4ch     ;结束,可以修改al设置返回码
		int 21h
	MAIN endp
	
	INPUT proc
		;clear screen and show hint message
		mov cx,61
		in_init:
		mov di,61
		sub di,cx
		mov input_buf[di],'$'
		loop in_init
		mov ax,3
		int 10h
		lea dx,ipmsg
		mov ah,9
		int 21h
		
		;use following loop to get user input
		mov si,0			;use si to save position in input_buf
		s_input:			;get user input
		mov ah,0
		int 16h
		cmp al,'9'
		ja in_print
		cmp al,'0'
		jnb valid
		cmp al,' '
		je valid
		cmp al,13
		je in_enter
		cmp al,8
		jne in_print
		
		backspace:
			cmp si,0
			je in_print
			mov input_buf[si-1],'$'
			sub si,1
			jmp in_print
		valid:
			mov input_buf[si],al
			inc si
			jmp in_print
		in_print:
			mov ax,3
			int 10h
			lea dx,ipmsg
			mov ah,9
			int 21h
		cont_loop:
		cmp si,61
		jb s_input
		jnb MAIN
		in_enter:
			mov ax,3
			int 10h
			lea dx,ipmsg
			mov ah,9
			int 21h
			mov dl,10
			mov ah,2
			int 21h
			mov dl,13
			int 21h
			;jmp MAIN
			jmp PARSEINPUT
	INPUT endp
	
	RANKP proc
		mov cx,20
		s_rank:
			mov si,20
			sub si,cx
			push cx
			mov al,1			;use ax to save rank
			mov cx,20
			s_cmp:
				mov bx,20
				sub bx,cx
				mov dl,gradelist[si]
				mov dh,gradelist[bx]
				cmp dl,dh
				jnb cmp_next
				add al,1
				cmp_next:
			loop s_cmp
			pop cx
			mov ranklist[si],al
		loop s_rank
		ret
	RANKP endp
	
	PARSEINPUT proc
		mov cx,20
		mov di,0						;use di to save current position in INPUTbuffer
		parse_s:
			mov ah,input_buf[di]
			mov al,input_buf[di+1]
			mov dh,input_buf[di+2]
			cmp ah,'0'
			jb parse_error
			cmp al,'0'
			jb parse_1
			cmp dh,'0'
			jb parse_2
			jmp parse_error
			
		parse_1:
			mov si,20
			sub si,cx
			mov dec_num[0],'0'
			mov dec_num[1],ah
			call DECIBIN
			mov ax,bin_num
			mov gradelist[si],al
			add di,2
			loop parse_s
			jmp parse_nxstep
			
		parse_2:
			mov si,20
			sub si,cx
			mov dec_num[0],ah
			mov dec_num[1],al
			call DECIBIN
			mov ax,bin_num
			mov gradelist[si],al
			add di,3
			loop parse_s
			jmp parse_nxstep
			
		parse_error:
			lea dx,iwmsg
			mov ah,9
			int 21h
			jmp MAIN
		
		parse_nxstep:
			mov gradelist[20],1
			lea dx,ismsg
			mov ah,9
			int 21h
			jmp MAIN
	PARSEINPUT endp
	
	SHOWRANK proc
		cmp gradelist[20],1
		jne r_error
		
		call RANKP
		mov ax,3
		int 10h
		lea dx,rsmsg
		mov ah,9
		int 21h
		mov cx,20
		s_sr:
		mov si,21
		sub si,cx
		mov dl,' '
		mov ah,2
		int 21h
		mov bin_num,si
		call BINDEC
		call PrintDec
		mov ah,2
		mov dl,' '
		int 21h
		int 21h
		int 21h
		int 21h
		int 21h
		sub si,1
		mov dx,0
		mov dl,gradelist[si]
		mov bin_num,dx
		call BINDEC
		call PrintDec
		mov ah,2
		mov dl,' '
		int 21h
		int 21h
		int 21h
		int 21h
		sub si,1
		mov dx,0
		mov dl,ranklist[si]
		mov bin_num,dx
		call BINDEC
		call PrintDec
		call PrintLn
		loop s_sr
		
		mov ah,1
		int 21h
		jmp main
		
		r_error:
			lea dx,rwmsg
			mov ah,9
			int 21h
			jmp MAIN
	SHOWRANK endp
	
	SEQUENCE proc
		cmp gradelist[20],1
		jne SHOWRANK
		
		mov cx,20
		mov ax,3
		int 10h
		lea dx,ssmsg
		mov ah,9
		int 21h
		
		seq_display:
			mov si,21
			sub si,cx
			push cx
			mov cx,20
			seq_cmp:
				mov di,20
				sub di,cx
				mov ax,si
				mov ah,ranklist[di]
				cmp ah,al
				jne seq_next
				
				mov ah,2
				mov dl,' '
				int 21h
				int 21h
				mov bin_num,si
				call BINDEC
				call PrintDec
				mov ah,2
				mov dl,' '
				int 21h
				int 21h
				int 21h
				add di,1
				mov bin_num,di
				call BINDEC
				call PrintDec
				mov ah,2
				mov dl,' '
				int 21h
				int 21h
				int 21h
				int 21h
				int 21h
				sub di,1
				mov ax,0
				mov al,gradelist[di]
				mov bin_num,ax
				call BINDEC
				call PrintDec
				call PrintLn
			seq_next:
			loop seq_cmp
			pop cx
		loop seq_display
		mov ah,1
		int 21h
		jmp MAIN
			
	SEQUENCE endp
	DECIBIN proc									;will change bx,ax reg
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
	
	BINDEC proc										;will change bx,ax reg
		mov ax,bin_num
		mov bx,10
		div bl
		add ah,'0'
		mov dec_num[1],ah
		add al,'0'
		mov dec_num[0],al
		ret
	BINDEC endp
	
	
	
	PrintDec proc									;will change ax,dx reg
		mov ah,2
		mov dl,dec_num[0]
		cmp dl,'0'
		jne p_next
		mov dl,' '
		p_next:
		int 21h
		mov dl,dec_num[1]
		int 21h
		ret
	PrintDec endp
	
	PrintLn proc
		mov ah,2
		mov dl,10
		int 21h
		mov dl,13
		int 21h
		ret
	PrintLn endp
	
END START