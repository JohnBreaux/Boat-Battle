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
	var _errno = 0;
	_errno += MessageBus.connect("start_tcsn", self, "_on_scene_start_by_name")
	_errno += MessageBus.connect("change_scene", self, "_on_scene_start")
	_errno += MessageBus.connect("kill_scene",   self, "_on_scene_kill")
	_errno += MessageBus.connect("list_scenes",  self, "_on_scene_list")
	_errno += MessageBus.connect("quit",         self, "_on_quit_request")
	_errno += MessageBus.connect("return_to_title", self, "_on_title_request")
	# Create the scenes
	title_screen = preload("res://scenes/Title Screen.tscn")
	gameplay     = preload("res://scenes/Gameplay.tscn")
	options      = preload("res://scenes/Options.tscn")
	debug_menu   = preload("res://scenes/Debug Menu.tscn")
	# go fullscreen
	OS.window_fullscreen = true
	if debug_enabled:
		add_child(debug_menu.instance())

# Process global keybinds
func _input(event):
	if event.is_action_pressed("ui_fullscreen"):
		# toggle_fullscreen
		OS.window_fullscreen = !OS.window_fullscreen


# Ensure the scene doesn't become empty
func _process(_delta):
	# Make sure there's something running
	# Debug counts as one child
	if get_child_count() < 1 + int(debug_enabled):
		MessageBus.emit_signal("change_scene", "Title")
		pass

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
	var node = find_node(scene, false, false)
	if node :
		node.queue_free()
		MessageBus.emit_signal("print_console", String(node.name) + " killed.\n".c_unescape())

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
