
clear_lines	MACRO	_lines
		LOCAL	clear_block
		ld	de,0000h		
		ld	hl,0000h
		add	hl,sp			; save SP
		ld	sp,SCREEN_ATR		; powyzej ekranu
		ld	b,_lines		; 192 = 6144 / ( 16 x 2 )
		clear_block:
	REPT	16				; zeruje 32 bajty na obrot
		push	de	
	ENDM
		djnz	clear_block	
		ld	sp,hl			; restore SP
		ENDM

hide_cursor	MACRO

		ENDM

show_cursor	MACRO

		ENDM

; =======================
border_color	MACRO	_color
		ld	a,_color
		out	(0FEh),a
		ENDM
	
; =======================
set_color	MACRO _paper, _ink, _adress, _rows
		LOCAL	colour_block
		ld	a,_paper
		add	a,a
		add	a,a
		add	a,a
		or	_ink
		ld	d,a
		ld	e,a
		ld	hl,0000h
		add	hl,sp			; save SP
		ld	sp,_adress
		ld	b,_rows
		colour_block:
	REPT	16				; zeruje 32 bajty na obrot
		push	de	
	ENDM
		djnz	colour_block	
		ld	sp,hl			; restore SP
		ENDM
