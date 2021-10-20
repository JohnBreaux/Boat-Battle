extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Singleplayer.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Singleplayer_pressed():
	get_tree().change_scene("res://scenes/Gameplay.tscn")
	
func _on_Multiplayer_pressed():
	get_tree().change_scene("res://scenes/Gameplay.tscn")

func _on_Options_pressed():
	get_tree().change_scene("res://scenes/Options.tscn")

func _on_Quit_pressed():
	get_tree().quit()