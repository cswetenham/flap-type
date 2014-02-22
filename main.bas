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
  set player_sprite_idx 107
  set enemy_sprite_idx 96
  set player_x 16
  set player_y 120
  set player_dy 0
  set enemy_x 240
  set enemy_y 120
  set enemy_dx 255 // -1
  set enemy_dy 0
  set frame_count 0
  return

// Routine to draw sprites
render:
  // Select flapping or non-flapping sprite
  set player_sprite_idx + 107 << a_held 1 
  // Skip sprite 0 - it's special and we might use it for scrolling later 
  set $2003 4 // Location for sprite 1 (4 bytes per attrib entry)
  // Every time we write to $2004 the address is incremented by 1 byte 
  // Render both player tiles
  set $2004 player_y // Y - actually Y-1, but impossible to render in 1st line
  set $2004 player_sprite_idx // Tile number
  set $2004 0 // Attrib
  set $2004 player_x // X
  
  set $2004 player_y // Y
  set $2004 + player_sprite_idx 1 // Tile number
  set $2004 0 // Attrib
  set $2004 + player_x 8 // X

  // Render 4 tiles for enemy sprite
  set $2004 enemy_y // Y
  set $2004 enemy_sprite_idx // Tile number
  set $2004 0 // Attrib
  set $2004 enemy_x // X
  
  set $2004 enemy_y // Y
  set $2004 + enemy_sprite_idx 1 // Tile number
  set $2004 0 // Attrib
  set $2004 + enemy_x 8 // X
  
  set $2004 + enemy_y 8 // Y
  set $2004 + enemy_sprite_idx 2 // Tile number
  set $2004 0 // Attrib
  set $2004 enemy_x // X
  
  set $2004 + enemy_y 8 // Y
  set $2004 + enemy_sprite_idx 3 // Tile number
  set $2004 0 // Attrib
  set $2004 + enemy_x 8 // X
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
    if player_dy < 8   set player_dy + player_dy 1
    if player_dy > 127 set player_dy + player_dy 1
  endif
  // Apply flap
  if a_pressed = 1 set player_dy 252 // -4
  if b_pressed = 1 set player_dy 252 // -4
  // Apply current speed 
  set player_y + player_y player_dy
  set enemy_x + enemy_x enemy_dx
  set enemy_y + enemy_y enemy_dy 
  // This time unsigned nums are in our favour
  // If out of bounds, restart 
  if player_y > 240 goto start

  // Okay, collision detection

  // Player box:
  // player.left = player_x
  // player.right = player_x + 15
  // player.top = player_y
  // player.bottom = player_y + 7

  // Enemy box:
  // enemy.left = enemy_x
  // enemy.right = enemy_x + 15
  // enemy.top = enemy_y
  // enemy.bottom = enemy_y + 15

  // Bounding box test: try to find a separating axis
  // if player.right < enemy.left goto no_collision
  if + player_x 15 < enemy_x goto no_collision
  // if enemy.right < player.left goto no_collision
  if + enemy_x 15 < player_x goto no_collision 
  // if player.bottom < enemy.top goto no_collision
  if + player_y 7 < enemy_y goto no_collision
  // if enemy.bottom < player.top goto no_collision
  if + enemy_y 15 < player_y goto no_collision
  // else collision
  goto start

no_collision:
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

