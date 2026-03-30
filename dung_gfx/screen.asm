; ==================================================================
; === Przyjmuje y,x ekranu, a zwraca adres w pamieci ekranu ======== 
; IN:
;	BC - Y,X
; OUT:
;	DE - adres pozycji na ekranie
; USED:	A  
; ==================================================================

gotoyx:
		ld	de,SCREEN
		ld	a,b
		and	%00000111		; bity 0-2 Y-ka	
		rrca				; * 32
		rrca				; ( gorna tercja ekranu )
		rrca
		or	e
		ld	e,a
		ld	a,b
		and	%00011000		; bity 3-4 Y-ka	
		or	d			; * 2K ( 8 * 8 * 32 )
		ld	d,a			; ( pozostale dwie tercje )
						
		ld	a,c
		or	e			; przesuniecie X do adresu
		ld	e,a
		ret
; ===================================================
; =======       Drukuje znak na ekranie      ========
; IN: 	DE - adres gdzie ma pojawic sie znak
;	A - ASCII char do wyswietlenia 
; USED:	A, DE, HL
; ===================================================
pchar:
	
		sub	20h			; start od spacji, a
		add	a,a			; x2
		ld	h,0
		ld	l,a	
		add	hl,hl	
		add	hl,hl			; x8
		ld	a,FONTS_MSB
		add	a,h
		ld	h,a
	REPT	8
		ld	a,(hl)
		ld	(de),a
		inc	hl
		inc	d
	ENDM
		ret

; ==================================================================
; IN:	DE - adres gdzie ma pojawic sie tile
;		BC - adres pierwszego tile do wyswietlenia 
; ==================================================================	
print_tile_line:
		ld	a,(bc)
		cp	TILE_EOL
		jp	z,ptile_out

	;	print_attribute_2buffer

		MUL8_A_HL

		ld	a,TILES_MSB	
		add	a,h	
		ld	h,a
	REPT	8		
		ld	a,(hl)
		ld	(de),a
		inc	hl
		inc	d
	ENDM
		ld	a,d
		sub	8
		ld	d,a
		inc	de
		inc	bc
		jr	print_tile_line	
ptile_out:
		ret
; ==================================================================
; IN:	DE - adres gdzie ma pojawic sie string
;		BC - adres stringa do wyswietlenia 
; ==================================================================	
pstring:
		ld	a,(bc)
		cp	STRING_DELIM
		jp	z,pstring_out
		push	de
		call	pchar
		pop	de
		inc	de
			inc	bc
		jr	pstring
pstring_out:
		ret

; ==================================================================
;	Zeruje 9-cio kolumnowe linie do wyczyszczenia 
;	IN:	HL	-  adres pierwszej lini do czyszczenia
;	B	_	liczba lini do wyczyszczenia 
; ==================================================================
clear_txtlines:
		ld	d,h
		ld	e,l			; SAVE HL

	txtline_down:
		xor	a
		ld	c,8
	line_down:
	REPT	FOV_WIDTH
		ld	(hl),a
		inc	l
	ENDM
		ld	l,e			; RESTORE L
		inc	h
		dec	c
	jp	nz,line_down
		ld	h,d			; RESTORE H
		ld	a,l
		add	a,SCREEN_WIDTH
		ld	l,a
		ld	e,l
		jr	nc,same_third	
		ld	a,h
		add	a,$08
		ld	h,a
		ld	d,h
	same_third:
		dec	b
		jp	nz,txtline_down
		ret

; ==================================================================
;	Ustawia atrybuty dla 'znaku' na ekranie
;	IN:	A - atrybut
;		DE - YX
; ==================================================================
set_atr
	push	af
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
	pop		af		
		ld	(hl),a
		ret

; ==================================================================
;	Ustawia atrybuty dla lini na ekranie
;	IN:	A - atrybut
;		C - liczba kolumn
;		DE - YX
; ==================================================================
set_atr_line
	push	af
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
	pop		af		
		ld	b,c
	nxt_col:	
		ld	(hl),a
		inc	l
	djnz	nxt_col
		ret
			
; ==================================================================
;	Ustawia atrybuty dla bloku ( czworokata ) na ekranie
;	IN:	A - atrybut
;		B - liczba lini
;		C - liczba kolumn
;		DE - YX
; ==================================================================
set_atr_block:
	push	bc
		call set_atr_line	
		inc	d
	pop		bc
	djnz	set_atr_block
		ret
; ==================================================================
; Przyjmuje y,x ekranu, a zwraca adres w pamieci atrybutow ekranu 
; IN:
;	BC - Y,X
; OUT:
;	HL' - adres w pamieci atrybutow 
; USED: A', BC'
; ==================================================================

;atryx:
;		push	bc
;		exx
;		ex	af,af'
;		pop	bc
;
;		ld	hl,0
;		ld	a,b
;		add	a,a
;		add	a,a
;		add	a,a
;		ld	l,a	
;		add	hl,hl
;		add	hl,hl
;		ld	b,0
;		add	hl,bc
;		ld	bc,SCREEN_ATR	
;	add	hl,bc
;		ex	af,af'
;		exx	
;		ret

; ==================================================================
; IN: 	HL' - adres gdzie ma pojawic sie bajt atrybutow 
;	A - bajt atrybutow do skopiowania 
; USED:	A'
; ==================================================================	
;patr:		push	af
;		exx	
;		pop	af
;		ld	(hl),a
;		exx
;		ret
; ==========================================
; Druguje ramke okna
; IN:	BC - Y, X lewego gornego rogu ramki
; ==========================================
print_frames:
		ld	hl,fov_frame_indexes			; iterator
			ld	b,FFH * 2 + F3H * 2	; licznik
;		ld	b,34	
	line_dwn:
	push	bc
		ld	b,(hl)
		inc	hl
		ld	c,(hl)
		call	gotoyx
		; adres w DE
		inc	hl
		ld	b,h
		ld	c,l
		call	print_tile_line
		; BC - iterator na $FF (eol)
		ld	h,b
		ld	l,c
		inc	hl
	pop		bc
	djnz	line_dwn
		ret
		
		
			
		
fov_frame_indexes
	db	FFY, FFX, 76, 77, 78, 79, 80, 76, 77, 78, 79, 80, 76, $FF
	db	FFY+1, FFX, 81, $FF, FFY+1, FFX+FFW, 81, $FF
	db	FFY+2, FFX, 82, $FF, FFY+2, FFX+FFW, 82, $FF
	db	FFY+3, FFX, 83, $FF, FFY+3, FFX+FFW, 83, $FF
	db	FFY+4, FFX, 84, $FF, FFY+4, FFX+FFW, 84, $FF
	db	FFY+5, FFX, 76, $FF, FFY+5, FFX+FFW, 76, $FF
	db	FFY+6, FFX, 81, $FF, FFY+6, FFX+FFW, 81, $FF
	db	FFY+7, FFX, 82, $FF, FFY+7, FFX+FFW, 82, $FF
	db	FFY+8, FFX, 83, $FF, FFY+8, FFX+FFW, 83, $FF
	db	FFY+9, FFX, 84, $FF, FFY+9, FFX+FFW, 84, $FF
	db	FFY+10, FFX, 76, 77, 78, 79, 80, 76, 77, 78, 79, 80, 76, $FF

	db	F3Y, F3X, 76, 77, 78, 79, 80, 76, 77, 78, 79, 80, 76, $FF
	db	F3Y+1, F3X, 81, $FF, F3Y+1, F3X+F3W, 81, $FF
	db	F3Y+2, F3X, 82, $FF, F3Y+2, F3X+F3W, 82, $FF
	db	F3Y+3, F3X, 83, $FF, F3Y+3, F3X+F3W, 83, $FF
	db	F3Y+4, F3X, 81, $FF, F3Y+4, F3X+F3W, 81, $FF
	db	F3Y+5, F3X, 82, $FF, F3Y+5, F3X+F3W, 82, $FF
	db	F3Y+6, F3X, 83, $FF, F3Y+6, F3X+F3W, 83, $FF
	db	F3Y+7, F3X, 76, 77, 78, 79, 80, 76, 77, 78, 79, 80, 76, $FF
