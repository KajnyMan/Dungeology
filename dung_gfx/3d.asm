printwall_3d:	
print_c_door_3d:	
print_o_door_3d:	
		ld	hl,wall_sprites
		jr	common

		ld	hl,c_door_sprites
		jr	common

		ld	hl,o_door_sprites

	common:	ld	a,(main_counter)
		dec	a
		add	a,a
		ld	d,0
		ld	e,a
		add	hl,de			; adres wskaznika na Sprite
		ld	e,(hl)
		inc	hl
		ld	d,(hl)			; adres Sprite w HL
		push	de
		pop	iy			; tenze adres w IY
		inc	iy			; ominiecie licznika petli
		
		ld	b,(iy-1)		; tenze licznik ustawiony
		ld	a,b			; jesli zero to nie ma sprite'a
		or	a			; w tej pozycji, a wiec wypad
		jp	z,printout
	nxt:	push	bc
		ld	b,(iy+1)
		ld	c,(iy+2)		; offset Y,X w BC	
		ld	hl,(w3d_position)
		add	hl,bc			; dodanie pozycji okna 3D 
		ld	b,h
		ld	c,l

		call	gotoyx			; Kursor ustawiony

		push	iy
		pop	bc
		inc	bc
		inc	bc
		inc	bc
		call	ptile			; Drukuje tile	

		ld	d,0
		ld	e,(iy)			; Ustawia wskaznik na
		add	iy,de			; nastepna linie sprite'a
		pop	bc	
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
;			ile lini, ile B stad do nastepnej lini, Y, X, string
w18		db	0, 9, 3, 0, "~~~~'$"
w17		db	0,10, 3, 4, "'~~~~'$"
w16		db	0,10, 3, 9, "'~~~~'$"
w15		db	0,10, 3,14, "'~~~~'$"
w14		db	0, 9, 3,19, "'~~~~$"

w13		db	2, 6, 2, 0,		38, 38, $FF
		db	   6, 3, 0,		39, 39, $FF

w12		db	2, 6, 2, 2,		38, 38, $FF
		db	   6, 3, 2,		39, 39, $FF

w11		db	2, 5, 2, 4,		38, $FF
		db	   5, 3, 4,		39, $FF

w10		db	2, 6, 2, 5,		38, 38, $FF
		db	   6, 3, 5,		39, 39, $FF

w09		db	2, 6, 2, 7,		38, 38, $FF
		db	   6, 3, 7,		39, 39, $FF

w08		db	2, 8, 2, 0,		32, 33, 33, 34, $FF
		db	   8, 3, 0,		32, 33, 33, 35, $FF

w07		db	2, 7, 2, 3,		32, 33, 33, $FF 
		db	   7, 3, 3,		32, 33, 33, $FF 

w06		db	2, 8, 2, 5,		36, 32, 33, 33, $FF	
		db	   8, 3, 5,		37, 32, 33, 33, $FF

w05		db	4, 7, 1, 0,		3, 16, 17, $FF
		db	   7, 2, 0,		2, 18, 19, $FF
		db	   7, 3, 0,		1, 20, 21, $FF
		db	   7, 4, 0,		0, 22, 23, $FF

w04		db	4, 11, 1, 1,	2, 0, 1, 0, 1, 2, 3, $FF
		db	   11, 2, 1,	0, 3, 0, 1, 2, 1, 2, $FF
		db	   11, 3, 1,	2, 0, 1, 2, 1, 0, 1, $FF
		db	   11, 4, 1,	0, 1, 0, 1, 2, 1, 0, $FF

w03		db	4, 7, 1, 6,		24, 25, 2, $FF
		db	   7, 2, 6,		26, 27, 0, $FF
		db	   7, 3, 6,		28, 29, 2, $FF
		db	   7, 4, 6,		30, 31, 0, $FF
		 
w02		db	6, 5, 0, 0,		4, $FF
		db	   5, 1, 0,		5, $FF 
		db	   5, 2, 0,		6, $FF 
		db	   5, 3, 0,		7, $FF 
		db	   5, 4, 0,		8, $FF
		db	   5, 5, 0,		9, $FF 
			   
w01		db	6, 5, 0, 8,		10, $FF
		db	   5, 1, 8,		11, $FF
		db	   5, 2, 8,		12, $FF
		db	   5, 3, 8,		13, $FF
		db	   5, 4, 8,		14, $FF
		db	   5, 5, 8,		15, $FF

wall_sprites	dw	    w01,    w02
		dw	    w03,w04,w05
		dw	    w06,w07,w08
		dw	w09,w10,w11,w12,w13
		dw	w14,w15,w16,w17,w18

; Drzwi zamkniete
d18		db	1, 9, 3, 0, "~^^~'$"
d17		db	1,10, 3, 4, "'~^^~'$"
d16		db	1,10, 3, 9, "'~^^~'$"
d15		db	1,10, 3,14, "'~^^~'$"
d14		db	1, 9, 3,19, "'~^^~$"

d13		db	2, 6, 2, 0, "_,$"
		db	   8, 3, 0, "-|^''$"

d12		db	2,12, 2, 1, ",__pq__,$"
		db	  13, 3, 1, "|--[]--|'$"

d11		db	2,12, 2, 8, ",__pq__,$"
		db	  12, 3, 8, "|--[]--|$"

d10		db	2,13, 2,14, " ,__pq__,$"
		db	  13, 3,14, "'|--[]--|$"

d09		db	2, 9, 2,19, "   ,_$"
		db	   9, 3,19, "''^|-$"

d08		db	3,13, 2, 0, "/\\]~~~T',$"
		db	  13, 3, 0, "<*I~_~|-|$"
		db	  12, 4, 0, "nn]---|'$"

d07		db	3,16, 2, 6, "T~~'[/\\]~~~T$"
		db	  16, 3, 6, "|_~_I<*I~_~|$"
		db	  16, 4, 6, "|---[nn]---|$"

d06		db	3,13, 2,15, ",'T~~'[/\\$"
		db	  13, 3,15, "|-|_~_I<*$"
		db	  12, 4,16,  "'|---[nn$"

d05		db	5,10, 1, 0, "~~~TI.$"
		db	  11, 2, 0, " - |I T$"
		db	  11, 3, 0, "<- |[<|$"
		db	  11, 4, 0, " - |I i$"
		db	  10, 5, 0, ".,.|I'$"

d04		db	5,22, 1, 3, "T~~~'[]/()\\[]'~~~T$"
		db	  22, 2, 3, "|- - ||mnnm||- - |$"
		db	  22, 3, 3, "| - -||< C || - -|$"
		db	  22, 4, 3, "|- - ||mnnm||- - |$"
		db	  22, 5, 3, "|..,.[]mmmm[],.,.|$"

d03		db	5,11, 1,17, " .IT~~~$"
		db	  11, 2,17, "T I|- -$"
		db	  11, 3,17, "|<]| ->$"
		db	  11, 4,17, "i I|- -$"
		db	  11, 5,17, " 'I|..,$"

d02		db	8, 7, 0, 0, "T',$"
		db	   8, 1, 0, "l  T$"
		db	   8, 2, 0, "I' |$"
		db	   8, 3, 0, "l<-|$"
		db	   8, 4, 0, "I .|$"
		db	   8, 5, 0, "l' |$"
		db	   7, 6, 0, "I .$"
		db	   6, 7, 0, "l'$"
			   
d01		db	8, 8, 0,20, " ,'T$"
		db	   8, 1,20, "T  |$"
		db	   8, 2,20, "| 'I$"
		db	   8, 3,20, "|->l$"
		db	   8, 4,20, "|. |$"
		db	   8, 5,20, "| '|$"
		db	   8, 6,20, "'. I$"
		db	   8, 7,20, "  'J$"


c_door_sprites	dw	    d01,    d02
		dw	    d03,d04,d05
		dw	    d06,d07,d08
		dw	d09,d10,d11,d12,d13
		dw	d14,d15,d16,d17,d18

;  Drzwi otwarte
o18		db	1, 9, 3, 0, "~  ~'$"
o17		db	1,10, 3, 4, "'~  ~'$"
o16		db	1,10, 3, 9, "'~  ~'$"
o15		db	1,10, 3,14, "'~  ~'$"
o14		db	1, 9, 3,19, "'~  ~$"


o13		db	0
o12		db	2,12, 2, 1, ",__..__,$"
		db	  13, 3, 1, "|--||--|'$"

o11		db	2,12, 2, 8, ",__..__,$"
		db	  12, 3, 8, "|--||--|$"

o10		db	2,13, 2,14, " ,__..__,$"
		db	  13, 3,14, "'|--||--|$"

o09		db	0

o08		db	0

o07		db	6, 9, 2, 6, "T~~'[$",	9,2,13,"]~~~T$"
		db	   9, 3, 6, "|_~_I$",	9,3,13,"I~_~|$"
		db	   9, 4, 6, "|---[$",	9,4,13,"]---|$"

o06		db	0

o05		db	0
o04		db	10,10, 1, 3, "T~~~'[$",   10, 1,15, "]'~~~T$"
		db	   10, 2, 3, "|- - |$",   10, 2,15, "|- - |$"
		db	   10, 3, 3, "| - -|$",   10, 3,15, "| - -|$"
		db	   10, 4, 3, "|- - |$",   10, 4,15, "|- - |$"
		db	   10, 5, 3, "|..,.[$",   10, 5,15, "],.,.|$"
o03		db	0

o02		db	0
o01		db	0

o_door_sprites	dw	    o01,    o02
		dw	    o03,o04,o05
		dw	    o06,o07,o08
		dw	o09,o10,o11,o12,o13
		dw	o14,o15,o16,o17,o18
