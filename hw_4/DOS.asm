;MASMPlus ����ģ�� - �� DOS ����

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
	
	;��ͣ,������ر�
	mov ah,1
	int 21h
	mov ah,4ch     ;����,�����޸�al���÷�����
	int 21h
	
END START