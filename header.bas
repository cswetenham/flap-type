// Header for nesasm
// Setup the banks
asm
	.inesprg 1 ; One PRG bank
	.ineschr 1 ; One CHR bank
	.inesmir 0 ; Mirroring type 0 (horizontal)
	.inesmap 0 ; Memory mapper 0 (none)
	.org $8000
	.bank 0
endasm
