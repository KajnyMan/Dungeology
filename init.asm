; ==============
;  Init
; ==============
		BORDER_COLOR BLACK
		SET_COLOR	BLACK_BGD OR BLACK, ATR_3D_TOP, 24
		CLEAR_LINES SCREEN_TOP, 191

		call	print_frames

		; kolory okna powiadomien
		ld	a,YELLOW_BGD OR BLACK 
		ld	b,MSG_HEIGHT
		ld	c,MSG_WIDTH
		ld	de,MSG_YX
		call set_atr_block

		; kolory ramki mapy
		ld	a,BLACK_BGD OR GREEN 
		ld	b,FOV_FRAME_H
		ld	c,FOV_FRAME_W
		ld	de,FOV_FRAME_YX
		call set_atr_block

;		; kolory ramki	3D 
		ld	a,BLACK_BGD OR PURPLE 
		ld	b,W3D_FRAME_H
		ld	c,W3D_FRAME_W
		ld	de,W3D_FRAME_YX
		call set_atr_block

		; kolory okna mapy
		ld	a,BLACK_BGD OR RED 
		ld	b,FOV_HEIGHT
		ld	c,FOV_WIDTH
		ld	de,FOV_YX
		call set_atr_block

		; kolory okna informacji
		ld	a,BLACK_BGD OR YELLOW 
		ld	b,INF_HEIGHT
		ld	c,INF_WIDTH
		ld	de,INF_YX
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
		ld	de,0				; offset obiektow
		ld	bc,(map.size)
_next_mapchar:
		ld	a,(hl)
		cp	C_DOOR_CHAR	
		jr	z,_init_door
		cp	O_DOOR_CHAR	
		jr	z,_init_door
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
		
; Oblicza i wypelnia tabele fov_offsets
; W zaleznosci od kierunku patrzenia kazde tile w polu widzenia
; dostanie swoj offset wzgledem Hero
		call	calc_fov	
; Wbija biezace statystyki hero do stringow stat_info
		call	update_stat_strings
		call	print_stat_info
		
