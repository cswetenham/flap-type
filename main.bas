// The program starts here on NES boot (see footer)

start:
  gosub vsync
  set $2000 %00000000
  set $2001 %00011100 //sprites and bg visible, no sprite clipping
  gosub init_vars
  gosub vsync
  gosub load_palette
  goto main_loop

// The main program loop
// TODO is this really a sensible order?
main_loop:
  gosub sample_input
  gosub update
  gosub vsync
  gosub render
  goto main_loop

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

// Routine to draw sprites
render:
  // 107 if unpressed, 109 if pressed 
  set spritenum + 107 << a_held 1 
  
  set $2003 4 // Location for sprite 1 (4 bytes per attrib entry)
  set $2004 spritey // Y
  set $2004 spritenum // Tile number
  set $2004 0 // Attrib
  set $2004 spritex // X
  // Now at loc for sprite 1
  set $2004 spritey // Y
  set $2004 + spritenum 1 // Tile number
  set $2004 0 // Attrib
  set $2004 + spritex 8 // X
  return

// Sample input and store
sample_input:
  gosub sample_pad_1
  // Handle A button
  set a_pressed 0
  if pad1a = 0 set a_held 0
  if pad1a = 1 if a_held = 0 then
    set a_pressed 1
    set a_held 1
  endif
  // Handle B button
  set b_pressed 0
  if pad1b = 0 set b_held 0
  if pad1b = 1 if b_held = 0 then
    set b_pressed 1
    set b_held 1
  endif
  return

// Handle press and release of A/B buttons
update:
  // Physics!!
  // Apply gravity every 8th frame 
  if & frame_count 7 = 0 then
    // Extra case because negative numbers
    if speed_y < 8   set speed_y + speed_y 1
    if speed_y > 127 set speed_y + speed_y 1
  endif
  // Apply flap
  if a_pressed = 1 set speed_y 252 // -4
  if b_pressed = 1 set speed_y 252 // -4
  // Apply current speed 
  set spritey + spritey speed_y
  // This time unsigned nums are in our favour
  // If out of bounds, restart 
  if spritey > 240 goto start
  // Update frame count
  set frame_count + frame_count 1
  return

// Load the palette
load_palette:
  //set the PPU start address (background color 0)
  set $2006 $3f
  set $2006 0
  set $2007 $0e // Set base color black
  // Set the PPU start address (foreground color 1)
  set $2006 $3f
  set $2006 $11
  set $2007 $10 // Set fg color 1 light grey
  set $2007 $11 // Set fg color 2 sexy blue
  set $2007 $0C // Set fg color 3 dark grey
  return

