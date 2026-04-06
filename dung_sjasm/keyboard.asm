scan_keyboard:	

		ld	a,Enter_H
		in	a,(0FEh)
		cpl
		and	0Eh
		ret	nz
			
		ld	a,P_Y
		in	a,(0FEh)
		cpl
		and	04h
		jr	nz,set_bit0

		ld	a,A_G
		in	a,(0FEh)
		cpl
		and	02h
		jr	nz,set_bit4
		ret
set_bit0:
		ld	a,1		; 0 bit ustawiony
		ret
set_bit4:
		ld	a,16		; 4 bit ustawiony
		ret
		

scn_keyboard:	

		ld	a,Enter_H
		in	a,(0FEh)
		bit	2,a
		jr	z,sbit
		ld	a,0
		jr	ext
sbit:	ld	a,4	

ext:
		ret
;sc_keyboard:	
;		ld	bc,0BFFEh	; H - Enter
;		in	a,(c)
;		bit	1,a
;		jr	nz,is_K
;		ld	a,2
;		ret
;	is_K:			
;		bit	2,a
;		jr	nz,is_J
;		ld	a,4
;		ret
;	is_J:
;		bit	3,a
;		jr	nz,is_I
;		ld	a,8
;		ret
;	is_I:
;		ld	b,P_Y
;		in	a,(c)
;		bit	2,a
;		jr	nz,noch
;		ld	a,1
;		ret
;	noch:
;		ld	a,0	
;		ret
		
