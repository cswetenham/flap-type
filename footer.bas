// File footer
asm
; Jump table points to NMI, Reset, and IRQ start points
	.bank 1
	.org $fffa
	.dw start, start, start
; Include CHR ROM
	.bank 2
	.org $0000
	.incbin "ascii.chr"
	.incbin "ascii.chr"
endasm
