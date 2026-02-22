
gotoyx:

; ==================================================================
; === Przyjmuje y,x ekranu, a zwraca adres w pamieci ekranu ======== 
; IN:
;	BC - Y,X
; OUT:
;	DE - adres pozycji na ekranie
; ==================================================================


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


; ==================================================================
; IN: 	DE - adres gdzie ma pojawic sie znak
;	A - ASCII char do wyswietlenia 
; ==================================================================	
pchar:
	
		ld	bc,FONTS
		sub	20h			; start od spacji, a
		add	a,a			; x2
		ld	hl,0
		ld	l,a	
		add	hl,hl	
		add	hl,hl			; x8
		add	hl,bc			; adres char w ROM		
		ld	b,8
next_bitline:
		ld	a,(hl)
		ld	(de),a
		inc	hl
		inc	d
		dec	b
		jr	nz,next_bitline
		ret


; ==================================================================
; IN:	DE - adres gdzie ma pojawic sie string
;	BC - adres stringa do wyswietlenia 
; ==================================================================	
pstring:
		ld	a,(bc)
		cp	STRING_DELIM
		jp	z,pstring_out
		sub	20h			; start od spacji, a
		add	a,a			; x2
		ld	hl,0
		ld	l,a	
		add	hl,hl	
		add	hl,hl			; x8 - offset char w ROM
		ld	a,3Dh			; msb FONTS
		add	a,h			; HL - adres char w ROM
		ld	h,a
		push	bc
		push	de
		ld	b,8
next_bitline2:
		ld	a,(hl)
		ld	(de),a
		inc	hl
		inc	d
		djnz	next_bitline2
		pop	de
		inc	de
		pop	bc
		inc	bc
		jr	pstring
pstring_out:
		ret
;========
;pstring2:
;		ld	a,(bc)
;		cp	STRING_DELIM
;		jp	z,pstring_out2
;		push	de
;		push	bc
;		call	pchar
;		pop	bc
;		pop	de
;		inc	de
;		inc	bc
;		jr	pstring2
;pstring_out2:
;		ret
