; ----------------
;  Basic Loader
; ----------------
		org	PRINTER_BUF
BasicStart:
    db 0, 10            ; Numer linii
    dw _b_end - _b_line   ; Dlugosc linii
_b_line:
    db $FD              ; CLEAR
    ; "00000" jako tekst, potem $0E i 5 bajtow (format Sinclaira dla 32767)
    db "00000", $0E, 0, 0, $FF, $7F, 0 
    db ":"
    db $EF, $22, $22, $AF ; LOAD "" CODE
    db ":"
    db $F9, $C0         ; RANDOMIZE USR
    ; "32768" jako tekst, potem $0E i 5 bajtow (format Sinclaira dla 32768)
    db "00000", $0E, 0, 0, low CodeStart, high CodeStart, 0
    db $0D              ; Enter
_b_end:

    ; pierwszy blok (BASIC) na tasme
    SAVETAP "dng.tap", BASIC, "Loader", BasicStart, _b_end - BasicStart, 10
