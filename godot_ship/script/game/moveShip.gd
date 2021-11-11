extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var held = false
var originalPos # Position before moving the ship
var snapOriginalPos = false # Gets the original position
var vertical = true # Gets ship which is either vertical or horizonal
var startingPos # Starting position of ships before being placed

# Called when the node enters the scene tree for the first time.
func _ready():
	startingPos = position # Sets the position of ships when game is started to the startingPos variable
	pass

var click_radius = 16
var orient = 0;

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:	
		if (event.position - position).length() < click_radius:
			if not held and event.pressed:
				AudioBus.emit_signal("button_clicked")
				held = true;
				
		if held and not event.pressed:
			held = false;
			# If ship is placed on board, snap to board
			if (position.x > 17.4 and position.x < 335.5) and (position.y > 20.2 and position.y < 335.5):
				position = position.snapped(Vector2(32, 32)) + Vector2(4, 4) # Position snapping on board
			else: # If not placed on board, ships are placed back at the starting position
				if originalPos != null:
					position = originalPos
					rotation = 0
					vertical = true
			
			# Lines 40-98 make sure that the ships placed on the board are not able to hang off the board
			
			# 2-Ship
			if (get_parent().get_node("2Ship").rotation_degrees == 0):
				if (get_parent().get_node("2Ship").position.y > 308):
					position = originalPos
					rotation = 0
					vertical = true
			if (get_parent().get_node("2Ship").rotation_degrees == -90):
				if (get_parent().get_node("2Ship").position.x > 308):
					position = originalPos
					rotation = 0
					vertical = true
			
			# 3-Ship A
			if (get_parent().get_node("3ShipA").rotation_degrees == 0):
				if (get_parent().get_node("3ShipA").position.y > 308) or (get_parent().get_node("3ShipA").position.y < 52):
					position = originalPos
					rotation = 0
					vertical = true
			if (get_parent().get_node("3ShipA").rotation_degrees == -90):
				if (get_parent().get_node("3ShipA").position.x > 308) or (get_parent().get_node("3ShipA").position.x < 52):
					position = originalPos
					rotation = 0
					vertical = true
			
			# 3-Ship B
			if (get_parent().get_node("3ShipB").rotation_degrees == 0):
				if (get_parent().get_node("3ShipB").position.y > 308) or (get_parent().get_node("3ShipB").position.y < 52):
					position = originalPos
					rotation = 0
					vertical = true
			if (get_parent().get_node("3ShipB").rotation_degrees == -90):
				if (get_parent().get_node("3ShipB").position.x > 308) or (get_parent().get_node("3ShipB").position.x < 52):
					position = originalPos
					rotation = 0
					vertical = true
					
			# 4-Ship
			if (get_parent().get_node("4Ship").rotation_degrees == 0):
				if (get_parent().get_node("4Ship").position.y > 276.8) or (get_parent().get_node("4Ship").position.y < 52):
					position = originalPos
					rotation = 0
					vertical = true
			if (get_parent().get_node("4Ship").rotation_degrees == -90):
				if (get_parent().get_node("4Ship").position.x > 276.8) or (get_parent().get_node("4Ship").position.x < 52):
					position = originalPos
					rotation = 0
					vertical = true
					
			# 5-Ship
			if (get_parent().get_node("5Ship").rotation_degrees == 0):
				if (get_parent().get_node("5Ship").position.y > 276.8) or (get_parent().get_node("5Ship").position.y < 84.8):
					position = originalPos
					rotation = 0
					vertical = true
			if (get_parent().get_node("5Ship").rotation_degrees == -90):
				if (get_parent().get_node("5Ship").position.x > 276.8) or (get_parent().get_node("5Ship").position.x < 84.8):
					position = originalPos
					rotation = 0
					vertical = true
					
			
	if event is InputEventMouseMotion and held:
		if snapOriginalPos == false:
			originalPos = position
			snapOriginalPos = true
		position = event.position;
		
	if event.is_action_pressed("ui_rotate"):
		if held:
			return
		if checkOriginalPos():
			return
		else:
			AudioBus.emit_signal("button_clicked")			
			if originalPos == null:
				if position == originalPos:
					return
			elif(event.position - position).length() < click_radius:
				if vertical == true:
					rotate(-PI/2)
					vertical = false
				else:
					rotate(PI/2)
					vertical = true
		
		# Lines  126-196 move the ship back accordingly after being rotated to make sure that the ships do not hang off the board
		if(position.x > 17.4 and position.x < 335.5) and (position.y > 20.2 and position.y < 335.5):
			# 2-Ship
			if (get_parent().get_node("2Ship").rotation_degrees == 0):
				if (get_parent().get_node("2Ship").position.y > 308):
					get_parent().get_node("2Ship").position.y -= 32
			if (get_parent().get_node("2Ship").rotation_degrees == -90):
				if (get_parent().get_node("2Ship").position.x > 308):
					get_parent().get_node("2Ship").position.x -= 32
		
			# 3-Ship A
			if (get_parent().get_node("3ShipA").rotation_degrees == 0):
				if (get_parent().get_node("3ShipA").position.y > 308):
					get_parent().get_node("3ShipA").position.y -= 32
				if (get_parent().get_node("3ShipA").position.y < 52):
					get_parent().get_node("3ShipA").position.y += 32
			if (get_parent().get_node("3ShipA").rotation_degrees == -90):
				if (get_parent().get_node("3ShipA").position.x > 308):
					get_parent().get_node("3ShipA").position.x -= 32
				if (get_parent().get_node("3ShipA").position.x < 52):
					get_parent().get_node("3ShipA").position.x += 32
			
			# 3-Ship B
			if (get_parent().get_node("3ShipB").rotation_degrees == 0):
				if (get_parent().get_node("3ShipB").position.y > 308):
					get_parent().get_node("3ShipB").position.y -= 32
				if (get_parent().get_node("3ShipB").position.y < 52):
					get_parent().get_node("3ShipB").position.y += 32
			if (get_parent().get_node("3ShipB").rotation_degrees == -90):
				if (get_parent().get_node("3ShipB").position.x > 308):
					get_parent().get_node("3ShipB").position.x -= 32
				if (get_parent().get_node("3ShipB").position.x < 52):
					get_parent().get_node("3ShipB").position.x += 32
					
			# 4-Ship
			if (get_parent().get_node("4Ship").rotation_degrees == 0):
				if (get_parent().get_node("4Ship").position.y > 308.8):
					get_parent().get_node("4Ship").position.y -= 64;
				elif (get_parent().get_node("4Ship").position.y > 276.8):
					get_parent().get_node("4Ship").position.y -= 32;
				if (get_parent().get_node("4Ship").position.y < 52):
					get_parent().get_node("4Ship").position.y += 32
			if (get_parent().get_node("4Ship").rotation_degrees == -90):
				if (get_parent().get_node("4Ship").position.x > 308.8):
					get_parent().get_node("4Ship").position.x -= 64
				elif (get_parent().get_node("4Ship").position.x > 276.8):
					get_parent().get_node("4Ship").position.x -= 32
				if (get_parent().get_node("4Ship").position.x < 52):
					get_parent().get_node("4Ship").position.x += 32
					
			# 5-Ship
			if (get_parent().get_node("5Ship").rotation_degrees == 0):
				if (get_parent().get_node("5Ship").position.y > 308.8):
					get_parent().get_node("5Ship").position.y -= 64
				elif (get_parent().get_node("5Ship").position.y > 276.8):
					get_parent().get_node("5Ship").position.y -= 32
				
				if (get_parent().get_node("5Ship").position.y < 52):
					get_parent().get_node("5Ship").position.y += 64
				elif (get_parent().get_node("5Ship").position.y < 84.8):
					get_parent().get_node("5Ship").position.y += 32
					
			if (get_parent().get_node("5Ship").rotation_degrees == -90):
				if (get_parent().get_node("5Ship").position.x > 308.8):
					get_parent().get_node("5Ship").position.x -= 64
				elif (get_parent().get_node("5Ship").position.x > 276.8):
					get_parent().get_node("5Ship").position.x -= 32
					
				if (get_parent().get_node("5Ship").position.x < 52):
					get_parent().get_node("5Ship").position.x += 64
				elif (get_parent().get_node("5Ship").position.x < 84.8):
					get_parent().get_node("5Ship").position.x += 32
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func pickup():
	if held:
		return
	mode = RigidBody2D.MODE_STATIC
	held = true

func drop(impulse=Vector2.ZERO):
	if held:
		mode = RigidBody2D.MODE_RIGID
		apply_central_impulse(impulse)
		held = false
		snapOriginalPos = false
		
func checkOriginalPos(): # Checks whether the position of the ship is the stating position of the ship
	if position == startingPos:
		return true
	else:
		return false
