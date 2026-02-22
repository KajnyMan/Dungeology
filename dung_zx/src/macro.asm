
clear_lines	MACRO	_lines
		LOCAL	clear_block
		ld	de,0000h		
		ld	hl,0000h
		add	hl,sp			; save SP
		ld	sp,SCREEN_ATR		; powyzej ekranu
		ld	b,_lines		; 192 = 6144 / ( 16 x 2 )
		clear_block:
	REPT	16				; zeruje 32 bajty na obrot
		push	de	
	ENDM
		djnz	clear_block	
		ld	sp,hl			; restore SP
		ENDM

hide_cursor	MACRO

		ENDM

show_cursor	MACRO

		ENDM

