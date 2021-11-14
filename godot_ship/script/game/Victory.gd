extends Control

signal exit_main
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# returns player(s) back to main menu
func _on_Button_pressed():
	AudioBus.emit_signal("button_clicked")
	#MessageBus.emit_signal("change_scene", "Title")
	emit_signal("exit_main")


func _on_restart_button_down():
	AudioBus.emit_signal("button_clicked")
	#MessageBus.emit_signal("change_scene", "Multiplayer")
	pass # Replace with function body.
 
