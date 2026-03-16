
clear_lines	MACRO	_end_of_area, _lines
		LOCAL	clear_block
		ld	de,0000h		
		ld	hl,0000h
		add	hl,sp			; save SP
		ld	sp,_end_of_area	; czysci od gory 
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
clear_txtline	MACRO _txtline
		LOCAL	clear_block
		ld	hl,_txtline
		ld	e,l
		ld	b,8
		xor	a
		clear_block:
	REPT	32
		ld	(hl),a
		inc	hl
	ENDM			
		ld	l,e
		inc	h
		djnz	clear_block	
		ENDM

; =======================
border_color	MACRO	_color
		ld	a,_color
		out	(0FEh),a
		ENDM
	
; =======================
set_color	MACRO _paper_ink, _adress, _rows
		LOCAL	colour_block
	;	ld	a,_paper_ink
	;	ld	d,a
	;	ld	e,a
		ld de, _paper_ink * 256 + _paper_ink
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

; ======================
set_hero_m	MACRO _paper_ink
		IF NUL _paper_ink
		ELSE
		ld	a,_paper_ink
		ENDIF
		ld	(hero_m),a
		ENDM

