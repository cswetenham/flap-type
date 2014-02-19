//the program starts here on NES boot (see footer)
start:
	gosub vwait
	set $2000 %00000000
	set $2001 %00011100 //sprites and bg visible, no sprite clipping
	gosub init_vars
	gosub vwait
	gosub load_palette
//the main program loop
mainloop:
	gosub joy_handler
	gosub vwait
	gosub drawstuff
	goto mainloop

//set default sprite location
init_vars:
	set a_pressed 0
	set b_pressed 0
	set a_inc 0
	set b_inc 0
	set spritenum 91
	set spritex 128
	set spritey 120
	return

// Routine to draw a sprite
drawstuff:
	set $2003 0 // Sprite memory loc 0
	set $2004 spritey // Y
	set $2004 spritenum // Tile number
	set $2004 0 // Attrib
	set $2004 spritex // X

	set $2004 spritey // Y
	set $2004 + spritenum 1 // Tile number
	set $2004 0 // Attrib
	set $2004 + spritex 8 // X
	return

//move sprite based on joystick input
joy_handler:
	gosub joystick1
	gosub incrementer
	set spritex + spritex joy1right
	set spritex - spritex joy1left
	set spritey + spritey joy1down
	set spritey - spritey joy1up
	// set spritenum + spritenum a_inc
	// set spritenum - spritenum b_inc
  // 91 if unpressed, 93 if pressed 
  set spritenum + 91 << a_pressed 1 
	if joy1start = 1 then
		set spritex 128
		set spritey 120
  endif
	return

//handle press and release of A/B buttons
incrementer:
	//handle A button
	set a_inc 0
	if joy1a = 0 set a_pressed 0
	if joy1a = 1 if a_pressed = 0 then
		set a_pressed 1
		if spritenum < 92 set a_inc 1
	endif
	//handle B button
	set b_inc 0
	if joy1b = 0 set b_pressed 0
	if joy1b = 1 if b_pressed = 0 then
		set b_pressed 1
		if spritenum > 65 set b_inc 1
	endif
	return

//load the colors
load_palette:
	//set the PPU start address (background color 0)
	set $2006 $3f
	set $2006 0
	set $2007 $0e //set base color black
	//set the PPU start address (foreground color 1)
	set $2006 $3f
	set $2006 $11
	set $2007 $30 //set fg color 1 white
	return	

