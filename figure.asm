talk_figure:
		call	message_area_clear
		call	right_before
		cp	FIGURE_CHAR
		jr	nz, _nobody
		ld	a,(hero.stat.str)
		cp	11
		jr	c,_insf
		ld	a,(hero.stat.def)
		cp	9
		jr	c,_insf	
		push	hl	
		PRINT_STR	MSG_LINE1 + 2, talk_ready	
		PRINT_STR	MSG_LINE2 + 1, talk_nxt_lvl	
		pop		hl
		ld	(hl),FLOOR_CHAR
		jp	refresh
_insf		
		PRINT_STR	MSG_LINE1 + 1, talk_insf_str	
		PRINT_STR	MSG_LINE2 + 2, talk_insf_def	
		jp	wait_release
_nobody
		PRINT_STR	MSG_LINE1 + 3, talk_nobody	
		jp	wait_release

talk_nobody		db	"Nobody here...$"
talk_insf_str	db	"Need Hand Trowel.$"
talk_insf_def	db	"& Leather Gloves.$"
talk_ready		db	"You are Ready!$"
talk_nxt_lvl	db	"Next level ahead!$"
