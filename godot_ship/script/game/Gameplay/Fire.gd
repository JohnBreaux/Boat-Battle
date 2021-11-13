extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Signal to pass the fire location back to yet-unknown nodes
signal fire_at


func _on_Fire_pressed():
	var crosshair = get_node("Crosshair")
	# hides crosshair
	crosshair.visible = false
	if crosshair.validate_position(crosshair.position) == true:
		var crosshair_pos = crosshair.world_to_board_space(crosshair.position)
		# fires at position
		print("Fire at position: ", crosshair_pos)
		emit_signal("fire_at", crosshair_pos)
		# Close the Firing menu
		queue_free()
	else:
		#if invalid position popup appears
		var dialog = get_node("FireDialog")
		dialog.popup_centered()
	pass # Replace with function body.

func _on_FireDialog_confirmed():
	get_node("Crosshair").visible = true
	pass # Replace with function body.
