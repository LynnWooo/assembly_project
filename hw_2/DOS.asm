;MASMPlus ����ģ�� - �� DOS ����

.model small


	
.CODE
START:

	;print first line
	;set time of loop & first letter
	mov cx,16
	mov dl,'a'
	;print a letter & blank space in each loop
	s:
	mov ah,2
	int 21h
	inc dl
	mov bx,dx
	mov dl,' '
	int 21h
	mov dx,bx
	loop s
	
	;change line
	mov dl,10
	int 21h
	mov dl,13
	int 21h
	
	;print 2nd line
	mov cx,10
	mov dl,'a'+16
	;print a letter & blank space in each loop
	s2:
	mov ah,2
	int 21h
	inc dl
	mov bx,dx
	mov dl,' '
	int 21h
	mov dx,bx
	loop s2
	
	;��ͣ,������ر�
	mov ah,1
	int 21h
	mov ah,4ch     ;����,�����޸�al���÷�����
	int 21h
	
END START