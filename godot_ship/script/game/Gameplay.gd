extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if find_next_valid_focus(): find_next_valid_focus().grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Forfeit_pressed():
	AudioBus.emit_signal("button_clicked")
	queue_free();
	MessageBus.emit_signal("change_scene", "Title")
