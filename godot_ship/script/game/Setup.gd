extends Control

signal game_ready

onready var Ships = ["2Ship", "3ShipA", "3ShipB", "4Ship", "5Ship"]

onready var Victory = preload("res://scenes/Game/Player.tscn")

class ShipData:
	var Position: Vector2
	var Length: int
	var Orientation: bool # (True = vertical) (False = horizontal)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Moves the focus to this menu
	if find_next_valid_focus(): find_next_valid_focus().grab_focus()


func _on_Confirm_Placement_pressed():
	# Make the button noise
	AudioBus.emit_signal("button_clicked")
	var valid = true
	for ship in Ships:
		# validate_placement returns the x-axis distance from the board
		# if this is more than zero, the ship is invalid
		if get_node(ship).validate_placement():
			valid = false
	print ("Placement: ", valid)
	if valid == false:
		get_node("PlaceShipDialog").popup()
	else:
		#Saves the location of ships and length of ship into an array
		var shipLocation = []
		for ship in Ships:
			var location = ShipData.new()
			location.Position = get_node(ship).position
			location.Length = get_node(ship).get("ship_length")
			location.Orientation = get_node(ship).get("vertical")
			shipLocation.append(location)
		
		#print out the array for testing
		for x in shipLocation:
			print("Ship Length: ", x.Length, ", Ship Orientation: ", x.Orientation, ", Ship Position: ", x.Position)
		
		# Return the shipLocation array to those listening on game_ready
		emit_signal("game_ready", shipLocation)
		queue_free()
	return valid # Replace with function body.

func _on_Clear_pressed():
	AudioBus.emit_signal("button_clicked")
	for ship in Ships:
		get_node(ship).clear()
	pass # Replace with function body.
