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
  set a_held 0
  set b_held 0
  set spritenum 107
  set spritex 16
  set spritey 120
  set speed_y 0
  set frame_count 0
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
  // set spritex + spritex joy1right
  // set spritex - spritex joy1left
  // set spritey + spritey joy1down
  // set spritey - spritey joy1up
  set spritey + spritey speed_y
  // 107 if unpressed, 109 if pressed 
  set spritenum + 107 << a_held 1 
  if joy1start = 1 then
    set spritex 128
    set spritey 120
  endif
  return

// Handle press and release of A/B buttons
incrementer:
  // Handle A button
  set a_pressed 0
  if joy1a = 0 set a_held 0
  if joy1a = 1 if a_held = 0 then
    set a_pressed 1
    set a_held 1
  endif
  // Handle B button
  set b_pressed 0
  if joy1b = 0 set b_held 0
  if joy1b = 1 if b_held = 0 then
    set b_pressed 1
    set b_held 1
  endif
  // Physics!!
  if & frame_count 7 = 0 then
    // Extra case because negative numbers
    if speed_y < 8   set speed_y + speed_y 1
    if speed_y > 127 set speed_y + speed_y 1
  endif
  if a_pressed = 1 set speed_y 252 // -4
  if b_pressed = 1 set speed_y 252 // -4
  set frame_count + frame_count 1
  return

//load the colors
load_palette:
  //set the PPU start address (background color 0)
  set $2006 $3f
  set $2006 0
  set $2007 $0e // Set base color black
  //set the PPU start address (foreground color 1)
  set $2006 $3f
  set $2006 $11
  set $2007 $10 // Set fg color 1 light grey
  set $2007 $11 // Set fg color 2 sexy blue
  set $2007 $0C // Set fg color 3 dark grey
  return

