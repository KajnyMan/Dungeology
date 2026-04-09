;-------------------------------------------;
; 	D U N G E O L O G Y - zx spectrum
;-------------------------------------------;

	DEVICE	ZXSPECTRUM48
	EMPTYTAP "dng.tap"

; rozmieszczenie elementow ekranu ( od tego liczona jest reszta )
FOV_Y			equ 2
FOV_X			equ 11
MSG_Y			equ	13
MSG_X			equ	7
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
C_DOOR3D_ATR	equ	BLACK_BGD OR RED
O_DOOR3D_ATR	equ	BLACK_BGD OR RED
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
MSG_WIDTH		equ 17
MSG_HEIGHT		equ 2
WALL_CHAR		equ	'#'
PREV_WALL		equ	'.'
FLOOR_CHAR		equ	' '
C_DOOR_CHAR		equ	'+'
O_DOOR_CHAR		equ	'/'
KEY_CHAR		equ	'~'
PASSAGE_CHAR	equ	'='
STRING_DELIM	equ	'$'
TILE_EOL		equ $FF
DELIM			equ	0FFh
OBJ_MAX			equ	16
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
SCR2			equ	$4800
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
PRINTER_BUF		equ $5B00
FONTS_MSB		equ $3D
SCR1_MSB		equ $40
SCR2_MSB		equ $48
SCR3_MSB		equ $50
ATR_MSB			equ	$58
ATR1_MSB		equ	$58
ATR2_MSB		equ	$59
ATR3_MSB		equ	$5A
	; adresy ruchome
;FOV_ADR			equ	$4021
FOV_ADR			equ	SCREEN + ( FOV_Y * $20 ) + FOV_X
W3D_ADR			equ	SCR3 + ( ( W3D_Y - $10 )  * $20 ) + W3D_X	
MSG_ADR			equ	SCR2 + ( ( MSG_Y - $08 ) * $20 ) + MSG_X 
ATR3_BUF		equ	$F000
ATR3_BUF_MSB	equ	$F0
;ATR_BUF_TOP		equ	$F100
TILES			equ	$8000
TILES_MSB		equ $80
GAME_START		equ	$8400

		
		include	struct.def
		include	macro.asm

; ----------------
;  Basic Loader
; ----------------
		org	PRINTER_BUF
BasicStart:
    db 0, 10            ; Numer linii
    dw b_end - b_line   ; Dlugosc linii
b_line:
    db $FD              ; CLEAR
    ; Trik: "32767" jako tekst, potem $0E i 5 bajtow (format Sinclaira dla 32767)
    db "00000", $0E, 0, 0, $FF, $7F, 0 
    db ":"
    db $EF, $22, $22, $AF ; LOAD "" CODE
    db ":"
    db $F9, $C0         ; RANDOMIZE USR
    ; "32768" jako tekst, potem $0E i 5 bajtow (format Sinclaira dla 32768)
    db "00000", $0E, 0, 0, low CodeStart, high CodeStart, 0
    db $0D              ; Enter
b_end:

    ; pierwszy blok (BASIC) na tasme
    SAVETAP "dng.tap", BASIC, "Loader", BasicStart, b_end - BasicStart, 10
; -----------------
; Kafelki
; -----------------
		org	TILES
Start:
		include tiles.asm

; ================
;  Start Programu
; ================
CodeStart:
;		org	GAME_START
		di
		
;============== D A T A     I N I T ===================
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
		
; ------ Czyta mape i inicjalizuje obiekty ( drzwi i uktyte przejscia ) ------
		ld	ix,doors
		ld	iy,passages
		ld	hl,map
		ld	de,0				; offset obiektow
		ld	bc,MAP_HEIGHT * MAP_WIDTH	; licznik
next_mapchar:
		ld	a,(hl)
		cp	C_DOOR_CHAR	
		jr	z,init_door
		cp	O_DOOR_CHAR	
		jr	z,init_door
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
init_door:
		ld	(ix),e				; offset obiektu lsb
		ld	(ix+1),d			; msb
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

; Na podstawie Y,X oblicza offset hero wzgledem poczatku map'y
		ld	a,(hero.mapY)
		ld	c,a
		ld	a,(map_width)
		ld	b,a
		call	mul8
		ld	a,(hero.mapX)
		ld	d,0
		ld	e,a
		add	hl,de	
		ld	(hero.offset),hl


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

		jp	begin

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
		jr	z,print_door_nr
		cp	O_DOOR_CHAR	
		jr	z,print_door_nr
		jp	key_press			; nie ma tutaj drzwi! Wypad
print_door_nr:
		push	hl				; save adresu drzwi
		call	room_label
		PRINT_STR	MSG_LINE1 + $A, msg_door
		pop		hl				; restore
		ld	a,(hl)
		cp	O_DOOR_CHAR	
		jr	z,close_door
		
open_door:
		call	check_key
		jr	z,no_key
		ld	(hl),O_DOOR_CHAR		
		jp	refresh
no_key:
		PRINT_STR	MSG_LINE2 + $A, msg_nokey
		jp	wait_release	
close_door:	ld	(hl),C_DOOR_CHAR		
		call	remove_key
		jp	refresh

; ---------------------------------------------------------------
; Jesli bylo powiadomienie w poprzednim ruchu - trzeba wyczyscic
; ---------------------------------------------------------------
message_area_clear:
		ld	a,(message_flag)
		or	a
		ret	z	

		ld	hl,MSG_ADR				; blok lewy
		ld	b,2
		call	clear_txtlines

		ld	hl,MSG_ADR + 8			; prawy
		ld	b,2
		call	clear_txtlines

		xor	a
		ld	(message_flag),a
		ret
		
; Sprawdza czy ruch jest mozliwy
ismove:	
		call	right_before
		cp	WALL_CHAR
		jp	z,key_press
		cp	C_DOOR_CHAR		
		jp	z,key_press
		call	move
		call	message_area_clear
		jp	refresh

;-------------------------------------------------
; Zmienia pozycje Hero
; IN: DE - nowa pozycja ( offset wzgl. map )
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
; e DE - jego OFFSET wzgl. map
; w HL - jego ADRESS 
;-----------------------------------------
right_before:
		ld	hl,neighbor_offs
		ld	de,(hero.direction)
		ld	d,00h
		add	hl,de		; adres offset'u Tile wzgl Hero
		ld	e,(hl)
		bit	7,e
		jr	z,addit
		ld	d,0FFh
addit:	ld	hl,(hero.offset)
		add	hl,de	
		ex	de,hl		; offset Tile wzgl mapy 
		ld	hl,map
		add	hl,de		; ADRES TILE PRZED HERO !
		ld	a,(hl)		; a w A jego ikona (ascii)
		ret

;--------------------------------------------
; Szuka ukrytych przejsc itp.
;--------------------------------------------
search:
		PRINT_STR	MSG_LINE1 + $9, msg_searching
		call 	right_before

		push	hl					; save adres char przed Hero

		; ukryte przejscie ?
		ld	b,OBJ_MAX
		ld	hl,passages
		call	check_offset16		; w HL msb offsety znalezionego objektu

		pop		de					; restore

		cp	0FFh					; a moze nic tu nie ma?
		jp	z,nothing_here	

		ld	a,FLOOR_CHAR
		ld	(de),a					; jesli przejcie to zburz mur
		ld	(hl),0					; Zeruje ten offset na liscie
		dec	hl						; nieodkrytych
		ld	(hl),0					; przejsc
		PRINT_STR	MSG_LINE2 + $8, msg_psgfinded
		jp	refresh	

nothing_here:
		PRINT_STR	MSG_LINE2 + $8, msg_nothing
		jp	key_press

; -----------------------------------------
; Ustawia bit flagi przypisany do nr drzwi 
; OUT:	A - ustawiony odpowiedni bit flagi 
;		C - bajt flagi kluczy
;		DE - adres bajtu flagi kluczy
; -----------------------------------------
door_keybit:
		ld	a,(door_nr)
		ld	b,a					; save nr
		ld	de,bag.keys
		cp	8
		jr	c, low_flags
		;high flags
		inc	de
		sub	8
low_flags:
		ld	a,(de)					; hl zajete wyzej
		ld	c,a
		ld	a,%00000001
roll_right:
		rrca
		djnz	roll_right
		ret

; --------------------------------------
; Sprawdza czy jest klucz do tych drzwi
; OUT:	A = 0 nie ma klucza, A != 0 jest 
; --------------------------------------
check_key:
		call	door_keybit
		and	c
		ret

; ----------------------------------------------------
; Wyjmuje klucz z otwartych drzwi i laduje do plecaka 
; ----------------------------------------------------
remove_key:
		call	door_keybit
		or	c
		ld	(de),a
		ret

; ----------------------------------------------------
; Podnosi klucz z gleby i laduje do plecaka 
; ----------------------------------------------------
take_key:
		ld	(hl),FLOOR_CHAR
		PRINT_STR	MSG_LINE1 + $9, msg_floor
		PRINT_STR	MSG_LINE2 + $9, msg_key
		ret

; ----------------------------------------------------
; Jak cos jest pod nogami wsadza do plecaka 
; ----------------------------------------------------
take_item:
		call	search_floor
		cp	KEY_CHAR
		jr	nz,floor_empty 
		call	take_key
		jp	wait_release
		
floor_empty:
		PRINT_STR	MSG_LINE1 + $9, msg_floor
		PRINT_STR	MSG_LINE2 + $9, msg_dust
		jp wait_release	

; ----------------------------------------------------
; Sprawdza co lezy pod nogami.
; OUT:	A - char przedmiotu 
;		HL - jego adress	
; ----------------------------------------------------
search_floor:
		ld	hl,(hero.offset)
		ld	de,map
		add	hl,de
		ld	a,(hl)
		ret

;------------------------------------------------
; Przeszukuje po offsecie liste wszystkich drzwi
; i drukuje nr na drzwiach przed Hero
; IN:  DE - offset drzwi ( wzgl. map )
; USED : A, BC, HL
;------------------------------------------------
room_label:
		ld	b,OBJ_MAX
		ld	hl,doors
		call	check_offset16
		inc	a
		ld	(door_nr),a
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
		ld	a,0FFh
		ret
_finded:	
		ld	a,c		; restore
		sub	b		; index znalezionego objekty ( od 0 )
		ret	
		
;------------------------	
; Wyjscie
;------------------------
_halt:
exit:	
		ei
		ret

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
w3d_position	db	1,17	; X, Y 

; -------------------------------------
borders			ds	4		; Ymin, Ymax, Xmin, Xmax 
message_flag	db	0		; jesli 0 nie ma czyszczenia ekranu powiadomien

;------ hero ----------
hero		Player	{ 2, 2, 1, $00 }
hero_i		db	'^','>','v','<'			; ikony Hero
hero_s		db	0,-1, 1,0, 0,1, -1,0	; przesuniecie wspolrzednych

; ------- Inventory ------------------------------
bag			Inventory { %10000100, %00010000 }
neighbor_offs:	db	0,1,0,-1

;------ doors ---------
doors		ds	OBJ_MAX * 2		; max doors: ofs lsb, msb
passages	ds	OBJ_MAX * 2		; max passages: ofs lsb, msb
door_nr		db	0				; numer drzwi na ktore patrzy Hero
;==================

		include	messages.asm
		include map.asm

;==================

End:

    ; drugi blok (CODE) na tasme
    SAVETAP "dng.tap", CODE, "Dungeology", Start, End - Start
