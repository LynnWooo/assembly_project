;MASMPlus 代码模板 - 纯 DOS 程序

.model small
.stack 200h
data segment
	;szMsg db 'Hello World!',13,10,'$'

		;以下是表示 21 年的 21 个字符串
	 	db '1975','1976','1977','1978','1979','1980','1981','1982','1983' 
		db '1984','1985','1986','1987','1988','1989','1990','1991','1992' 
		db '1993','1994','1995'
		;以下是表示 21 年公司总收的 21 个 dword 型数据
		dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
		dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
		;以下是表示 21 年公司雇员人数的 21 个 word 型数据
		dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226 
		dw 11542,14430,45257,17800
		
data ends

table segment
	db 21 dup('year summ ne ?? ')
table ends

.CODE
START:
	;loop settings
	mov cx,9
	mov bx,0
	s:
	mov ax,data
	mov ds,ax
	mov ah,9
	;int 21h
	
	print:
	mov ax,table
	mov ds,ax
	mov bx,0
	mov al,'$'
	mov ah,[bx+21]
	mov [bx+21],al
	mov si,ax
	mov ah,9
	mov dx,bx
	int 21h
	mov ax,si
	mov [bx+21],ah
	add bx,21
	;暂停,任意键关闭
	mov ah,1
	int 21h
	mov ah,4ch     ;结束,可以修改al设置返回码
	int 21h
	
END START