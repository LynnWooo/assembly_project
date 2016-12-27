.model small
.data
	msg_hl		db 'Choose function:',10,13
					db 'c = show clock only',10,13
					db 'a = set alram at particular time',10,13
					db 'd = set a count down alarm',10,13
					db	'u = uninstall current clock',10,13,'$'
	msg_input	db	'Input HH:MM:SS:$'
	msg_rmd		db	10,13,'Input remind word(less than 8 letters):$'
	msg_err		db 10,13,'Input Error!',10,13,'$'
	t_msg_buf	db '$$$$$$$$$'
	msg_of		db 10,13,'Input Overflow!',10,13,'$'
	time_buf		dw ?,?,?
	time_add		dw 0,0,30
	num_bcd		db ?
	num_bin		dw ?
	num_dec		db '34'
	unins_err	db 'TSR is not running!',10,13,'$'
	

.code
start:  
	jmp welcome
	
old_dx	dw	?
old_1ch	dw ?,?

msg_remind	db '$$$$$$$$$'
time_remind	dw	2317h,1000h
time_end		dw 2317h,3000h
status		dw 0		;if status==0, show time
							;if status==1 show remind message
ref_1ch:
	pushf
	call DWORD ptr old_1ch		;call System 1ch int
	
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	;get current position of display and save in cs:old_dx,pagenumber in bh
	xor bh,bh
	mov ah,3
	int 10h
	mov cs:old_dx,dx
	
	mov dl,72
	mov dh,0
	mov bh,0
	mov ah,2
	int 10h
	
	;get cur time,save h in ch, m in cl,s in dh,     bcd code
	mov ah,2				
	int 1ah
	mov dl,0
	mov si,dx
	mov di,cx
	
	
	cmp cx,time_remind
	jne end_check
	cmp dx,time_remind[2]
	jne end_check
	mov status,1
	
	end_check:
	cmp cx,time_end
	jne int_check
	cmp dx,time_end[2]
	jne int_check
	mov status,0
	
	int_check:
	cmp status,0
	je show_time
	
	call dsp_msg
	jmp int_ret
	
	
	show_time:
;	mov di,time_end
;	mov si,time_end[2]
	call dsp_t
	
	int_ret:
	;reset position of display
	mov dx,old_dx
	mov ah,2
	mov bh,0
	int 10h
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	
	iret

dsp_msg proc
	mov di,0
	mov cx,8
	dm_loop:
	mov al,msg_remind[di]
	cmp al,'$'
	jne dm_nxt
	mov al,' '
	dm_nxt:
	mov ah,9
	mov cx,1
	mov bl,01101111b
	int 10h
	call mov_row
	inc di
	cmp di,8
	je dm_end
	jmp dm_loop
	dm_end:
	ret
dsp_msg endp


;display time
dsp_t proc				;display time
	;display hour unit that is saved in di-h
	mov dx,di
	mov cl,8
	shr dx,cl
	push dx
	call dsp_unit
	call dsp_div
	;display min unit that is saved in di-l
	mov dx,di
	mov dh,0
	push dx
	call dsp_unit
	call dsp_div
	;display second unit that is saved in si-h
	mov dx,si
	mov cl,8
	shr dx,cl
	push dx
	call dsp_unit
	ret
dsp_t endp

;display bcd code,8bit, will change value of ax,bx,cx,dx
dsp_unit proc near			
	
	;pop the ip that has been pushed through [call function]
	pop cx						
	pop dx
	push cx
	mov cl,4
	
	;print 1st bcd code
	mov dh,0
	shl dx,cl
	mov al,dh
	add al,'0'
	mov bl,01101111b				;set background-color:brown,text-color:white
	mov ah,9
	mov cx,1
	int 10h
	push dx
	call mov_row
	
	;print 2nd bcd code
	pop dx
	mov cl,4
	mov dh,0
	shr dx,cl
	mov al,dl
	add al,'0'
	mov bl,01101111b				;set background-color:brown,text-color:white
	mov ah,9
	mov cx,1
	int 10h
	call mov_row
	ret
dsp_unit endp


dsp_div proc				;display ':' to divide units
	mov al,':'
	mov bl,01101111b
	mov ah,9
	mov cx,1
	int 10h
	call mov_row
	ret
dsp_div endp

mov_row proc near					;move to next row,will change ax,bx,dx
	mov ah,3
	int 10h
	inc dl
	mov ah,2
	int 10h
	ret
mov_row endp
;end of TSR










;non TSR part, including TSR settings
welcome:
	mov ax,@data
	mov ds,ax
	
	;clear screen
	mov ax,3
	int 10h
	
	;show headline guide message
	lea dx,msg_hl
	mov ah,9
	int 21h
	
	;get user input
	mov ah,0
	int 16h
	
	;check
	cmp al,'c'
	je setup
	cmp al,'a'
	je alarm
	cmp al,'d'
	je cnt_down
	cmp al,'u'
	je unins
	;initialize again if invalid command
	jmp welcome



;gettime function,function a
alarm:
	call get_time
	call parse_time
	call get_rmd
	jmp setup

cnt_down:
	call get_time
	call get_rmd
	mov al,t_msg_buf
	mov num_dec,al
	mov al,t_msg_buf[1]
	mov num_dec[1],al
	call dec_bin
	mov ax,num_bin
	mov time_add,ax
	
	mov al,t_msg_buf[3]
	mov num_dec,al
	mov al,t_msg_buf[4]
	mov num_dec[1],al
	call dec_bin
	mov ax,num_bin
	mov time_add[2],ax
	
	mov al,t_msg_buf[6]
	mov num_dec,al
	mov al,t_msg_buf[7]
	mov num_dec[1],al
	call dec_bin
	mov ax,num_bin
	mov time_add[4],ax
	
	mov ah,2
	int 1ah
	
	push cx
	push dx
	mov num_bcd,ch
	call bcd_bin
	call BINDEC
	mov ax,num_bin
	mov time_buf,ax
	pop dx
	pop cx
	
	push cx
	push dx
	mov num_bcd,cl
	call bcd_bin
	mov ax,num_bin
	mov time_buf[2],ax
	pop dx
	pop cx
	
	push cx
	push dx
	mov num_bcd,dh
	call bcd_bin
	mov ax,num_bin
	mov time_buf[4],ax
	pop dx
	pop cx
	
	call cal_time
	
	mov ax,time_buf
	mov num_bin,ax
	call BINDEC
	call dec_bcd
	mov ch,num_bcd
	push cx
	
	mov ax,time_buf[2]
	mov num_bin,ax
	call BINDEC
	call dec_bcd
	pop cx
	mov cl,num_bcd
	push cx
	
	mov ax,time_buf[4]
	mov num_bin,ax
	call BINDEC
	call dec_bcd
	mov dh,num_bcd
	pop cx
	mov dl,0
	mov cs:time_remind[2],dx
	mov cs:time_remind,cx
	
	
	jmp setup
get_time proc
	lea dx,msg_input
	mov ah,9
	int 21h
	mov si,0
	gt_loop:
		mov ah,1
		int 21h
		cmp al,8
		je gt_bks
		cmp al,':'
		je gt_valid
		cmp al,'9'
		ja gt_error
		cmp al,'0'
		jnb gt_valid
		jmp gt_error
	
	gt_valid:
		mov t_msg_buf[si],al
		inc si
		cmp si,8
		je gt_end
		jmp gt_loop
	gt_bks:
		cmp si,0
		je gt_error
		mov t_msg_buf[si],'$'
		sub si,1
		jmp gt_loop
	
	gt_error:
	lea dx,msg_err
	mov ah,9
	int 21h
	jmp welcome
	gt_end:
	ret
get_time endp

parse_time proc
	mov al,t_msg_buf
	mov num_dec,al
	mov al,t_msg_buf[1]
	mov num_dec[1],al
	call dec_bcd
	mov dh,num_bcd
	
	mov al,t_msg_buf[3]
	mov num_dec,al
	mov al,t_msg_buf[4]
	mov num_dec[1],al
	call dec_bcd
	mov dl,num_bcd
	
	mov al,t_msg_buf[6]
	mov num_dec,al
	mov al,t_msg_buf[7]
	mov num_dec[1],al
	call dec_bcd
	mov cx,dx
	mov dl,0
	mov dh,num_bcd
	
	mov cs:time_remind,cx
	mov cs:time_remind[2],dx
	
	
	
	push cx
	push dx
	mov num_bcd,ch
	call bcd_bin
	call BINDEC
	mov ax,num_bin
	mov time_buf,ax
	pop dx
	pop cx
	
	push cx
	push dx
	mov num_bcd,cl
	call bcd_bin
	mov ax,num_bin
	mov time_buf[2],ax
	pop dx
	pop cx
	
	push cx
	push dx
	mov num_bcd,dh
	call bcd_bin
	mov ax,num_bin
	mov time_buf[4],ax
	pop dx
	pop cx
	
	call cal_time
	
	mov ax,time_buf
	mov num_bin,ax
	call BINDEC
	call dec_bcd
	mov ch,num_bcd
	push cx
	
	mov ax,time_buf[2]
	mov num_bin,ax
	call BINDEC
	call dec_bcd
	pop cx
	mov cl,num_bcd
	push cx
	
	mov ax,time_buf[4]
	mov num_bin,ax
	call BINDEC
	call dec_bcd
	mov dh,num_bcd
	pop cx
	mov dl,0
	mov cs:time_end[2],dx
	mov cs:time_end,cx
	ret
parse_time endp

;change dec num into bcd num
dec_bcd proc
	mov ah,num_dec
	sub ah,'0'
	mov al,0
	mov cl,4
	shl ax,cl
	mov al,num_dec[1]
	sub al,'0'
	add ah,al
	mov num_bcd,ah
	ret
dec_bcd endp

PrintDec proc									;will change ax,dx reg
		mov ah,2
		mov dl,num_dec[0]
		cmp dl,'0'
		jne p_next
		mov dl,' '
		p_next:
		int 21h
		mov dl,num_dec[1]
		int 21h
		ret
PrintDec endp

;change dec num into bin num
dec_bin proc									;will change bx,ax reg
		mov bh,num_dec[0]
		mov bl,num_dec[1]
		sub bl,'0'
		sub bh,'0'
		mov al,10
		mul bh
		mov bh,0
		add ax,bx
		mov num_bin,ax
		ret
dec_bin endp

;change bcd num into bin num
bcd_bin proc
	mov al,num_bcd
	mov cl,4
	mov ah,0
	shl ax,cl
	mov bh,10
	mov bl,al
	mov al,ah
	mul bh
	;mov bh,num_bcd
	mov bh,0
	shl bx,cl
	mov bl,0
	
	add al,bh
	mov num_bin,ax
	ret
bcd_bin endp

;change bin num into dec num
BINDEC proc										;will change bx,ax reg
		mov ax,num_bin
		mov bx,10
		div bl
		add ah,'0'
		mov num_dec[1],ah
		add al,'0'
		mov num_dec[0],al
		ret
BINDEC endp

;calcu time_buf+time_add
cal_time proc
	mov ax,time_buf[4]
	mov bx,time_buf[2]
	mov cx,time_buf
	
	add ax,time_add[4]
	cmp ax,60
	jb cal_m
	sub ax,60
	add bx,1
	
	cal_m:
	add bx,time_add[2]
	cmp bx,60
	jb cal_h
	sub bx,60
	add cx,1
	
	cal_h:
	add cx,time_add
	cmp cx,24
	jb cal_ret
	sub cx,24
	
	cal_ret:
	mov time_buf[4],ax
	mov time_buf[2],bx
	mov time_buf,cx
	ret
cal_time endp

;get reminder
get_rmd proc
	lea dx,msg_rmd
	mov ah,9
	int 21h
	mov si,0
	
	gr_loop:
		mov ah,1
		int 21h
		cmp al,8
		je gr_bks
		cmp al,13
		je gr_end
		mov cs:msg_remind[si],al
		inc si
		cmp si,8
		je gr_end
		jmp gr_loop
		gr_bks:
			cmp si,0
			je gr_err
			mov cs:msg_remind[si],'$'
			sub si,1
			jmp gr_loop
		
	gr_err:
		lea dx,msg_err
		jmp welcome
	gr_end:
	ret
get_rmd endp

;function u
unins proc
	mov ax,0f1f1h
	int 1ch
	cmp ax,1f1fh
	je unins_nxt
	lea dx,unins_err
	mov ah,1
	int 21h
	mov ah,4ch
	int 21h
	
	unins_nxt:
	jmp welcome
unins endp


;set up TSR
setup:
	;set ds=code segment
	push cs		
	pop ds
	
	;get int 1ch vector segment, save in es:bx
	mov ah,35h
	mov al,1ch
	int 21h
	
	;save System int 1ch in DWORD ptr old_1ch
	mov old_1ch,bx
	mov ax,es
	mov old_1ch[2],es
	
	;set new 1ch int vector
	mov dx,offset ref_1ch
	mov ah,25h
	mov al,1ch
	int 21h
	
	;set length of the program in memory,save in dx
	mov dx,offset welcome
	mov ax,offset start
	sub dx,ax
	mov cl,4
	shr dx,cl
	add dx,12h		;add up length of psp,and 2 extra words
	mov ah,31h
	int 21h
END START

