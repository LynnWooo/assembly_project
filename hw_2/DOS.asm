;MASMPlus ����ģ�� - �� DOS ����

.model small


	
.CODE
START:

	;print first line
	;set time of loop & first letter
	mov cx,26
	mov dl,'a'
	s:
	mov ah,2
	;mov dl,'a'
	;mov cx,1
	int 21h
	inc dl
	mov bx,dx
	mov dl,' '
	int 21h
	mov dx,bx
	;int 21h
	loop s
	;��ͣ,������ر�
	mov ah,1
	int 21h
	mov ah,4ch     ;����,�����޸�al���÷�����
	int 21h
	
END START