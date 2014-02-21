// Update control pad 1 button status
sample_pad_1:
	set $4016 1 // First strobe byte
	set $4016 0 // Second strobe byte
	set pad1a		& [$4016] 1
	set pad1b		& [$4016] 1
	set pad1select	& [$4016] 1
	set pad1start	& [$4016] 1
	set pad1up		& [$4016] 1
	set pad1down	& [$4016] 1
	set pad1left	& [$4016] 1
	set pad1right	& [$4016] 1
	return

// Wait until screen refresh
vsync:
	asm
		lda $2002
		bpl vsync ; Wait for start of retrace
	vsync_end:
		lda $2002
		bmi vsync_end ; Wait for end of retrace
	endasm
	// Reset scroll and PPU base address
	set $2005 0
	set $2005 0
	set $2006 0
	set $2006 0
	return
