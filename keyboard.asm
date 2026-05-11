scan_keyboard:	

		ld	a,Enter_H
		in	a,(0FEh)
		cpl
		and	%00001110			; jkl
		ret	nz
			
		ld	a,P_Y
		in	a,(0FEh)
		ld	b,a
		cpl
		and	%00000100			; i
		jr	nz,_set_bit0

		ld	a,b
		cpl
		and	%00000001			; p
		jr	nz,_set_bit7

		ld	a,A_G
		in	a,(0FEh)
		cpl
		and	%00000010			; s
		jr	nz,_set_bit4

		ld	a,Q_T
		in	a,(0FEh)
		ld	b,a
		cpl
		and	%00010000			; t
		jr	nz,_set_bit5

		ld	a,CS_V
		in	a,(0FEh)
		cpl
		and	%00001000			; c
		jr	nz,_set_bit6

		ret

_set_bit0:
		ld	a,1
		ret
_set_bit4:
		ld	a,16
		ret
_set_bit5:
		ld	a,32
		ret
_set_bit6:
		ld	a,64
		ret
_set_bit7:
		ld	a,128
		ret
