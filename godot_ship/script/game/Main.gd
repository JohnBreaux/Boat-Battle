extends Control

# Scenes
var title_screen
var gameplay
var options
var debug_menu

var debug_enabled = true

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect to signals
	MessageBus.connect("change_scene", self, "_on_change_scene")
	MessageBus.connect("quit", self, "_on_quit_request")
	MessageBus.connect("return_to_title", self, "_on_title_request")
	# Create the scenes
	title_screen = preload("res://scenes/Title Screen.tscn")
	gameplay     = preload("res://scenes/Gameplay.tscn")
	options      = preload("res://scenes/Options.tscn")
	debug_menu   = preload("res://scenes/Debug Menu.tscn")
	if (debug_enabled):
		add_child(debug_menu.instance())
	_on_change_scene("Title")

func _on_change_scene(scene):
	match scene:
		"Singleplayer":
			add_child(gameplay.instance())
		"Multiplayer":
			add_child(gameplay.instance())
		"Options":
			add_child(options.instance())
		"Title":
			add_child(title_screen.instance())

func _on_quit_request():
	get_tree().quit()
	
func _on_title_request():
	get_tree().change_scene("res://scenes/Options.tscn")
