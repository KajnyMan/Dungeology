; ==================================================================
; === Przyjmuje y,x ekranu, a zwraca adres w pamieci ekranu ======== 
; IN:
;	BC - Y,X
; OUT:
;	DE - adres pozycji na ekranie
; USED:	A  
; ==================================================================

gotoyx:
		push	af
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
		pop	af

		ret
; ===================================================
; =======       Drukuje znak na ekranie      ========
; IN: 	DE - adres gdzie ma pojawic sie znak
;	A - ASCII char do wyswietlenia 
; USED:	A, BC, DE, HL
; ===================================================
pchar:
	
;		ld	bc,FONTS
		sub	20h			; start od spacji, a
		add	a,a			; x2
		ld	h,0
		ld	l,a	
		add	hl,hl	
		add	hl,hl			; x8
;		add	hl,bc			; adres char w ROM		
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

; =====================================================
; =======       Ustawia kolor w Y, X ekranu	=======
; IN: 		BC - Y,X
;		A - atrybut
; OUT:		HL - adres w pamieci atrybutow 
; USED:		BC, HL 
; =====================================================
setatr:
		push	af		; kolor save

		ld	hl,0
		ld	a,b
		add	a,a
		add	a,a
		add	a,a
		ld	l,a	
		add	hl,hl
		add	hl,hl
		ld	b,0
		add	hl,bc
		ld	bc,SCREEN_ATR	
		add	hl,bc		; adres atrybutow

		pop	af		; kolor restore
		ld	(hl),a		; i ustawiony
		ret	

; ==================================================================
; IN:	DE - adres gdzie ma pojawic sie string
;	BC - adres stringa:o wyswietlenia 
; ==================================================================	
ptile:
		ld	a,(bc)
		cp	TILE_EOL
		jp	z,ptile_out
		ld	hl,0
		ld	l,a	
		add	hl,hl	
		add	hl,hl	
		add	hl,hl			; x8 - offset Tile
		ld	a,TILES_MSB	
		add	a,h	
		ld	h,a
		push	de
	REPT	8		
		ld	a,(hl)
		ld	(de),a
		inc	hl
		inc	d
	ENDM
		pop	de
		inc	de
		inc	bc
		jr	ptile	
ptile_out:
		ret
;========
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
;		add	hl,bc
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
