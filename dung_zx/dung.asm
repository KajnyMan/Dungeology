;-------------------------------------------;
; 	D U N G E O L O G Y - zx spectrum
;-------------------------------------------;

NORTH		equ	0
EAST		equ	1
SOUTH		equ	2
WEST		equ	3

MAP_HEIGHT	equ	12
MAP_WIDTH	equ	32
W3D_HEIGHT	equ	8
W3D_WIDTH	equ	24
WALL_CHAR	equ	'#'
FLOOR_CHAR	equ	' '
C_DOOR		equ	'+'
O_DOOR		equ	'/'
PASSAGE_CHAR	equ	'='
STRING_DELIM	equ	'$'
OBJ_MAX		equ	32

FONTS		equ	3D00h	
SCREEN		equ	4000h
SCREEN_ATR	equ	5800h
ATR_MIDDLE_AREA	equ	5A00h
ATR_LOW_AREA	equ	5B00h

CS_V		equ	0FEh
A_G		equ	0FDh
Q_T		equ	0FBh
Num1_5		equ	0F7h
Num0_6		equ	0EFh
P_Y		equ	0DFh
Enter_H		equ	0BFh
Space_B		equ	7Fh

BLACK		equ	0
BLUE		equ	1
RED		equ	2
PURPLE		equ	3
GREEN		equ	4
CYAN		equ	5
YELLOW		equ	6
WHITE		equ	7
BLACK_BGD	equ	0
BLUE_BGD	equ	8
RED_BGD		equ	16
PURPLE_BGD	equ	24	
GREEN_BGD	equ	32	
CYAN_BGD	equ	40
YELLOW_BGD	equ	48
WHITE_BGD	equ	56
BRIGHT		equ	64
FLASH		equ	128


		include	macro.asm
		
		org	8000h
		
		di
		clear_lines 191
		border_color BLACK
			
		set_color BLACK_BGD OR GREEN, ATR_LOW_AREA, 8
		set_color BLACK_BGD OR RED, ATR_MIDDLE_AREA, 16
		; domyslnie w pamieci Hero atrybut ustawiony w set_color
		set_hero_m

;============== D A T A     I N I T ===================
	
; ------ Czyta mape i inicjalizuje obiekty ( drzwi i uktyte przejscia ) ------
		ld	ix,doors
		ld	iy,passages
		ld	hl,MAP
		ld	de,0				; offset obiektow
		ld	bc,MAP_HEIGHT * MAP_WIDTH	; licznik
next_mapchar:
		ld	a,(hl)
		cp	C_DOOR
		jr	z,init_door_cls
		cp	O_DOOR
		jr	z,init_door_opn
		cp	PASSAGE_CHAR
		jr	nz,inc_counters
		; --- ukryte przejscia ----
		ld	(iy),e
		ld	(iy+1),d
		inc	iy
		inc	iy
		ld	(hl),WALL_CHAR
		jr	inc_counters
		; ---	drzwi   --- 
		; 0 - map ofs lsb, 1 - msb, 2 - open(0), close(1)
init_door_cls:	ld	(ix+2),1	
		jr	init_offset
init_door_opn:	ld	(ix+2),0
init_offset:	ld	(ix),e				; offset obiektu lsb
		ld	(ix+1),d			; msb
		inc	ix			
		inc	ix
		inc	ix
		; -----------------
inc_counters:	inc	hl
		inc	de
		dec	bc	
		ld	a,b
		or	c
		jr	nz,next_mapchar
		; Hero kolor ---------
		ld	a,PURPLE OR BRIGHT
		ld	(hero_a),a
; Na podstawie Y,X oblicza offset hero wzgledem poczatku MAP'y
		ld	a,(hero_y)
		ld	c,a
		ld	a,(map_width)
		ld	b,a
		call	mul8
		ld	a,(hero_x)
		ld	d,0
		ld	e,a
		add	hl,de	
		ld	(hero_o),hl

; Dodaje do Y i X Hero przesuniecie MAP'y
		ld	de,(map_position)
		ld	hl,(hero_yx)
		add	hl,de
		ld	(hero_yx),hl 

; Oblicza granice widzialnosci Tiles
		ld	ix,borders
		; Y min
		ld	a,(map_position)	
		ld	(ix),a
		; Y max
		ld	hl,map_height
		add	a,(hl)
		ld	(ix+1),a
		; X min
		ld	a,(map_position + 1)
		ld	(ix+2),a
		; X max 
		inc	hl			; map_width
		add	a,(hl)
		ld	(ix+3),a

; Oblicza i wypelnia tabele neighbor_offs
		ld	ix,neighbor_offs
		ld	a,(map_width)
		ld	(ix+2),a
		neg
		ld	(ix),a
		
; Oblicza i wypelnia tabele fov_offsets
; W zaleznosci od kierunku patrzenia kazde tile w polu widzenia
; dostanie swoj offset wzgledem Hero
		call	calc_fov	

; ===============  M A I N    L O O P =================
 

		hide_cursor
		jp	begin

refresh:	hide_cursor
		; ------------------------------------------- ; Powidok po fov poprzedniego ruchu na ekran
		; -------------------------------------------
		clear_lines 64
		call	prev_fov

		; -----------------------
		; Pole widzenia na ekran
		; -----------------------
begin:		call	field_of_view		; fov.z80
		
		; --------------	
		; Hero na ekran	
		; --------------
		ld	hl,hero_i	; ikona hero
		ld	a,(hero_d)	; w zaleznosci
		ld	b,0		; od kierunku
		ld	c,a		; i zwrotu
		add	hl,bc		; ^ > v <
		ld	a,(hl)
		ld	bc,(hero_yx)
		push	bc
		call	gotoyx
		call	pchar
		ld	a,(hero_a)
		pop	bc		; RESTORE Y,X
		call	setatr	

wait_release:
		call	scan_keyboard	
		or	a
		jr	nz,wait_release

		show_cursor

key_press:
		call	scan_keyboard	
asdf:		cp	0
		jp	z,key_press
		cp	1			; bit 0: I
		jp	z,ismove
		cp	2			; bit 1: L
		jr	z,trn_r
		cp	4			; bit 2: K
		jp	z,move_door
		cp	8			; bit 3: J
		jp	z,trn_l
		cp	16			; bit 4: S
		jp	z,search
		jr	key_press
; -------------------------
trn_r:
		ld	hl,hero_d
		inc	(hl)
		ld	a,(hl)
		cp	WEST+1
		jr	nz,refresh
		ld	(hl),NORTH
		jp	refresh
trn_l:
		ld	hl,hero_d
		dec	(hl)
		ld	a,(hl)
		cp	NORTH-1
		jp	nz,refresh
		ld	(hl),WEST
		jp	refresh

; otwiera lub zamyka drzwi
move_door:	call	right_before
		cp	C_DOOR
		jr	z,open_door
		cp	O_DOOR
		jr	z,close_door
		jp	key_press	; nie ma tutaj drzwi! Wypad
open_door:	ld	(hl),O_DOOR	
		jp	refresh
close_door:	ld	(hl),C_DOOR
		jp	refresh

; Sprawdza czy ruch jest mozliwy
ismove:		call	right_before
		cp	WALL_CHAR
		jp	z,key_press
		cp	C_DOOR
		jp	z,key_press
		call	move
		jp	refresh

;-------------------------------------------------
; Zmienia pozycje Hero
; IN: DE - nowa pozycja ( offset wzgl. MAP )
;-------------------------------------------------
move:
		ld	(hero_o),de	; Hero new offset
		
		ld	bc,(hero_x)
		push	bc		; SAVE Y,X
		call	gotoyx
		ld	a,FLOOR_CHAR
		call	pchar
		pop	bc		; RESTORE Y,X
		ld	a,(hero_m)
		call	setatr

		ld	hl,hero_s	; /
		ld	a,(hero_d)	; Przesuniecie kursora
		add	a,a		; do nowej pozycji
		ld	e,a		; Hero
		ld	d,00h
		add	hl,de 
		ld	a,(hero_y)
		add	a,(hl)
		ld	(hero_y),a
		inc	hl
		ld	a,(hero_x)
		add	a,(hl)
		ld	(hero_x),a	; \____________
		ret

;-----------------------------------------
; Funkja wypluwa:
; w A - char Tile bezposrednio przed Hero 
; e DE - jego OFFSET wzgl. MAP
; w HL - jego ADRESS 
;-----------------------------------------
right_before:
		ld	hl,neighbor_offs
		ld	de,(hero_d)
		ld	d,00h
		add	hl,de		; adres offset'u Tile wzgl Hero
		ld	e,(hl)
		bit	7,e
		jr	z,addit
		ld	d,0FFh
	addit:	ld	hl,(hero_o)
		add	hl,de	
		ex	de,hl		; offset Tile wzgl mapy 
		ld	hl,MAP
		add	hl,de		; ADRES TILE PRZED HERO !
		ld	a,(hl)		; a w A jego ikona (ascii)
		ret

;--------------------------------------------
; Szuka ukrytych przejsc, przedmiotow itp.
;--------------------------------------------
search:
		call 	right_before

		; ukryte przejscie ?
		push	hl			; save char przed Hero
		ld	b,OBJ_MAX
		ld	hl,passages
		call	check_offset16
		pop	hl			; restore

		ld	a,b		
		cp	0FFh			; a moze nic tu nie ma?
		jp	z,key_press	
		ld	(hl),FLOOR_CHAR		; jesli przejcie to zburz mur
		jp	refresh	

;------------------------------------------------------------------
; szuka 16-bitowego offsetu na liscie objektow 
; IN:	DE - offset do wyszukania
; 	HL - adres listy offsetow objektow ( H - msb )
; OUT:	B - jesli FFh = nie znaleziony offset
;	, w przeciwnym razie index znalezionego objektu na liscie ( od 0 )
; USED:	A, C, HL
;------------------------------------------------------------------
check_offset16:
		ld	c,b		; save licznik objektow
		ld	a,e
	cell:
		cp	(hl)
		inc	hl
		jr	nz,msb
		ld	a,d
		cp	(hl)
		jr	nz,lsb
		jr	_finded
	lsb:	ld	a,e
	msb:	inc	hl
		djnz	cell	
		ld	b,0FFh
		ret
	_finded:	
		ld	a,c		; restore
		sub	b
		ld	b,a		; index znalezionego objekty ( od 0 )
		ld	(hl),0		; zeruje ten ofset na liscie
		dec	hl		; nieodkrytych przejsc
		ld	(hl),0
		ret	
		
;------------------------	
; Wyjscie
;------------------------
_halt:
		clear_screen
exit:		ret
;--------------------------

		include screen.asm
		include	fov.asm
		include 3d.asm
		include math.asm 
		include keyboard.asm

;=========     D A T A     =========

;------ map -----------
map_height:	db	12
map_width:	db	32	
;---- windows ---------
map_position:	db	 0,0			; wzgl lew-gorn rogu terminala	
w3d_position:	db	4,16			; X, Y 
; -------------------------------------
borders:	ds	4			; Ymin, Ymax, Xmin, Xmax 
;------ hero ----------
hero_yx:
hero_x:		db	2
hero_y:		db	2	
hero_d:		db	1			; zwrot : 0 - N, 1 - E itd
hero_o:		ds	2			; 16-bit offset wzgl .MAP
hero_i		db	'^','>','v','<'		; ikony Hero
hero_a		db	0			; kolory ( atrybut )
hero_m		db	0			; pamiec atrybutu
hero_s		db	-1,0, 0,1, 1,0, 0,-1	; przesuniecie wspolrzednych
neighbor_offs:	db	0,1,0,-1
;------ doors ---------
doors:		ds	OBJ_MAX * 3		; max 32 doors: ofs lsb, msb, flag (op / cl)
passages:	ds	OBJ_MAX * 2		; max 32 passages: ofs lsb, msb
door_before:	db	0			; numer drzwi na ktore patrzy Hero

		include map.asm
		end	8000h
