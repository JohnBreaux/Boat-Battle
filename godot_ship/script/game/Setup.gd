extends Control

signal board_ready

onready var Ships = ["2Ship", "3ShipA", "3ShipB", "4Ship", "5Ship"]

var light_theme = load("res://light_theme.tres")
var dark_theme = load("res://dark_theme.tres")

class ShipData:
	var Position: Vector2
	var Length: int
	var Orientation: bool # (True = vertical) (False = horizontal)
	var Variant: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Moves the focus to this menu
	if find_next_valid_focus(): find_next_valid_focus().grab_focus()
	
	get_node("PlaceShipDialog").get_ok().rect_min_size.x = 50
	
	var _errno = 0;
	_errno += OptionsController.connect("change_theme", self, "_on_change_theme")
	_on_change_theme(OptionsController.get_theme())

func _on_Confirm_Placement_pressed():
	# Make the button noise
	AudioBus.emit_signal("button_clicked")
	var valid = true
	for ship in Ships:
		# validate_placement returns the x-axis distance from the board
		# if this is more than zero, the ship is invalid
		if get_node(ship).validate_placement():
			valid = false
	if valid == false:
		get_node("PlaceShipDialog").popup()
	else:
		#Saves the location of ships and length of ship into an array
		var ship_data = []
		for ship in Ships:
			ship = get_node(ship)
			var data = ship.get_shipdata()
			ship_data.append(data)
		# Return the shipLocation array to those listening on game_ready
		emit_signal("board_ready", ship_data)
		queue_free()
	return valid # Replace with function body.

func _on_Clear_pressed():
	AudioBus.emit_signal("button_clicked")
	for ship in Ships:
		get_node(ship).clear()
	pass # Replace with function body.
	
func _on_change_theme(theme):
	if theme == "light":
		self.set_theme(light_theme)
	elif theme == "dark":
		self.set_theme(dark_theme)
