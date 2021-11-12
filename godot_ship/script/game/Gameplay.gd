extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	if find_next_valid_focus(): find_next_valid_focus().grab_focus()


func _on_Forfeit_pressed():
	AudioBus.emit_signal("button_clicked")
	queue_free();
	MessageBus.emit_signal("change_scene", "Title")

