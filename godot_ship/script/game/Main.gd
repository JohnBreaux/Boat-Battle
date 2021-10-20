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
	MessageBus.connect("start_tcsn", self, "_on_scene_start_by_name")
	MessageBus.connect("change_scene", self, "_on_scene_start")
	MessageBus.connect("kill_scene",   self, "_on_scene_kill")
	MessageBus.connect("list_scenes",  self, "_on_scene_list")
	MessageBus.connect("quit",         self, "_on_quit_request")
	MessageBus.connect("return_to_title", self, "_on_title_request")
	# Create the scenes
	title_screen = preload("res://scenes/Title Screen.tscn")
	gameplay     = preload("res://scenes/Gameplay.tscn")
	options      = preload("res://scenes/Options.tscn")
	debug_menu   = preload("res://scenes/Debug Menu.tscn")
	if debug_enabled:
		add_child(debug_menu.instance())
	_on_scene_start("Title")

# Creates a new instance of each menu scene
func _on_scene_start(scene):
	print ("_on_scene_start(",scene,")")
	match scene:
		"Singleplayer": 
			add_child (gameplay.instance())
			return true
		"Multiplayer": 
			add_child (gameplay.instance())
			# add_child (multiplayercontroller.instance())
			return true
		"Options": 
			add_child (options.instance())
			return true
		"Title": 
			add_child (title_screen.instance())
			return true

func _on_scene_start_by_name(scene):
	var pack = load("res://scenes/" + scene + ".tscn");
	add_child(pack.instance());

# Kills all child nodes with name matching `scene`
func _on_scene_kill(scene):
	var c = get_children()
	for i in range (c.size()):
		if c[i].name == scene:
			c[i].queue_free()
			MessageBus.emit_signal("print_console", String(c[i].name) + " killed.\n".c_unescape())
			return true
	return false

func _on_scene_list():
	var children = get_children()
	var names = []
	for i in range (children.size()):
		names.append(children[i].name)
	MessageBus.emit_signal("print_console", String(names) + "\n".c_unescape())


# Quits
func _on_quit_request():
	get_tree().quit()

# Kills the current tree and replaces it with a new one
func _on_title_request():
	return get_tree().change_scene("res://scenes/Main.tscn")
