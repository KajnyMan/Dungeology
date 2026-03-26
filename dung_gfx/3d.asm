printwall_3d:	
		ld	hl,wall_sprites
		ld	d,WALL3D_ATR
		jr	common

print_c_door_3d:	
		ld	hl,c_door_sprites
		ld	d,C_DOOR3D_ATR
		jr	common
print_o_door_3d:	
		ld	hl,o_door_sprites
		ld	d,O_DOOR3D_ATR

	common:
		ex	af,af'
		ld	a,d
		ex	af,af'			; atrybut Tile przygotowany
		ld	a,(main_counter)
		dec	a
		add	a,a
		ld	d,0
		ld	e,a
		add	hl,de			; adres wskaznika na Sprite
		ld	e,(hl)
		inc	hl
		ld	d,(hl)			; iterator DE na Sprite 

		ld	a,(de)
		or	a				; jesli zero to nie ma sprite'a
		jp	z,printout		; w tej pozycji, a wiec wypad
		ld	b,a				; licznik lini ustawiony
		inc	de				; iterator na Y 
	nxt:
		push	bc			; SAVE licznik
		ld	a,(de)
		ld	b,a
		inc	de				; iterator na X
		ld	a,(de)
		ld	c,a				; offset Y,X w BC	
		
;		ld	hl,(w3d_position)
		ld	hl,W3D_YX
		add	hl,bc			; dodanie pozycji okna 3D 
		ld	b,h
		ld	c,l				; Y, X ekranu dla poczatku lini Tile w BC 

		push	de				; SAVE iterator
		call	gotoyx			; Kursor ustawiony

		pop	bc					; RESTORE iterator 
		inc	bc					; tenze na pierwszym bajcie Tile	
		call	print_tile_line
								; iterator BC na TILE_EOL
		inc	bc
		ld	d,b
		ld	e,c					; iterator DE na Y nastepnej lini Tile
		
		pop		bc				; RESTORE licznik
		djnz	nxt
		jp	printout

;------------------------------------------------
; Przeszukuje po offsecie liste wszystkich drzwi
; i drukuje nr na drzwiach przed Hero
; w DE: offset drzwi ( wzgl. MAP )
;------------------------------------------------
roomlabel:
		ld	hl,doors	
		ld	a,e
		ld	b,1			; drzwi nr 1 - najnizszy offset
	.loop1:	cp	(hl)
		inc	hl
		jr	nz,.nxt1
		ld	a,d
		cp	(hl)	
		jr	nz,.nxt2
		jr	finded
	.nxt2:	ld	a,e
	.nxt1:	inc	hl
		inc	hl
		inc	b
		jr	.loop1	
		ret
	finded:	ld	a,b	
		ld	(door_before),a		; nr drzwi do zmiennej
		call	h2asci			; zamiana na ascii do druku
		push	ix
		ld	ix,d04
		ld	(ix+12),c
		ld	(ix+13),b
		pop	ix
		ret
		
space_string	ds	24,' '
				db	'$'

w18		db	1
		db	3, 0,		44, 44, $FF		

w17		db	1
		db	3, 2,		44, 44, $FF		

w16		db	1
		db	3, 4,		44, $FF		

w15		db	1
		db	3, 5,		44, 44, $FF		

w14		db	1
		db	3, 7,		44, 44, $FF		

w13		db	2
		db	2, 0,		38, 38, 42, $FF
		db  3, 0,		39, 39, 43, $FF

w12		db	2
		db	2, 2,		38, 38, 42, $FF
		db  3, 2,		39, 39, 43, $FF

w11		db	2
		db	2, 4,		38, $FF
		db  3, 4,		39, $FF

w10		db	2
		db	2, 4,		40, 38, 38, $FF
		db  3, 4,		41, 39, 39, $FF

w09		db	2
		db	2, 6,		40, 38, 38, $FF
		db  3, 6,		41, 39, 39, $FF

w08		db	2
		db	2, 0,		32, 33, 33, 34, $FF
		db  3, 0,		32, 33, 33, 35, $FF

w07		db	2
		db	2, 3,		32, 33, 33, $FF 
		db  3, 3,		32, 33, 33, $FF 

w06		db	2
		db	2, 5,		36, 32, 33, 33, $FF	
		db  3, 5,		37, 32, 33, 33, $FF

w05		db	4
		db	1, 0,		3, 16, 17, $FF
		db  2, 0,		2, 18, 19, $FF
		db  3, 0,		1, 20, 21, $FF
		db  4, 0,		0, 22, 23, $FF

w04		db	4
		db	1, 1,	2, 0, 1, 0, 1, 2, 3, $FF
		db	2, 1,	0, 3, 0, 1, 2, 1, 2, $FF
		db	3, 1,	2, 0, 1, 2, 1, 0, 1, $FF
		db	4, 1,	0, 1, 0, 1, 2, 1, 0, $FF

w03		db	4
		db	1, 6,		24, 25, 2, $FF
		db  2, 6,		26, 27, 0, $FF
		db  3, 6,		28, 29, 2, $FF
		db  4, 6,		30, 31, 0, $FF
		 
w02		db	6
		db	0, 0,		4, $FF
		db  1, 0,		5, $FF 
		db  2, 0,		6, $FF 
		db  3, 0,		7, $FF 
		db  4, 0,		8, $FF
		db  5, 0,		9, $FF 
			   
w01		db	6
		db	0, 8,		10, $FF
		db  1, 8,		11, $FF
		db  2, 8,		12, $FF
		db  3, 8,		13, $FF
		db  4, 8,		14, $FF
		db  5, 8,		15, $FF

wall_sprites	dw	    w01,    w02
		dw	    w03,w04,w05
		dw	    w06,w07,w08
		dw	w09,w10,w11,w12,w13
		dw	w14,w15,w16,w17,w18

; Drzwi zamkniete
d18		db	1
		db	3, 0,		44, 44, $FF		
d17		db	1
		db	3, 2,		44, 44, $FF		
d16		db	1
		db	3, 4,		44, $FF		
d15		db	1
		db	3, 5,		44, 44, $FF		
d14		db	1
		db	3, 7,		44, 44, $FF		
d13		db	2
		db	2, 0,		38, 38, 42, $FF
		db  3, 0,		39, 39, 43, $FF
d12		db	2
		db	2, 2,		38, 38, 42, $FF
		db  3, 2,		39, 39, 43, $FF
d11		db	2
		db	2, 4,		38, $FF
		db  3, 4,		39, $FF
d10		db	2
		db	2, 4,		40, 38, 38, $FF
		db  3, 4,		41, 39, 39, $FF
d09		db	2
		db	2, 6,		40, 38, 38, $FF
		db  3, 6,		41, 39, 39, $FF
d08		db	2
		db	2, 0,		32, 33, 33, 34, $FF
		db  3, 0,		32, 33, 33, 35, $FF
d07		db	2
		db	2, 3,		64, 66, 65, $FF 
		db  3, 3,		64, 67, 65, $FF 
d06		db	2
		db	2, 5,		36, 32, 33, 33, $FF	
		db  3, 5,		37, 32, 33, 33, $FF
d05		db	4
		db	1, 0,		3, 16, 17, $FF
		db  2, 0,		2, 18, 19, $FF
		db  3, 0,		1, 20, 21, $FF
		db  4, 0,		0, 22, 23, $FF
d04		db	4
		db	1, 1,	2, 0, 51, 46, 45, 2, 3, $FF
		db	2, 1,	0, 3, 47, 50, 48, 0, 2, $FF
		db	3, 1,	2, 0, 47, 50, 49, 0, 1, $FF
		db	4, 1,	0, 1, 51, 46, 45, 0, 0, $FF
d03		db	4
		db	1, 6,		24, 25, 2, $FF
		db  2, 6,		26, 27, 0, $FF
		db  3, 6,		28, 29, 2, $FF
		db  4, 6,		30, 31, 0, $FF
d02		db	6
		db	0, 0,		4, $FF
		db  1, 0,		5, $FF 
		db  2, 0,		6, $FF 
		db  3, 0,		7, $FF 
		db  4, 0,		8, $FF
		db  5, 0,		9, $FF 
d01		db	6
		db	0, 8,		10, $FF
		db  1, 8,		11, $FF
		db  2, 8,		12, $FF
		db  3, 8,		13, $FF
		db  4, 8,		14, $FF
		db  5, 8,		15, $FF

c_door_sprites	dw	    d01,    d02
		dw			    d03,d04,d05
		dw				d06,d07,d08
		dw			d09,d10,d11,d12,d13
		dw			d14,d15,d16,d17,d18

;  Drzwi otwarte
o18		db	1
		db	3, 0,		44, 44, $FF		
o17		db	1
		db	3, 2,		44, 44, $FF		
o16		db	1
		db	3, 4,		44, $FF		
o15		db	1
		db	3, 5,		44, 44, $FF		
o14		db	1
		db	3, 7,		44, 44, $FF		
o13		db	2
		db	2, 0,		38, 38, 42, $FF
		db  3, 0,		39, 39, 43, $FF
o12		db	2
		db	2, 2,		38, 38, 42, $FF
		db  3, 2,		39, 39, 43, $FF
o11		db	2
		db	2, 4,		38, $FF
		db  3, 4,		39, $FF
o10		db	2
		db	2, 4,		40, 38, 38, $FF
		db  3, 4,		41, 39, 39, $FF
o09		db	2
		db	2, 6,		40, 38, 38, $FF
		db  3, 6,		41, 39, 39, $FF
o08		db	2
		db	2, 0,		32, 33, 33, 34, $FF
		db  3, 0,		32, 33, 33, 35, $FF
o07		db	2
		db	2, 3,		32, 33, 33, $FF 
		db  3, 3,		32, 33, 33, $FF 
o06		db	2
		db	2, 5,		36, 32, 33, 33, $FF	
		db  3, 5,		37, 32, 33, 33, $FF
o05		db	4
		db	1, 0,		3, 16, 17, $FF
		db  2, 0,		2, 18, 19, $FF
		db  3, 0,		1, 20, 21, $FF
		db  4, 0,		0, 22, 23, $FF
o04		db	8
		db	1, 1,		2, 0, $FF, 1, 6,	2, 3, $FF
		db	2, 1,		0, 3, $FF, 2, 6,	0, 2, $FF
		db	3, 1,		2, 0, $FF, 3, 6,	0, 1, $FF
		db	4, 1,		0, 1, $FF, 4, 6,	0, 0, $FF
o03		db	4
		db	1, 6,		24, 25, 2, $FF
		db  2, 6,		26, 27, 0, $FF
		db  3, 6,		28, 29, 2, $FF
		db  4, 6,		30, 31, 0, $FF
o02		db	6
		db	0, 0,		4, $FF
		db  1, 0,		5, $FF 
		db  2, 0,		6, $FF 
		db  3, 0,		7, $FF 
		db  4, 0,		8, $FF
		db  5, 0,		9, $FF 
o01		db	6
		db	0, 8,		10, $FF
		db  1, 8,		11, $FF
		db  2, 8,		12, $FF
		db  3, 8,		13, $FF
		db  4, 8,		14, $FF
		db  5, 8,		15, $FF

o_door_sprites	dw	    o01,    o02
		dw	    o03,o04,o05
		dw	    o06,o07,o08
		dw	o09,o10,o11,o12,o13
		dw	o14,o15,o16,o17,o18
