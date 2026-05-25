printwall_3d:	
		ld	hl,wall_sprites
		ld	b,W3D_ATR
		jr	_common
print_c_door_3d:	
		ld	hl,c_door_sprites
		ld	b,W3D_ATR
		jr	_common
print_o_door_3d:	
		ld	hl,o_door_sprites
		ld	b,W3D_ATR
		jr	_common
print_key_3d:
		ld	hl,key_sprites
		ld	b,KEY_ATR
		jr	_common
print_weapon_3d:
		ld	hl,weapon_sprites
		ld	b,WEAPON_ATR
		jr	_common
print_armour_3d:
		ld	hl,armour_sprites
		ld	b,ARMOUR_ATR

_common
		ex	af,af'
		ld	a,b
		ex	af,af'
		ld	a,(main_counter)
		dec	a
		add	a,a
		ld	d,0
		ld	e,a
		add	hl,de			; adres wskaznika na Sprite
		ld	e,(hl)
		inc	hl
		ld	d,(hl)			; iterator DE na Sprite 

_direct
		ld	a,(de)
		or	a				; jesli zero to nie ma sprite'a
		jp	z,_printout		; w tej pozycji, a wiec wypad
		ld	b,a				; licznik lini ustawiony
		inc	de				; iterator na Y 
_nxt
		push	bc			; SAVE licznik
		ld	a,(de)
		ld	b,a
		inc	de				; iterator na X
		ld	a,(de)
		ld	c,a				; offset Y,X w BC	
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
		djnz	_nxt
		jp	_printout

print_figure_3d:
		ld	a,(main_counter)
		cp	4					; stwor przed Hero
		jp	nz,_printout		

		ld	de,f04
		ex	af,af'
		ld	a,FIGURE_ATR
		ex	af,af'
		jr	_direct	
		
		include figure.asm
		include data/sprites.dat
