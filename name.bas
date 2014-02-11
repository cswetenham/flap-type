//header for nesasm
asm
	.inesprg 1 ;//one PRG bank
	.ineschr 1 ;//one CHR bank
	.inesmir 0 ;//mirroring type 0
	.inesmap 0 ;//memory mapper 0 (none)
	.org 32768
	.bank 0
endasm

//the program starts here on NES boot (see footer)
goto start
myname:
	data "YOUR NAME HERE",0

start:
	gosub vwait
	set 8192 %00000000
	set 8193 %00011100 //sprites and bg visible, no sprite clipping
	gosub vwait
	gosub load_palette
	gosub vwait
	gosub load_name
//the main program loop
mainloop:
	gosub vwait
	goto mainloop

//load the colors
load_palette:
	//set the PPU start address (background color 0)
	set 8198 $3f
	set 8198 0
	set 8199 $0e //set base color black
	set 8199 $30
	//set the PPU start address (foreground color 1)
	set 8198 $3f
	set 8198 $11
	set 8199 $30 //set fg color 1 white
	return	

//write your name into the background
load_name:
	set 8198 $21
	set 8198 3
	set x 0		
	load_name_1:
		set 8199 [myname x]
		inc x
		set a [myname x]
		if a <> 0 branchto load_name_1
	return

//wait until screen refresh
vwait:
	asm
		lda $2002
		bpl vwait ;//wait for start of retrace
	vwait_1:
		lda $2002
		bmi vwait_1 ;//wait for end of retrace
	endasm
	//set scroll and PPU base address
	set 8197 0
	set 8197 0
	set 8198 0
	set 8198 0
	return

//file footer
asm
;//jump table points to NMI, Reset, and IRQ start points
	.bank 1
	.org $fffa
	.dw start, start, start
;//include CHR ROM
	.bank 2
	.org $0000
	.incbin "ascii.chr"
	.incbin "ascii.chr"
endasm
