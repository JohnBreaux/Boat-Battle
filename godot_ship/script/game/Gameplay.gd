extends Control

onready var Ships = ["2Ship", "3ShipA", "3ShipB", "4Ship", "5Ship"]


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
		get_node("AcceptDialog").popup()
	return valid # Replace with function body.


func _on_Clear_pressed():
	for ship in Ships:
		get_node(ship).clear()
	pass # Replace with function body.
