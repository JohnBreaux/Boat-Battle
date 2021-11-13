extends Control

onready var Ships = ["2Ship", "3ShipA", "3ShipB", "4Ship", "5Ship"]
onready var Crosshair

class Location:
	var Coor: Vector2
	var Length: int
	var Orientation: bool #vertical is true, (Trueship = vertical) (Falseship = horizontal)

# Called when the node enters the scene tree for the first time.
func _ready():
	if find_next_valid_focus(): find_next_valid_focus().grab_focus()


func _on_Forfeit_pressed():
	AudioBus.emit_signal("button_clicked")
	queue_free();
	MessageBus.emit_signal("change_scene", "Title")



func _on_Confirm_Placement_pressed():
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
			var location = Location.new()
			location.Coor = get_node(ship).position
			location.Length = get_node(ship).get("ship_length")
			location.Orientation = get_node(ship).get("vertical")
			shipLocation.append(location)
		
		#print out the array for testing
		for x in shipLocation:
			print("Ship Length: ", x.Length, ", Ship Orientation: ", x.Orientation, "Ship Coor: ", x.Coor)
		
		#Hides the ship placement UI
		var confirmButton = get_node("Confirm Placement")
		var clearButton = get_node("Clear")
		var ship1 = get_node("2Ship")
		var ship2 = get_node("3ShipA")
		var ship3 = get_node("3ShipB")
		var ship4 = get_node("4Ship")
		var ship5 = get_node("5Ship")
		confirmButton.visible = false
		clearButton.visible = false
		ship1.visible = false
		ship2.visible = false
		ship3.visible = false
		ship4.visible = false
		ship5.visible = false
		
		#Changes to firing mode, makes the fireing mode UI visible (The location of this can be changed later. This position is for testing)
		var crosshair = get_node("Crosshair")
		var fireButton = get_node("Fire")
		crosshair.visible = true
		fireButton.visible = true
	return valid # Replace with function body.

func _on_Clear_pressed():
	for ship in Ships:
		get_node(ship).clear()
	pass # Replace with function body.


func _on_Fire_pressed():
	var crosshair = get_node("Crosshair")
	# hides crosshair
	crosshair.visible = false
	if crosshair.validate_position(crosshair.position) == true:
		# fires at position
		print("Fire at position: ", crosshair.position)
	else:
		#if invalid position popup appears
		var dialog = get_node("FireDialog")
		dialog.popup_centered()
	pass # Replace with function body.

func _on_FireDialog_confirmed():
	get_node("Crosshair").visible = true
	pass # Replace with function body.
