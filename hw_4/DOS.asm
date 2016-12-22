;MASMPlus 代码模板 - 纯 DOS 程序

.model small
.386				;can't find solution on printing 32bit data in 16bit asm, use 386 mode instead
.stack 200h

.data
	
	year 	db '1975','1976','1977','1978','1979','1980','1981','1982','1983' 
			db '1984','1985','1986','1987','1988','1989','1990','1991','1992' 
			db '1993','1994','1995'
			
	income	dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
				dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
				
	empl		dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226 
				dw 11542,14430,45257,17800
	prtbuf	db 'yyyy 1234567890	12345 1234567890',10,13,'$'
	
	headline db 'year   income    emp    avg_inc',10,13,10,13,'$'
table segment
	db 21 dup('year summ ne ???? ')
table ends



.CODE
START:
	mov ax,@data
	mov ds,ax
	lea dx,headline
	mov ah,9
	int 21h
	
	;loop settings
	mov cx,21
	mov si,0
	mov di,0
	s:				;move data in this loop
	;move year info	
	mov ax,@data
	mov ds,ax
	mov dh,year[si]
	mov dl,year[si+1]
	shl edx,16
	mov dh,year[si+2]
	mov dl,year[si+3]
	mov ax,table
	mov ds,ax
	mov [di],edx
	;move income info
	mov ax,@data
	mov ds,ax
	mov edx,income[si]
	mov ax,table
	mov ds,ax
	mov [di+5],edx
	;move employee info
	mov ax,@data
	mov ds,ax
	mov ax,si
	mov bl,2
	div bl
	mov si,ax
	mov dx,empl[si]
	mov ax,table
	mov ds,ax
	mov [di+10],dx
	;calcu avg info
	mov ax,@data
	mov ds,ax
	mov ebx,0
	mov bx,empl[si]
	add si,si
	mov edx,0
	mov eax,income[si]
	div ebx
	mov ebx,eax
	mov ax,table
	mov ds,ax
	mov [di+13],ebx
	add si,4
	add di,18
	loop s
	
	
	
	
	mov si,0
	mov cx,21
	prt:
	mov ax,table
	mov ds,ax
	mov edx,[si]
	mov ax,@data
	mov ds,ax
	mov prtbuf[3],dl
	mov prtbuf[2],dh
	shr edx,16
	mov prtbuf[1],dl
	mov prtbuf[0],dh
	mov ax,table
	mov ds,ax
	mov edx,[si+5]
	push cx
	mov ax,@data
	mov ds,ax
	mov eax,edx
	mov cx,10
	;print income info into mempry
	subp_1:	
	mov edx,0
	mov ebx,10
	div ebx
	mov di,cx
	add di,4
	add dl,'0'
	cmp ax,0
	jne next_1
	cmp dl,'0'
	jne next_1
	mov dl,' '
	next_1:
	mov prtbuf[di],dl
	loop subp_1
	
	mov cx,5
	mov ax,table
	mov ds,ax
	mov dx,[si+10]
	mov ax,@data
	mov ds,ax
	mov ax,dx
	subp_2:
	mov dx,0
	mov bx,10
	div bx
	mov di,cx
	add di,15
	add dl,'0'
	cmp ax,0
	jne next_2
	cmp dl,'0'
	jne next_2
	mov dl,' '
	next_2:
	mov prtbuf[di],dl
	loop subp_2
	
	mov ax,table
	mov ds,ax
	mov edx,[si+13]
	mov ax,@data
	mov ds,ax
	mov eax,edx
	mov cx,10
	
	subp_3:	
	mov edx,0
	mov ebx,10
	div ebx
	mov di,cx
	add di,21
	add dl,'0'
	cmp ax,0
	jne next_3
	cmp dl,'0'
	jne next_3
	mov dl,' '
	next_3:
	mov prtbuf[di],dl
	loop subp_3
	
	pop cx
	lea dx,prtbuf
	mov ah,9
	int 21h
	add si,18
	sub cx,1
	cmp cx,0
	jne prt
	
	
	
	
	;暂停,任意键关闭
	mov ah,1
	int 21h
	mov ah,4ch     ;结束,可以修改al设置返回码
	int 21h
	
	
END START