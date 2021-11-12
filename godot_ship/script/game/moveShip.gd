extends RigidBody2D


var held = false
var originalPos # Position before moving the ship
var snapOriginalPos = false # Gets the original position
var mousePos
var vertical = true # Gets ship which is either vertical or horizonal
var startingPos # Starting position of ships before being placed

# Ships are all named starting with their length,
# So we cast from string to int, on the ship name, and get the length
onready var ship_length = int(name)

# This is set when we're colliding with something
var collision = false

# Called when the node enters the scene tree for the first time.
func _ready():
	mode = MODE_KINEMATIC
	# Snap the ships to the grid, so the engine won't get mad when they're moved away from the starting position every frame
	position = (position - offset).snapped(Vector2(32, 32)) + offset
	startingPos = position
	var _trash
	# Connect to my own signals, and not the signals of my fellowships
	# PLEASE don't parameterize; there's no way to tell these signals apart with the args the engine provides.
	_trash = connect("body_entered", self, "ship_stacked")
	_trash = connect("body_exited",  self, "ship_unstacked")

# Radius of the "knob" on the center of each ship
var click_radius = 16

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:	
		if (event.position - position).length() < click_radius:
			if not held and event.pressed:
				AudioBus.emit_signal("button_clicked")
				pickup()
				
		if held and not event.pressed:
			drop()
			# Convert the center of this piece to board-space
			var bs_position = world_to_board_space(position)
			# Check whether the piece is within half a board-space of the grid (-0.5, 9.5)
			if not (bs_position.x > -0.5 and bs_position.x < 9.5 and bs_position.y > -0.5 and bs_position.y < 9.5):
				if originalPos != null:
					collision = true
					vertical = true

	if event is InputEventMouseMotion and held:
		if snapOriginalPos == false:
			originalPos = position
			snapOriginalPos = true
		# Save the moise position, so _physics_process can use it
		mousePos = event.position;
		
	if event.is_action_pressed("ui_rotate"):
		if not held and not checkOriginalPos():
			if(event.position - position).length() < click_radius:
				#Play a sound
				AudioBus.emit_signal("button_clicked")
				# Rotation has been moved to _physics_process,
				# as per recommendation of godot_engine.org
				vertical = not vertical


# Offset from the corner of the screen to the corner of the board
const offset = Vector2(36, 36)
# The previous verticality of the object
var   prev_vertical = true
# The previous position of the object
var   prev_position = Vector2(0,0)
# The number of frames after an object is released to check for physics updates
var   released = 0

func _integrate_forces(state):
	if state.get_contact_count():
		collision = true

#   _physics_process: called in place of the physics processor
#     Checks collision and updates the position and rotation of the object
func _physics_process(_delta):
	# calculate whether the piece has been rotated or moved
	var rotated = prev_vertical != vertical
	var moved = prev_position != position
	
	# If the piece is held, move it to the mouse:
	if held and mousePos and mousePos != position:
		position = mousePos
		mousePos = null
	
	# Snap it to the grid if not held (and previously moved)
	if not held and moved:
		position = (position - offset).snapped(Vector2(32, 32)) + offset
		prev_position = position
		
	# If it's been moved or rotated, snap it to the board
	if released or rotated:
		# check whether the ends of the piece are within the board
		var linear_move = check_extents(position, vertical, ship_length)
		# if not, move them back inside
		if linear_move:
			if vertical:
				position += 32 * Vector2(0, linear_move)
			else:
				position += 32 * Vector2(linear_move, 0)
			pass
	
	# Check collisions after released, reset if colliding
	if collision and released:
		position = startingPos
		rotation = 0
		vertical = true
	# Rotate if the piece needs to be rotated
	if rotated:
		prev_vertical = vertical
		rotation = -PI/2 * int(not vertical) # int(true) == 1, int(false) == 0
		
	# Count down the number of physics timesteps left until the piece can stop processing
	if released > 0: 
		released = released - 1


func pickup():
	if not held:
		raise() # Render this ship on top of other ships
		held = true # mark it as held
		collision = false # Assume we're not colliding by default

func drop():
	if held:
		released = 1 # mark the node as released
		held = false # mark the node as not held
		snapOriginalPos = false

func checkOriginalPos():
	return position == startingPos


# Called when *this* ship collides with another ship
func ship_stacked(_body):
	collision = true
# Called when *this* ship stops colliding with another ship
func ship_unstacked(_body):
	collision = false

# Calculate the extents (front to back) of the ship and check whether they're on the board
# Returns how many squares to move the ship along its orientation axis (positive or negative)
func check_extents(center, orientation, length):
	center = world_to_board_space(center) # Convert to board-space (0-10)
	# Calculate the position of the front of the ship
	# Orientation is true when the ship is vertical
	var bow   = vectorget(center, orientation) - floor((length - 1) / 2)
	# if out of bounds, return how much to move the ship by
	if bow < 0:
		return -bow
	# Calculate the position of the rear of the ship
	var stern = vectorget(center, orientation) + floor(length / 2)
	# If out of bounds, return how much to move the ship by
	if stern >= 10:
		return -(stern - 9)
	return 0

func validate_placement():
	# Checks whether the ship's center is on the board.
	# As long as the ship was moved according to the rules defined in the
	# _physics_process function, this should be necessary and sufficient
	# to say the ship is on the board
	return check_extents(position, false, 1)

func clear():
	# ships return home on collision
	# simulate a collision
	collision = true
	released = 1

# Convert the world-space coordinates to positions on the board
func world_to_board_space(vector):
	# Do math
	var res = (vector - offset) / 32 # Basically Fahrenheit/Celcius conversion, but in 2D
	return res

# Inverse of the above function.
func board_to_world_space(vector):
	# Do math
	var res = (vector * 32) + offset #Invert the above function
	return res #Truncate decimals

# index a Vector2 like an array
# Why is this needed?
# So we can discard the unimportant axis! (a ship is always 1 unit wide!)
func vectorget(vector, axis):
	if axis:
		return vector.y
	else:
		return vector.x
