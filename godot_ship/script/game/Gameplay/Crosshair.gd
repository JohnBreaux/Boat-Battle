extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var snapped = false #when snapped if true crosshair stops following mouse

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if snapped == false:
		position += (get_global_mouse_position() - position)/10

func _input(event):
	# Check if left click is being clicked and the sprite is visible (i.e only checks for inputs after ship positions are confirmed)
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and visible == true:
		# Locks the position of the crosshair with left click
		if validate_position(position) == true:
			# rounds the board position to the nearest integer
			snapped = true
			position.x = int(round(world_to_board_space(position).x))
			position.y = int(round(world_to_board_space(position).y))
			position = board_to_world_space(position)
	# Check if left click is being clicked and the sprite is visible (i.e only checks for inputs after ship positions are confirmed)
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and visible == true:
		# Unlocks the position of the crosshair with right click
		snapped = false

func validate_position(vector):
	# rounds the board position to the nearest integer
	var boardx = int(round(world_to_board_space(vector).x))
	var boardy = int(round(world_to_board_space(vector).y))
	# Checks if the board position is within bounds of the board
	if boardx < 11 and boardx > 0 and boardy < 11 and boardy > 0:
		# changes the position of the crosshair
		return true
	else:
		# unlocks the crosshair if not within bounds
		return false

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
