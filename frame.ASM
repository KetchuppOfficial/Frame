;-------------------------------------------------------------------------------------------
;	AH - colour of line
;	AL - any symbol
;	BX - length of the string 
;	BP - middle lines counter
;	CX - counter
;	DI - number of symbol counting from the beginning of the line
;	ES - address of a videosegment (0b800h)
;-------------------------------------------------------------------------------------------

.model tiny
.code
org 100h

VIDEOSEG	equ 0b800h
MID_LINES	equ 2

COLOUR		equ 08Ch
CMD_LINE	equ 081h

PUTCHAR		macro

			nop
			lodsb
			stosw
			nop	

			endm

Start: jmp main

locals @@

;-------------------------------------------------------------------------------------------
New_Line	proc

			xor dx, dx
			mov ax, di
			mov cx, 0A0h
			div cx
			inc ax
			mul cx
			mov di, ax
			mov ah, COLOUR

			ret

New_Line	endp
;-------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------
Skip_Spaces proc

@@skip_spaces:
			inc si
			mov al, 020h
			cmp [si], al
			je @@skip_spaces

			ret

Skip_Spaces endp
;-------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------
Draw_Line	proc

			mov cx, bx
			add cx, 2
			
			PUTCHAR

			lodsb
@@next_symb:
			stosw
			loop @@next_symb
			
			PUTCHAR
			
			call New_Line

			ret

Draw_Line	endp
;-------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------
Draw_Middle	proc

			xor bp, bp

@@middle:	mov cx, bx
			add cx, 2

			mov si, CMD_LINE
			call Skip_Spaces
			add si, 3

			call Draw_Line

			inc bp
			cmp bp, MID_LINES
			jb @@middle

			ret

Draw_Middle	endp
;-------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------
Draw_Text	proc

			mov si, CMD_LINE
			call Skip_Spaces
			add si, 3

			PUTCHAR
			PUTCHAR
			
			mov si, CMD_LINE
			call Skip_Spaces
			add si, 9
			call Skip_Spaces

@@next_symb:
			PUTCHAR

			mov cx, 0Dh
			cmp [si], cx
			jne @@next_symb	

			mov si, CMD_LINE
			call Skip_Spaces
			add si, 4

			PUTCHAR
			PUTCHAR

			call New_Line

			ret

Draw_Text	endp
;-------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------
Draw_Frame	proc

		mov si, CMD_LINE
		call Skip_Spaces
		call Draw_Line

		call Draw_Middle

		call Draw_Text

		call Draw_Middle
		
		mov si, CMD_LINE
		call Skip_Spaces
		add si, 6
		call Draw_Line

Draw_Frame	endp
;-------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------
main:	
		mov si, 080h
		mov bx, [si]
		xor bh, bh

		cmp bx, 000Ch
		jb @@incomplete_input
		sub bx, 11				;9 symbols for frame, 1 space before cmd line and 1 space between frame symbols and phrase

		mov ax, VIDEOSEG
		mov es, ax
		mov ah, COLOUR
		xor di, di

		call Draw_Frame

		mov ax, 4C00h
		int 21h

@@incomplete_input:

		mov bx, offset incomplete
		mov ah, 09h
		int 21h

		mov ax, 4C00h
		int 21h

;-------------------------------------------------------------------------------------------
incomplete	db "The input has to contain at least 9 frame sybmols and 1 content symbol", 0Dh, 0Ah, '$'
;-------------------------------------------------------------------------------------------

end		Start
