;-------------------------------------------;
; 	D U N G E O L O G Y - zx spectrum
;-------------------------------------------;

	DEVICE	ZXSPECTRUM48
	EMPTYTAP "dng.tap"
		
		include	struct.def
		include	macro.def
		include	const.def
		include	loader.asm

		org	TILES

Start:
		include tiles.dat

; ================
;  Code Start
; ================
CodeStart:
		di
		
		include	init.asm
		
; ===============  M A I N    L O O P =================

		jp	_begin

refresh:
		; czyszczenie okna fov
		ld	hl,FOV_ADR	
		ld	b,FOV_HEIGHT
		call	clear_txtlines

		; czyszczenie okna 3d
		ld	hl,W3D_ADR
		ld	b,W3D_HEIGHT
		call	clear_txtlines
_begin
		; "wygaszone" okno 3D przy rysowaniu
		ld	a,BLACK_BGD OR BLACK
		ld	b,W3D_HEIGHT
		ld	c,W3D_WIDTH
		ld	de, W3D_YX
		call set_atr_block

		; -----------------------
		; Pole widzenia na ekran
		; -----------------------
		call	field_of_view		; fov.z80

		; -----------------------
		;  "widzialnosc" okna 3D
		; -----------------------
		ld	a,BLACK_BGD OR BLUE OR BRIGHT
		ld	b,W3D_HEIGHT
		ld	c,W3D_WIDTH
		ld	de, W3D_YX
		call set_atr_block
;		atrbuf_2_atr
		
		; --------------	
		; Hero na ekran	
		; --------------
		ld	hl,hero_i		; ikona hero
		ld	a,(hero.direction)		; w zaleznosci
		ld	b,0				; od kierunku
		ld	c,a				; i zwrotu
		add	hl,bc			; ^ > v <
		ld	a,(hl)
		ld	bc,HERO_YX		; stala pozycja HERO na ekranie

		ld	h,a				; SAVE char
		call	gotoyx
		ld	a,h				; RESTORE char

		call	pchar
		
		ld	a, HERO_ATR
		ld	de,HERO_YX
		call	set_atr

wait_release:
		call	scan_keyboard	
		or	a
		jr	nz,wait_release

key_press:
		call	scan_keyboard	

		cp	0
		jp	z,key_press
		cp	1
		jp	z,ismove	; bit 0: I
		cp	2
		jr	z,trn_r		; bit 1: L
		cp	4
		jp	z,move_door	; bit 2: K
		cp	8
		jp	z,trn_l		; bit 3: J
		cp	16
		jp	z,search	; bit 4: S
		cp	32
		jp	z,take_item	; bit 5: T

		jr	key_press

; -------------------------
trn_r:
		call	message_area_clear
		ld	hl,hero.direction
		inc	(hl)
		ld	a,(hl)
		cp	WEST+1
		jp	nz,refresh
		ld	(hl),NORTH
		jp	refresh
trn_l:
		call	message_area_clear
		ld	hl,hero.direction
		dec	(hl)
		ld	a,(hl)
		cp	NORTH-1
		jp	nz,refresh
		ld	(hl),WEST
		jp	refresh

; otwiera lub zamyka drzwi
move_door:
		call	message_area_clear
		call	right_before
		cp	C_DOOR_CHAR	
		jr	z,_print_door_nr
		cp	O_DOOR_CHAR	
		jr	z,_print_door_nr
		jp	key_press			; nie ma tutaj drzwi! Wypad
_print_door_nr
		push	hl				; save adresu drzwi
		call	room_label
		PRINT_STR	MSG_LINE1 + $A, msg_door
		pop		hl				; restore
		ld	a,(hl)
		cp	O_DOOR_CHAR	
		jr	z,close_door
		
open_door:
		call	check_key
		jr	z,_no_key
		ld	(hl),O_DOOR_CHAR		
		jp	refresh
_no_key
		PRINT_STR	MSG_LINE2 + $A, msg_nokey
		jp	wait_release	
close_door:
		ld	(hl),C_DOOR_CHAR		
		ld	a,(door_nr)
		call	remove_key
		jp	refresh

;-------------------------------------------------
; Zmienia pozycje Hero
; IN: DE - nowa pozycja ( offset wzgl. MAP )
;-------------------------------------------------
move:
		ld	(hero.offset),de	; Hero new offset
		ld	hl,hero_s	; /
		ld	a,(hero.direction)	; Przesuniecie kursora
		add	a,a		; do nowej pozycji
		ld	e,a		; Hero
		ld	d,00h
		add	hl,de
		ld	a,(hero.mapX)
		add	a,(hl)
		ld	(hero.mapX),a
		inc	hl
		ld	a,(hero.mapX)
		add	a,(hl)
		ld	(hero.mapY),a	; \____________
		ret

;-----------------------------------------
; Funkja wypluwa:
; w A - char Tile bezposrednio przed Hero 
; e DE - jego OFFSET wzgl. MAP
; w HL - jego ADRESS 
;-----------------------------------------
right_before:
		ld	hl,neighbor_offs
		ld	de,(hero.direction)
		ld	d,00h
		add	hl,de		; adres offset'u Tile wzgl Hero
		ld	e,(hl)
		bit	7,e
		jr	z,_addit
		ld	d,0FFh
_addit	ld	hl,(hero.offset)
		add	hl,de	
		ex	de,hl		; offset Tile wzgl mapy 
		ld	hl,MAP
		add	hl,de		; ADRES TILE PRZED HERO !
		ld	a,(hl)		; a w A jego ikona (ascii)
		ret

;--------------------------------------------
; Szuka ukrytych przejsc itp.
;--------------------------------------------
search:
	;	call	message_area_clear
		PRINT_STR	MSG_LINE1 + $9, msg_searching
		call 	right_before

		push	hl					; save adres char przed Hero

		; ukryte przejscie ?
		ld	b,OBJ_MAX
		ld	hl,passages
		call	check_offset16		; w HL msb offsety znalezionego objektu

		pop		de					; restore

		cp	0FFh					; a moze nic tu nie ma?
		jp	z,_nothing_here	

		ld	a,FLOOR_CHAR
		ld	(de),a					; jesli przejcie to zburz mur
		ld	(hl),0					; Zeruje ten offset na liscie
		dec	hl						; nieodkrytych
		ld	(hl),0					; przejsc
		PRINT_STR	MSG_LINE2 + $8, msg_psgfinded
		jp	refresh

_nothing_here
		PRINT_STR	MSG_LINE2 + $8, msg_nothing
		jp	wait_release

; ----------------------------------------------------
; Jak cos jest pod nogami wsadza do plecaka 
; ----------------------------------------------------
take_item:
		call	message_area_clear
		PRINT_STR	MSG_LINE1 + $9, msg_floor
		call	search_floor
		ld	a,c
		cp	KEY_CHAR
		jp	z,take_key
		cp	WEAPON_CHAR
		jp	z,take_weapon
		cp	ARMOUR_CHAR
		jp	z,take_armour

		; jesli nic nie ma to komunikat ze nic nie ma
		PRINT_STR	MSG_LINE2 + $9, msg_dust
		jp wait_release	

; ----------------------------------------------------
; Sprawdza co lezy pod nogami.
; OUT:	C - char przedmiotu 
;		HL - jego adress	
;		DE - i offset
; ----------------------------------------------------
search_floor:
		ld	de,(hero.offset)
		ld	hl,MAP
		add	hl,de
		ld	c,(hl)
		ret

; --------------------------------------
; Sprawdza czy jest klucz do tych drzwi
; OUT:	A = 0 nie ma klucza, A != 0 jest 
; --------------------------------------
check_key:
		ld	a,(door_nr)
		ld	de,hero.bag.keys
		call	nr_to_bit
		and	c
		ret

; ----------------------------------------------------
; Wyjmuje klucz z otwartych drzwi i laduje do plecaka 
; IN:	A - nr drzwi
; ----------------------------------------------------
remove_key:
		ld	de,hero.bag.keys
		call	nr_to_bit
		or	c
		ld	(de),a
		ret

; ----------------------------------------------------
; Podnosi klucz z gleby i laduje do plecaka 
; IN:	C - char klucza
; ----------------------------------------------------
take_key:
		call	search_map
		ld	hl,key_door_nr
		add	hl,de
		ld	a,(hl)
		call	remove_key
		PRINT_STR	MSG_LINE2 + $9, msg_key
		jp	wait_release

; ----------------------------------------------------
; Podnosi bron z gleby i laduje do plecaka 
; IN:	C - char broni
; ----------------------------------------------------
take_weapon:
		call	search_map
		ld	hl,weapon_pow
		add	hl,de
		ld	a,(hl)
		ld	(hero.bag.weapon),a
		PRINT_STR	MSG_LINE2 + $9, msg_weapon
		ld	hl,hero.bag.weapon
		ld	de,hero.stat.str
		call	equip
		jp	wait_release

; ----------------------------------------------------
; Podnosi zbroje z gleby i laduje do plecaka 
; IN:	C - char zbroi 
; ----------------------------------------------------
take_armour:
		call	search_map
		ld	hl,armour_pow
		add	hl,de
		ld	a,(hl)
		ld	(hero.bag.armour),a
		ld	hl,hero.bag.armour
		ld	de,hero.stat.def
		call	equip
		PRINT_STR	MSG_LINE2 + $9, msg_armour
		jp	wait_release

; ----------------------------------------------------
; Wyciaga item z plecaka celem uzywania
; IN:	HL - adres item w plecaku
;		DE - adres statystyki, na ktora wplywa
; ----------------------------------------------------
equip:
		ld	c,(hl)
		ld	a,(de)
		add	a,c
		ld	(de),a
		call	update_stat_strings 
		call	print_stat_info
		ret

; ----------------------------------------------------
; Przeszukuje mape w poszukiwaniu char'a
; IN:	C - char do znalezienia
;		HL - adres do sprawdzenia
; OUT:	B, DE	- ktory w kolejnosci na MAP'e	
; ----------------------------------------------------
search_map:
		ex	de,hl				; adres do znalezienia w DE
		ld	b,0					; licznik C char'ow
		ld	hl,MAP
_not_this
		ld	a,(hl)	
		cp	c
		jr	z,_maybe_this
		inc	hl
		jr	_not_this	
_maybe_this
		ld	a,e
		cp	l
		jr	z,_check_msb
		inc hl
		inc	b					; char ten, ale nie ten adres
		jr _not_this			; jednak nie
_check_msb
		ld	a,d
		cp	h
		jr	z,_this_one
		inc	hl
		inc	b					; char ten, ale nie ten adres
		jr _not_this			; no nie
_this_one
		ld	(hl),FLOOR_CHAR		; wziety z gleby
		ld	d,0
		ld	e,b
		ret

;-------------------------------------------------------
; Przeszukuje po offsecie liste wszystkich drzwi
; Drukuje nr na drzwiach przed Hero i wbija do zmiennej
; IN:  DE - offset drzwi ( wzgl. map )
; USED : A, BC, HL
;-------------------------------------------------------
room_label:
		ld	b,OBJ_MAX
		ld	hl,doors
		call	check_offset16
		inc	a
		ld	(door_nr),a			; do zmiennej
		call	h2asci			; zamiana na ascii do druku
		ld	hl,msg_door_nr
		ld	(hl),c
		inc	hl
		ld	(hl),b
		ret
		
;------------------------------------------------------------------
; szuka 16-bitowego offsetu na liscie objektow 
; IN:	DE - offset do wyszukania
; 	HL - adres listy offsetow objektow ( H - msb )
; OUT:	A  - jesli FFh = nie znaleziony offset
;	, w przeciwnym razie index znalezionego objektu na liscie ( od 0 )
; USED:	A, C, HL
;------------------------------------------------------------------
check_offset16:
		ld	c,b		; save licznik objektow
		ld	a,e
_cell
		cp	(hl)
		inc	hl
		jr	nz,_msb
		ld	a,d
		cp	(hl)
		jr	nz,_lsb
		jr	_finded
_lsb
		ld	a,e
_msb
		inc	hl
		djnz	_cell	
		ld	a,0FFh
		ret
_finded	
		ld	a,c		; restore
		sub	b		; index znalezionego objektu ( od 0 )
		ret	
;------------------------------------------------------
; Wbija biezace statystyki hero do stringow stat_info
; USED: wszystko
;------------------------------------------------------
update_stat_strings:
		ld	hl,stat_info + 4
		ld	de,hero.stat.hp
		ld	b,3
_nxt_stat
		push	bc
		ld	a,(de)	
		call	h2asci
		ld	(hl),c
		inc	hl
		ld	(hl),b
		inc	de
		ld	b,0
		ld	c,6
		add	hl,bc
		pop		bc
		djnz	_nxt_stat
		; etykieta broni i zbroi
		ld	b,LABELS_NUMBER
		ld	a,(hero.bag.weapon)
		ex	de,hl				; w DE miejsce w stringu
		ld	hl,weapon_names

_modify_string

		push	bc

		ld	b,a
		add	a,a
		add	a,b							; x3
		ld	b,0
		ld	c,a
		add	hl,bc
		ld	bc,3						; ( x3 litery )		
		ldir

		ld	a,(hero.bag.armour)
		ld	hl,5
		add	hl,de	
		ex	de,hl
		ld	hl,armour_names

		pop		bc	

		djnz	_modify_string

		ret	
;------------------------------------------------------
; Drukuje statystyki 
;------------------------------------------------------
print_stat_info:
		ld	bc,stat_info		
		ld	de,INF_ADR
		ld	h,5				;  ilosc etykiet
_nxt_label
		push	hl
		push	de

		call	pstring_global

		inc	bc	
		pop		de
		ld	hl,32
		add	hl,de
		ex	de,hl
		pop		hl
		dec	h
		jr	nz,_nxt_label
		ret
		
;------------------------	
; Wyjscie
;------------------------
_halt:
		ei
		ret

;--------------------------

		include screen.asm
		include	fov.asm
		include 3d.asm
		include math.asm 
		include keyboard.asm

		include	vars.dat
		include	messages.dat
		include map.dat

;==================

End:

    ; drugi blok (CODE) na tasme
    SAVETAP "dng.tap", CODE, "Dungeology", Start, End - Start
