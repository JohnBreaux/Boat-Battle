extends Control

# Scenes
onready var Title_Screen = preload("res://scenes/Title Screen.tscn")
onready var Game         = preload("res://scenes/Game/Game.tscn"   )
onready var Options      = preload("res://scenes/Options.tscn"     )
onready var Debug_Menu   = preload("res://scenes/Debug Menu.tscn"  )

# Themes
var lightmode = preload("res://assets/backgrounds/Background_Light.png")
var darkmode = preload("res://assets/backgrounds/Background_Dark.png")
var light_theme = load("res://light_theme.tres")
var dark_theme = load("res://dark_theme.tres")

#flags
var power_saving = true
var debug_enabled = true
var start_fullscreen = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect to signals
	var _errno = 0;
	_errno += MessageBus.connect("start_tcsn"     , self, "_on_scene_start_by_name")
	_errno += MessageBus.connect("change_scene"   , self, "_on_scene_start"        )
	_errno += MessageBus.connect("kill_scene"     , self, "_on_scene_kill"         )
	_errno += MessageBus.connect("list_scenes"    , self, "_on_scene_list"         )
	_errno += MessageBus.connect("quit"           , self, "_on_quit_request"       )
	_errno += MessageBus.connect("return_to_title", self, "_on_title_request"      )
	_errno += OptionsController.connect("change_theme", self, "_on_change_theme"   )
	# Set the theme based on the config file
	_on_change_theme(OptionsController.get_theme())
	# go fullscreen
	OS.low_processor_usage_mode = power_saving
	OS.low_processor_usage_mode_sleep_usec = 6800
	OS.window_fullscreen = start_fullscreen
	if debug_enabled:
		add_child(Debug_Menu.instance())

# Process global keybinds
func _input(event):
	if event.is_action_pressed("ui_fullscreen"):
		# toggle_fullscreen
		OS.window_fullscreen = !OS.window_fullscreen


# Ensure the scene doesn't become empty
func _process(_delta):
	# Make sure there's something running
	# Background counts as one child
	# Debug counts as one child
	if get_child_count() < 2 + int(debug_enabled):
		MessageBus.emit_signal("change_scene", "Title")
		pass

# Creates a new instance of each menu scene
func _on_scene_start(scene):
	var instance
	#print ("_on_scene_start(",scene,")")
	match scene:
		"Singleplayer": 
			instance = Game.instance()
			add_child (instance)
			return true
		"Multiplayer": 
			instance = Game.instance()
			instance.is_multiplayer = true
			add_child (instance)
			return true
		"Options": 
			instance = Options.instance()
			add_child (instance)
			return true
		"Title": 
			instance = Title_Screen.instance()
			add_child (instance)
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
	
func _on_change_theme(theme):
	if theme == "light":
		get_node("Background").set_texture(lightmode)
		self.set_theme(light_theme)
	elif theme == "dark":
		get_node("Background").set_texture(darkmode)
		self.set_theme(dark_theme)
