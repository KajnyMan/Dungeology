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
; IN:	DE - adres gdzie ma pojawic sie tile
;		BC - adres pierwszego tile do wyswietlenia 
; ==================================================================	
print_tile_line:
		ld	a,(bc)
		cp	TILE_EOL
		jp	z,ptile_out

		print_attribute_2buffer

		ld	h,0
		ld	l,a	
		add	hl,hl	
		add	hl,hl	
		add	hl,hl			; x8 - offset Tile
		ld	a,TILES_MSB	
		add	a,h	
		ld	h,a
;		push	de
	REPT	8		
		ld	a,(hl)
		ld	(de),a
		inc	hl
		inc	d
	ENDM
		ld	a,d
		sub	8
		ld	d,a
;		pop	de
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
; ==========================================
; Druguje ramke okna
; IN:	BC - Y, X lewego gornego rogu ramki
; ==========================================
print_frames:
		ld	bc,FOV_FRAME_YX
		ld	hl,fov_frame_indexes				
		ld	a,(hl)
		inc	hl
		ex	af,af'
		ld	a,(hl)
		ex	af,af'					; kolor przygotowany
		inc	hl	
	go_down:
		push	bc
		push	af
		call	gotoyx			
		; w DE adres
		
		ld	b,h
		ld	c,l
		call	print_tile_line
		; BC na $FF lini
		pop		af
		pop		bc
		ld	h,b
		ld	l,c
		inc	b
		dec	a
		jr	nz, go_down	
		
		
		
		

			
		
fov_frame_indexes
	db	76, 77, 78, 79, 80, 76, 77, 78, 79, 80, 76, $FF
	db	81, $FF, 81, $FF, 82, $FF, 82, $FF
	db	83, $FF, 83, $FF, 84, $FF, 84, $FF
	db	76, 77, 78, 79, 80, 76, 77, 78, 79, 80, 76, $FF
