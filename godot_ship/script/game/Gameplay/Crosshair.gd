extends Sprite


var snapped = false #when snapped if true crosshair stops following mouse
const world_offset = Vector2(36,36)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Move the cursor to 0,0
	position = board_to_world_space(Vector2(-2,-2))
	pass # Replace with function body.

func _physics_process(_delta):
	var mousePos = get_global_mouse_position()
	# If the cursor is not snapped, and the mouse is over the board
	if snapped == false and validate_position(mousePos):
		# Snap the crosshair to the grid, but following the mouse
		position = (mousePos - world_offset).snapped(Vector2(32,32)) + world_offset

func _input(event):
	# Check if left click is being clicked and the sprite is visible (i.e only checks for inputs after ship positions are confirmed)
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and visible and not event.is_pressed():
		# Make a noise
		AudioBus.emit_signal("button_clicked")
		# Locks the position of the crosshair with left click release
		if validate_position(position) == true:
			# rounds the board position to the nearest integer
			snapped = true
			position.x = int(round(world_to_board_space(position).x))
			position.y = int(round(world_to_board_space(position).y))
			position = board_to_world_space(position)
	# Check if left click is being clicked and the sprite is visible (i.e only checks for inputs after ship positions are confirmed)
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT and visible == true:
		# Unlocks the position of the crosshair with left click
		snapped = false

func validate_position(vector):
	# rounds the board position to the nearest integer
	var board = world_to_board_space(vector)
	# Checks if the board position is within bounds of the board
	if board.x < 9.5 and board.x >= -0.5 and board.y < 9.5 and board.y >= -0.5:
		# changes the position of the crosshair
		return true
	else:
		# unlocks the crosshair if not within bounds
		return false

# Convert the world-space coordinates to positions on the board
func world_to_board_space(vector):
	# Do math
	var res = (vector - world_offset) / 32 # Basically Fahrenheit/Celcius conversion, but in 2D
	return res

# Inverse of the above function.
func board_to_world_space(vector):
	# Do math
	var res = (vector * 32) + world_offset #Invert the above function
	return res #Truncate decimals
