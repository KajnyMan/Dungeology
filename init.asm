; ==============
;  Init
; ==============
		BORDER_COLOR BLACK
		SET_COLOR	BLACK_BGD OR BLACK, ATR_3D_TOP, 24
		CLEAR_LINES SCREEN_TOP, 192

		call	print_frames

		; kolory okna powiadomien
		ld	a,MSG_ATR
		ld	b,MSG_HEIGHT
		ld	c,MSG_WIDTH
		ld	de,MSG_YX
		call set_atr_block

		; kolory ramki mapy
		ld	a,FOV_FRAME_ATR	
		ld	b,FOV_FRAME_H
		ld	c,FOV_FRAME_W
		ld	de,FOV_FRAME_YX
		call set_atr_block

;		; kolory ramki	3D 
		ld	a,W3D_FRAME_ATR	
		ld	b,W3D_FRAME_H
		ld	c,W3D_FRAME_W
		ld	de,W3D_FRAME_YX
		call set_atr_block

		; kolory okna mapy
		ld	a,FOV_ATR
		ld	b,FOV_HEIGHT
		ld	c,FOV_WIDTH
		ld	de,FOV_YX
		call set_atr_block

		; kolory okna statystyk
		ld	a,STS_ATR
		ld	b,STS_HEIGHT
		ld	c,STS_WIDTH
		ld	de,STS_YX
		call set_atr_block
		
		; kolory okna przedmiotow
		ld	a,ITM_ATR
		ld	b,ITM_HEIGHT
		ld	c,ITM_WIDTH
		ld	de,ITM_YX
		call set_atr_block
		
; ------ Oblicza rozmiar mapy --------
		ld	hl,(map.width)
		ld	b,h
		ld	c,l
		call	mul8
		ld	(map.size),hl	

; ------ Czyta MAPe i inicjalizuje obiekty ( drzwi i uktyte przejscia ) ------
		ld	ix,doors
		ld	iy,passages
		ld	hl,MAP
		ld	de,0				; offset obiektow w bajtach
		ld	bc,(map.size)
		exx
		ld	hl,m_walls
		exx
_next_mapchar:
		ld	a,(hl)
		cp	C_DOOR_CHAR	
		jr	z,_init_door

		cp	O_DOOR_CHAR	
		jr	z,_init_door

		cp	M_WALL_CHAR
		jr	nz,_maybe_psg

		; --- przesuwane sciany ---	
		push	de
		exx	
		pop		de
		ld	(hl),e
		inc	hl
		ld	(hl),d
		inc	hl
		exx
		ld	(hl),WALL_CHAR
_maybe_psg
		cp	PASSAGE_CHAR
		jr	nz,_inc_counters

		; --- ukryte przejscia ----
		ld	(iy),e
		ld	(iy+1),d
		inc	iy
		inc	iy
		ld	(hl),WALL_CHAR
		jr	_inc_counters
		; ---	drzwi   --- 
		; 0 - MAP Ofs lsb, 1 - msb, 2 - open(0), close(1)
_init_door:
		ld	(ix),e				; offset obiektu lsb
		ld	(ix+1),d			; msb
		inc	ix
		inc	ix
		; -----------------
_inc_counters:
		inc	hl
		inc	de
		dec	bc	
		ld	a,b
		or	c
		jr	nz,_next_mapchar

; Na podstawie Y,X oblicza offset hero wzgledem poczatku map'y
		ld	a,(hero.mapY)
		ld	c,a
		ld	a,(map.width)
		ld	b,a
		call	mul8
		ld	a,(hero.mapX)
		ld	d,0
		ld	e,a
		add	hl,de	
		ld	(hero.offset),hl


; Oblicza i wypelnia tabele neighbor_offs
		ld	ix,neighbor_offs
		ld	a,(map.width)
		ld	(ix+2),a
		neg
		ld	(ix),a
		
; -------------------------------------------------------
; Oblicza i wypelnia wynikami tabele offsetow
; potencjalnie widzialnych Tiles - fov_offsets 
; W zaleznosci od kierunku patrzenia kazde tile w polu widzenia
; dostanie swoj offset wzgledem Hero
; -------------------------------------------------------
calc_fov:
		; --- EAST & NORTH --- 
		ld	iy,fov_n + 4	
		ld	ix,fov_e + 4
		ld	b,4			; glebokosc fov
		ld	d,0
		ld	e,10			; offset adresu od 5 do 2
		ld	a,(map.width)
		ld	c,a
_nxtrow:
		add	a,b
		ld	(ix+2),a	
		ld	a,b
		sub	c
		ld	(ix-2),a
		ld	(ix-1),0FFh
		ld	(ix),b

		call	mul8
		ld	a,h
		cpl
		ld	h,a
		ld	a,l
		cpl
		ld	l,a
		ld	(iy-2),l
		ld	(iy-1),h
		inc	hl

		ld	(iy),l
		ld	(iy+1),h
		inc	hl
		ld	(iy+2),l
		ld	(iy+3),h

		ld	a,b
		cp	3
		jr	c,_ommit1
		ld	a,(ix+2)
		add	a,c
		ld	(ix+4),a
		ld	a,(ix-2)
		sub	c
		ld	(ix-4),a
		ld	(ix-3),0FFh

		ld	l,(iy-2)
		ld	h,(iy-1)
		dec	hl	
		ld	(iy-4),l
		ld	(iy-3),h
		ld	l,(iy+2)
		ld	h,(iy+3)
		inc	hl	
		ld	(iy+4),l
		ld	(iy+5),h
_ommit1:
		add	ix,de
		add	iy,de
		dec	e	
		dec	e	
		ld	a,c
		djnz	_nxtrow

		ld	(ix+2),a
		neg
		ld	(ix),a
		ld	(ix+1),0FFh
		ld	(iy),-1
		ld	(iy+1),0FFh
		ld	(iy+2),1
		;--- WEST & SOUTH ---
		ld	hl,fov_n
		ld	de,fov_s
		ld	b,36
_nxt1:	push	bc
		ld	a,(hl)	
		cpl
		ld	c,a	
		inc	hl
		ld	a,(hl)
		cpl
		ld	b,a
		inc	bc
		ld	a,c
		ld	(de),a
		inc	de
		ld	a,b
		ld	(de),a
		inc	hl
		inc	de
		pop	bc
		djnz	_nxt1

; Wbija biezace statystyki hero do stringow stat_info
		call	update_info_strings
		call	print_info
		
