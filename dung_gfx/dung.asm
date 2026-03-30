;-------------------------------------------;
; 	D U N G E O L O G Y - zx spectrum
;-------------------------------------------;


; rozmieszczenie elementow ekranu ( od tego liczona jest reszta )
FOV_Y			equ 2
FOV_X			equ 11
MSG_Y			equ	11
MSG_X			equ	4
W3D_Y			equ	17
W3D_X			equ	11

; atrybuty
BLACK			equ	0
BLUE			equ	1
RED				equ	2
PURPLE			equ	3
GREEN			equ	4
CYAN			equ	5
YELLOW			equ	6
WHITE			equ	7
BLACK_BGD		equ	0
BLUE_BGD		equ	8
RED_BGD			equ	16
PURPLE_BGD		equ	24	
GREEN_BGD		equ	32	
CYAN_BGD		equ	40
YELLOW_BGD		equ	48
WHITE_BGD		equ	56
BRIGHT			equ	64
FLASH			equ	128
WALL3D_ATR		equ BLACK_BGD OR BLUE OR BRIGHT
C_DOOR3D_ATR	equ	BLACK_BGD OR BLUE OR BRIGHT 
O_DOOR3D_ATR	equ	BLACK_BGD OR BLUE OR BRIGHT
SCREEN_WIDTH	equ	32

	; klawiatura
CS_V			equ	$FE
A_G				equ	$FD
Q_T				equ	$FB
Num1_5			equ	$F7
Num0_6			equ	$EF
P_Y				equ	$DF
Enter_H			equ	$BF
Space_B			equ	$7F
	; mapa i hero
MAP_HEIGHT		equ	12
MAP_WIDTH		equ	32
FOV_YX			equ	( FOV_Y * 256 ) + FOV_X 
FOV_WIDTH		equ 9
FOV_HEIGHT		equ 9
FOV_FRAME_Y		equ	FOV_Y - 1	
FOV_FRAME_X		equ	FOV_X - 1	
FOV_FRAME_YX	equ	( FOV_FRAME_Y * 256 ) + FOV_FRAME_X	
FOV_FRAME_H		equ	FOV_HEIGHT + 2		
FOV_FRAME_W		equ	FOV_WIDTH + 2		
FFY				equ	FOV_FRAME_Y
FFX				equ	FOV_FRAME_X
FFW				equ	FOV_WIDTH + 1
FFH				equ FOV_HEIGHT + 1
W3D_HEIGHT		equ	6
W3D_WIDTH		equ	9
W3D_YX			equ	( W3D_Y * 256 ) + W3D_X 
W3D_FRAME_Y		equ	W3D_Y - 1	
W3D_FRAME_X		equ	W3D_X - 1	
W3D_FRAME_YX	equ	( W3D_FRAME_Y * 256 ) + W3D_FRAME_X	
W3D_FRAME_H		equ	W3D_HEIGHT + 2		
W3D_FRAME_W		equ	W3D_WIDTH + 2		
F3Y				equ	W3D_FRAME_Y
F3X				equ	W3D_FRAME_X
F3W				equ	W3D_WIDTH + 1
F3H				equ W3D_HEIGHT + 1
MSG_YX			equ	( MSG_Y * 256 ) + MSG_X
MSG_WIDTH		equ 24
MSG_HEIGHT		equ 5
WALL_CHAR		equ	'#'
PREV_WALL		equ	'.'
FLOOR_CHAR		equ	' '
C_DOOR			equ	'+'
O_DOOR			equ	'/'
PASSAGE_CHAR	equ	'='
STRING_DELIM	equ	'$'
TILE_EOL		equ $FF
DELIM			equ	0FFh
OBJ_MAX			equ	32
HERO_Y			equ	FOV_Y + 4
HERO_X			equ FOV_X + 4 	
HERO_ATR		equ BLACK_BGD OR YELLOW
;HERO_YX			equ $0505
HERO_YX			equ ( HERO_Y * 256 ) + HERO_X 

NORTH			equ	0
EAST			equ	1
SOUTH			equ	2
WEST			equ	3

	; adresy stale
FONTS			equ	$3D00	
SCREEN			equ	$4000
SCREEN_TOP		equ	$5800
SCREEN_ATR		equ	$5800
ATR3			equ	$5A00
MSG_AREA		equ $4888	; linie 96-127
MSG_LINE1		equ	$48A0
MSG_LINE2		equ	$48C0
SCR3			equ	$5000
ATR_MAP_TOP		equ	$5980
ATR_MSG_TOP 	equ	$5A00
ATR_3D_TOP		equ	$5B00
FONTS_MSB		equ $3D
SCR1_MSB		equ $40
SCR2_MSB		equ $48
SCR3_MSB		equ $50
ATR_MSB			equ	$58
	; adresy ruchome
;FOV_ADR			equ	$4021
FOV_ADR			equ	SCREEN + ( FOV_Y * $20 ) + FOV_X
W3D_ADR			equ	SCR3 + ( ( W3D_Y - $10 )  * $20 ) + W3D_X	
ATR3_BUF		equ	$F000
ATR3_BUF_MSB	equ	$F0
ATR_BUF_TOP		equ	$F100
TILES			equ	$F800
TILES_MSB		equ $F8


		include	macro.asm
		
		org	8000h
		di
		
;============== D A T A     I N I T ===================
		clear_lines SCREEN_TOP, 191
		border_color BLACK
	
		set_color	BLACK_BGD OR BLACK, ATR_3D_TOP, 24
		call	print_frames

		; kolory okna powiadomien
		ld	a,BLACK_BGD OR YELLOW 
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

		; kolory ramki	3D 
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
	init_door_cls:
		ld	(ix+2),1	
		jr	init_offset
	init_door_opn:
		ld	(ix+2),0
	init_offset:
		ld	(ix),e				; offset obiektu lsb
		ld	(ix+1),d			; msb
		inc	ix			
		inc	ix
		inc	ix
		; -----------------
	inc_counters:
		inc	hl
		inc	de
		dec	bc	
		ld	a,b
		or	c
		jr	nz,next_mapchar

		; Hero kolor ---------
;		ld	a,BLACK_BGD OR PURPLE OR BRIGHT
;		ld	(hero_a),a
; Na podstawie Y,X oblicza offset hero wzgledem poczatku MAP'y
		ld	a,(hero_mapY)
		ld	c,a
		ld	a,(map_width)
		ld	b,a
		call	mul8
		ld	a,(hero_mapX)
		ld	d,0
		ld	e,a
		add	hl,de	
		ld	(hero_o),hl


; Oblicza granice widzialnosci Tiles
;		ld	ix,borders
;		; Y min
;		ld	a,(map_position)	
;		ld	(ix),a
;		; Y max
;		ld	hl,map_height
;		add	a,(hl)
;		ld	(ix+1),a
;		; X min
;		ld	a,(map_position + 1)
;		ld	(ix+2),a
;		; X max 
;		inc	hl			; map_width
;		add	a,(hl)
;		ld	(ix+3),a

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
		
;	Rysuje ramki okien fov i w3d
		
; ===============  M A I N    L O O P =================

;		jp	begin

refresh:
		; czyszczenie okna fov
		ld	hl,FOV_ADR	
		ld	b,FOV_HEIGHT
		call	clear_txtlines

		; czyszczenie okna 3d
		ld	hl,W3D_ADR
		ld	b,W3D_HEIGHT
		call	clear_txtlines
begin:
		; "wygaszone" okno 3D przy rysowaniu
		ld	a,BLACK_BGD OR BLUE OR BRIGHT
		ld	b,W3D_HEIGHT
		ld	c,W3D_WIDTH
		ld	de, W3D_YX
		call set_atr_block

;		set_color BLACK_BGD OR BLACK, ATR_BUF_TOP, 8

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
		
		; --------------	
		; Hero na ekran	
		; --------------
		ld	hl,hero_i		; ikona hero
		ld	a,(hero_d)		; w zaleznosci
		ld	b,0				; od kierunku
		ld	c,a				; i zwrotu
		add	hl,bc			; ^ > v <
		ld	a,(hl)
		ld	bc,HERO_YX		; stala pozycja HERO na ekranie
		push	af
		call	gotoyx
		pop		af
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
;asdf:
		cp	0
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
		call	message_area_clear
		ld	hl,hero_d
		inc	(hl)
		ld	a,(hl)
		cp	WEST+1
		jp	nz,refresh
		ld	(hl),NORTH
		jp	refresh
trn_l:
		call	message_area_clear
		ld	hl,hero_d
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
		cp	C_DOOR
		jr	z,open_door
		cp	O_DOOR
		jr	z,close_door
		jp	key_press	; nie ma tutaj drzwi! Wypad
open_door:
		ld	(hl),O_DOOR	
		jp	refresh
close_door:	ld	(hl),C_DOOR
		jp	refresh

; ---------------------------------------------------------------
; Jesli bylo powiadomienie w poprzednim ruchu - trzeba wyczyscic
; ---------------------------------------------------------------
message_area_clear:
		ld	a,(message_flag)
		or	a
		ret	z	
;		ld	de,MSG_LINE + $A
;		ld	bc,msg_clear
;		call	pstring	
		
		clear_txtline	MSG_LINE1	
		clear_txtline	MSG_LINE2	

		xor	a
		ld	(message_flag),a
		ret
		
; Sprawdza czy ruch jest mozliwy
ismove:		call	right_before
		cp	WALL_CHAR
		jp	z,key_press
		cp	C_DOOR
		jp	z,key_press
		call	move
		call	message_area_clear
		jp	refresh

;-------------------------------------------------
; Zmienia pozycje Hero
; IN: DE - nowa pozycja ( offset wzgl. MAP )
;-------------------------------------------------
move:
		ld	(hero_o),de	; Hero new offset
		ld	hl,hero_s	; /
		ld	a,(hero_d)	; Przesuniecie kursora
		add	a,a		; do nowej pozycji
		ld	e,a		; Hero
		ld	d,00h
		add	hl,de
		ld	a,(hero_mapX)
		add	a,(hl)
		ld	(hero_mapX),a
		inc	hl
		ld	a,(hero_mapY)
		add	a,(hl)
		ld	(hero_mapY),a	; \____________
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
		ld	a,1
		ld	(message_flag),a		; trzeba bedzie wyczyscic powiadomienia
		ld	de,MSG_LINE1 + $A 
		ld	bc,msg_searching
		call	pstring
		call 	right_before

		; ukryte przejscie ?
		push	hl					; save char przed Hero
		ld	b,OBJ_MAX
		ld	hl,passages
		call	check_offset16
		pop		hl					; restore

		ld	a,b		
		cp	0FFh					; a moze nic tu nie ma?
		jp	z,nothing_here	
		ld	(hl),FLOOR_CHAR			; jesli przejcie to zburz mur
		ld	de,MSG_LINE2 + $9
		ld	bc,msg_psgfinded
		call	pstring
		jp	refresh	
	nothing_here:
		ld	de,MSG_LINE2 + $6
		ld	bc,msg_nothing
		call	pstring
		jp	key_press

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
	lsb:
		ld	a,e
	msb:
		inc	hl
		djnz	cell	
		ld	b,0FFh
		ret
	_finded:	
		ld	a,c		; restore
		sub	b
		ld	b,a		; index znalezionego objekty ( od 0 )
		ld	(hl),0	; zeruje ten ofset na liscie
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
map_height	db	12
map_width	db	32	
;---- windows ---------
;map_position	db	 0,0	; wzgl lew-gorn rogu terminala	
w3d_position	db	1,17	; X, Y 
; -------------------------------------
borders			ds	4		; Ymin, Ymax, Xmin, Xmax 
message_flag	db	0		; jesli 0 nie ma czyszczenia ekranu powiadomien
;------ hero ----------
hero_mapYX
hero_mapX	db	2
hero_mapY	db	2	
hero_d		db	1						; zwrot : 0 - N, 1 - E itd
hero_o		ds	2						; 16-bit offset wzgl .MAP
hero_i		db	'^','>','v','<'			; ikony Hero
hero_a		db	0						; kolory ( atrybut )
;hero_m		db	0						; pamiec atrybutu
;hero_s		db	-1,0, 0,1, 1,0, 0,-1	; przesuniecie wspolrzednych
hero_s		db	0,-1, 1,0, 0,1, -1,0	; przesuniecie wspolrzednych
neighbor_offs:	db	0,1,0,-1
;------ doors ---------
doors		ds	OBJ_MAX * 3		; max 32 doors: ofs lsb, msb, flag (op / cl)
passages	ds	OBJ_MAX * 2		; max 32 passages: ofs lsb, msb
door_before	db	0				; numer drzwi na ktore patrzy Hero
;- tabela adresow poczatkow lini 'tekstowych' -----

		include	messages.asm
		include map.asm

		org	TILES
		include tiles.asm


		end	8000h
