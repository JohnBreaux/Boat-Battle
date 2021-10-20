extends Control


# Declare member variables here:


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Singleplayer.grab_focus()

func _on_Singleplayer_pressed():
	MessageBus.emit_signal("change_scene", "Singleplayer")
	
func _on_Multiplayer_pressed():
	MessageBus.emit_signal("change_scene", "Multiplayer")

func _on_Options_pressed():
	MessageBus.emit_signal("change_scene", "Options")

func _on_Quit_pressed():
	MessageBus.emit_signal("quit")
