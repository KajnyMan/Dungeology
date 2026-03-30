MUL8_A_HL	MACRO
		ld	h,0
		ld	l,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ENDM
		
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

; =================
; IN:	Y,X w DE
; =================
SET_ATR_LINE	MACRO _paper_ink, _col
		ld	a,d
		add	a,a
		add	a,a
		add	a,a
		ld	l,a
		ld	h,0
		add	hl,hl
		add hl,hl
		ld	a,e
		add	a,l
		ld	l,a
		ld	a,ATR_MSB	
		add	a,h
		ld	h,a
		ld	a,_paper_ink
	IF	NUL _col
		ld	(hl),a
		inc	l
	ELSE
		REPT	_col
			ld	(hl),a
			inc	l
		ENDM
	ENDIF
		ENDM
			
; =========================
SET_ATR_BLOCK	MACRO _paper_ink, _col, _lines
		LOCAL	_next_ln
		ld	b,_lines
	_next_ln:
		set_atr _paper_ink, _col
		inc	d
		djnz	_next_ln
		ENDM
; =========================
; IN : DE - adres Tile na ekranie, A'- atrybut
print_attribute_2buffer	MACRO
		ld	h,ATR3_BUF_MSB
		ld	l,e
		ex	af,af'
		ld	(hl),a
		ex	af,af'
		ENDM
; ========================
atrbuf_2_atr	MACRO
		ld	de,ATR3
		ld	hl,ATR3_BUF
		ld	bc,32 * 8
		ldir
		ENDM
