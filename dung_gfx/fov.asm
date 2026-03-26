;=============
field_of_view:
;=============
	; fov_coords - offsety tiles na ekranie ( zawsze stale )
	; fov_offsets - offsety tiles na mapie ( zaleza od szerokosci mapy )

	; Ustawienie wskaznika fov_coords w zaleznosci kierunku patrzenia. 
	; wariant z 4 bajtowa tabelka fov_shift ( staly krok o 36B )
		ld	hl,fov_shift
		ld	a,(hero_d)
		ld	d,0
		ld	e,a
		add	hl,de
		ld	e,(hl)			; przesuniecie do dodania
		ld	hl,fov_coords
		add	hl,de
		ld	(coords_pointer),hl	; zapisany
		

	; Ustawienie wkaznika dla offsetow tiles	
	; koordynaty oraz offsety sa 2 bajtowe, wiec offset w DE jest ten sam
		ld	hl,fov_offsets
		add	hl,de			; wskaznik na offset tile 
		ld	(offset_pointer),hl	; wzgledem Hero

	; Ustawienie wskaznika dla fov_list
	; Wszystkie obiekty w polu widzenia beda dodany do tej listy
	; Te poza MAP beda wyzerowane
	; 3 Bajty dla obiektu: y, x ( dla Terminala ), ASCII char obiektu 
		ld	ix,fov_list

	; Ustawienie wskaznika dla map_position
		ld	iy,borders

	; Dodanie offsetow koordynatow Tiles do koordynatow Hero	
		ld	b,18			; 18 przebiegow petli
.setdataloop:	push	bc			; SAVE licznik
		ld	(ix),00h
		ld	(ix+1),00h
		ld	(ix+2),00h
		ld	hl,(coords_pointer)
		; Y
		ld	e,(hl)			; offset Y tile
;		ld	a,(hero_mapY)
;		add	a,e			; dodatnie mapY Hero
;		cp	(iy)			; jesli Y tile
;		jr	c,out1			; poza rozmiarem mapy to
;		cp	(iy+1)		; konczymy ten przebieg 
;		jr	nc,out1
	ld	a,HERO_Y
	add	a,e
		ld	(ix),a			; do Y tile i zapis do fov_list
		inc	hl
		; X
		ld	d,(hl)			; offset X tile
;		ld	a,(hero_mapX)
;		add	a,d			; dodatnie X Hero
;		cp	(iy+2)		; jesli X tile
;		jr	c,out2			; poza rozmiarem mapy to				
;		cp	(iy+3)		; konczymy ten przebieg 
;		jr	nc,out2
	ld	a,HERO_X
	add	a,d
		ld	(ix+1),a		; do X tile i zapis do fov_list

	; ASCII char
		ld	hl,(offset_pointer)
		ld	e,(hl)		
		inc	hl
		ld	d,(hl)
		ld	hl,(hero_o)		
		add	hl,de			; dodanie przesuniecia Hero
		ex	de,hl			; save sumy przesuniec
		ld	hl,MAP
		add	hl,de			; i odczytanie z MAPy char 
		ld	a,(hl)			; Tile i zapisanie tego
		ld	(ix+2),a		; char (Tile) na liscie fov

	; Jezeli przed Hero sa Zamkniete Drzwi to funkja roomlabel wyszukuje je
	; na mapie i wbije odpowiedni nr drzwi w sprit'a 3D, ktory bedzie
	; pozniej wydrukowany.
		cp	C_DOOR		; Jesli Zamkniete drzwi
		jr	nz,shift
		ld	a,b
		cp	4			; przed Hero
		jr	nz,shift
	;	call	roomlabel		; to wbij nr drzwi w sprite'a 3D

	; Przesuwa wskazniki koordynatow, wskaznika offsetu wzgl.Hero
	; i wskaznika listy FOV
	shift:	ld	hl,(coords_pointer)
	out1:	inc	hl
	out2:	inc	hl
		ld	(coords_pointer),hl
		ld	hl,(offset_pointer)
		inc	hl
		inc	hl
		ld	(offset_pointer),hl
		inc	ix
		inc	ix
		inc	ix	

		pop	bc			; RESTORE licznik
		djnz	.setdataloop
	
	; ----------------------------------------------------
	; - Petla wyswietlajaca FOV i zapisujaca do prev_fov -
	; ----------------------------------------------------
		ld	b,18			; ilosc mozliwych pol widzenia
		; Ustawienie wskaznikow
		ld	hl,prev_fov_list
		ld	(iterator),hl
.printloop:
		push	bc

		ld	hl,count_order		; podmiana licznika na liczacy
		ld	e,b			; z dwoch stron fov do srodka
		ld	d,0
		add	hl,de			; w hl adres nowego licznika

		ld	a,(hl)			; Tylko dla Tile od 18 do 6
		ld	(main_counter),a
		cp	6			; spradza czy Tile widoczny
		jp	nc,is_visible		; Reszta zawsze widoczna.
	vsbl:
		; Ustawienie kursora
		ld	hl,fov_list_end
		ld	a,(main_counter)
		ld	b,a
		add	a,a
		add	a,b			; licznik x 3
		ld	e,a
		and	a			; carry  0	
		sbc	hl,de			; Adres ( Y, X, char )
		push	hl
		pop	ix	
		
		ld	b,(ix)			; Y
		ld	c,(ix+1)		; X	
		; Kopia Y i X tile do prev_fov_list
		ld	hl,(iterator)
		ld	(hl),b
		inc	hl
		ld	(hl),c
		inc	hl
		ld	a,(ix+2)		; Tile char
		push	af			; Save Tile.char
		ld	(hl),a
		inc	hl
		ld	(iterator),hl
		
		; Tile na ekran	
		ld	a,(ix+2)		
		call	gotoyx
		call	pchar

		; Print 3D
		pop	af			; Restore Tile.char
		cp	WALL_CHAR
		jp	z,printwall_3d		; Sprite na ekran
		cp	C_DOOR
		jp	z,print_c_door_3d	; Sprite na ekran
		cp	O_DOOR
		jp	z,print_o_door_3d	; Sprite na ekran

	printout:
		pop	bc
		djnz	.printloop			
		ld	hl,(iterator)
		ld	(hl),DELIM
		; wlacza "widzialnosc" okna 3D
	;	set_color BLACK_BGD OR GREEN, ATR_3D_TOP, 8
		atrbuf_2_atr
		ret

;-----------------------------------
; Sprawdza czy Tile jest widoczny
; ( w A jest licznil petli funkji wywolujacej )
;-----------------------------------	
is_visible:
		ld	b,3			; 3 przebiegi petli
		sub	6			; brak zaslon dla pierwszych 5  
		ld	c,a			; save i
		add	a,a			; i x 2	
		add	a,c			; i x 3 (3 potencjalne zaslony)
		ld	hl,list_indexes
		ld	e,a
;		ld	d,0
		add	hl,de			; wskaznik na index zaslony
	three:
		ld	a,(hl)	
		or	a
		jp	z,vsbl			; jak 0 - wypad
		ld	c,a			; Save index
		add	a,a
		add	a,c			; index x 3 ( y,x,char )
		ld	iy,fov_list		; od tego liczymy offsety
		ld	e,a
;		ld	d,0
		add	iy,de
		ld	a,(iy+2)		; Tile.char do sprawdzenia!
		cp	WALL_CHAR
		jp	z,printout
		cp	'+'
		jp	z,printout
		inc	hl
		djnz	three	
		jp	vsbl	

;=============
prev_fov:
;=============
		ld	b,18			; 16 przebiegow + DELIM
		ld	ix,prev_fov_list
.pfovloop:	push	bc
		ld	a,(ix)
		cp	DELIM
		jr	nz,prtbl
		pop	bc
		jr	out4
	prtbl:	ld	b,a
		ld	c,(ix+1)
		call	gotoyx
		ld	b,FLOOR_CHAR
		ld	a,(ix+2)
		cp	WALL_CHAR		; jesli nie sciana
		jr	nz,prtspc		; drukuje spacje 
		ld	b,PREV_WALL
	prtspc:
		ld	a,b
		call	pchar	
		inc	ix
		inc	ix
		inc	ix	
		pop	bc
		djnz	.pfovloop
	out4:	ret

; -------------------------------------------------------
; Oblicza i wypelnia wynikami tabele offsetow
; potencjalnie widzialnych Tiles - fov_offsets 
; -------------------------------------------------------
calc_fov:
		; --- EAST & NORTH --- 
		ld	iy,fov_n + 4	
		ld	ix,fov_e + 4
		ld	b,4			; glebokosc fov
		ld	d,0
		ld	e,10			; offset adresu od 5 do 2
		ld	a,(map_width)
		ld	c,a
	nxtrow:
		add	a,b
		ld	(ix+2),a	
;		ld	(ix+3),0	
		ld	a,b
		sub	c
		ld	(ix-2),a
		ld	(ix-1),0FFh
		ld	(ix),b
;		ld	(ix+1),0

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
		jr	c,ommit1
		ld	a,(ix+2)
		add	a,c
		ld	(ix+4),a
;		ld	(ix+5),0
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
	ommit1:
		add	ix,de
		add	iy,de
		dec	e	
		dec	e	
		ld	a,c
		djnz	nxtrow

		ld	(ix+2),a
;		ld	(ix+3),0
		neg
		ld	(ix),a
		ld	(ix+1),0FFh
		ld	(iy),-1
		ld	(iy+1),0FFh
		ld	(iy+2),1
;		ld	(iy+3),0
		;--- WEST & SOUTH ---
		ld	hl,fov_n
		ld	de,fov_s
		ld	b,36
	nxt1:	push	bc
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
		djnz	nxt1
		ret
DSEG	
main_counter:	db	0
;-------------------------------------------------------
; Sprite musza byc wyswietlane od zewnatrz fov do srodka
; Stad petla jedzie z dwoch stron do srodka. Rzeczywisty
; Licznik ( od 18 do 1 ) jest dodawany do tego adresu 
; i zdereferowany.
;-----------------------------------------------------
count_order	db 	0,1,2
		db	4,3,5
		db	7,6,8
		db	11,10,12,9,13
		db	16,15,17,14,18

;-----------------------------------------------------
; Indexy listy fov_list do sprawdzania czy jest tam
; cos, co zaslania ten Tile's
;-----------------------------------------------------
list_indexes   ; indeksy fov_list  | iteracje petli
		db	14, 0,0		;06
		db	14, 0,0		;07
		db	14, 0,0		;08
		db	15,12,0		;09
;		db	14,12,0		;10
		db	14,11,0		;10
		db	14,11,0		;11
;		db	14,10,0		;12
		db	14,11,0		;12
		db	13,10,0		;13
		db	15,12,8		;14
		db	14,12,8		;15
		db	14,11,7		;16
		db	14,10,6		;17
		db	13,10,6		;18

;--------------------------------------------------------------------------
; Lista obiektow wszystkich obiektow tile potencjalnie widocznych dla Hero
;--------------------------------------------------------------------------
fov_list	ds	54			; ( Y, X, char ) x 18
fov_list_end	
prev_fov_list	ds	55			; jw. + DELIM
iterator	dw	0000h			; iterator list

; -----------------------------------------------------------------
; Offset'y tiles wzgledem Hero - wypelniane przez funkcje calc_fov
; -----------------------------------------------------------------
fov_offsets:
	fov_n:	ds	36 			; North
	fov_e:	ds	36			; East	
	fov_s:	ds	36			; South
	fov_w:	ds	36			; West	
; -----------------------------------------------------
; Przesuniecia koordynatow tiles wzgledem Hero - stale
; -----------------------------------------------------
fov_coords
		db	-4,-2,  -4,-1,  -4,0,  -4,1,  -4,2		
		db	-3,-2,  -3,-1,  -3,0,  -3,1,  -3,2		
		db	        -2,-1,  -2,0,  -2,1
		db	        -1,-1,  -1,0,  -1,1
		db	         0,-1,          0,1

		db	-2,4,  -1,4,  0,4,  1,4,  2,4
		db	-2,3,  -1,3,  0,3,  1,3,  2,3
		db	       -1,2,  0,2,  1,2
		db	       -1,1,  0,1,  1,1
		db	       -1,0,        1,0

		
		db	 4,2,  4,1,  4,0,  4,-1,  4,-2		
		db	 3,2,  3,1,  3,0,  3,-1,  3,-2		
		db	       2,1,  2,0,  2,-1
		db	       1,1,  1,0,  1,-1
		db	       0,1,        0,-1

		db	 2,-4,  1,-4,  0,-4,  -1,-4,  -2,-4
		db	 2,-3,  1,-3,  0,-3,  -1,-3,  -2,-3
		db	        1,-2,  0,-2,  -1,-2
		db	        1,-1,  0,-1,  -1,-1
		db	        1,0,        -1,0
; Tabela przesuniec w tabeli fov_coord. Przesuniecie zalezy od zwrotu Hero
fov_shift	db	0, 36, 72, 108
; Pola wskaznikow
coords_pointer	dw	0000h
offset_pointer	dw	0000h
counter		db	00h
