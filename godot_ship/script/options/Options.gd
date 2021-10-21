extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	find_next_valid_focus().grab_focus()


func _on_Button_pressed():
	queue_free()
	MessageBus.emit_signal("change_scene", "Title")
