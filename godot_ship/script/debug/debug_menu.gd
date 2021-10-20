extends Control

# Declare member variables here.
var debug_output
var debug_line = 0

var debug_canvas
var debug_transform

var debug_active = false
var menu_position = 0.0
var menu_velocity = 4

# positions when the menu is hidden/active
var menu_hidden = Transform2D(Vector2(1,0), Vector2(0,1), Vector2(0,-170))
var menu_active = Transform2D(Vector2(1,0), Vector2(0,1), Vector2(0,   0))

# signals
signal clear_in
signal clear_out
signal print_text(text)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	debug_canvas = get_node("debug_canvas")
	debug_transform = debug_canvas.get_transform()
	debug_output = get_node("debug_canvas/VBoxContainer/TextEdit")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (debug_active && menu_position < 1):
		menu_position += menu_velocity * delta;
	elif (!debug_active && menu_position > 0):
		menu_position -= menu_velocity * delta;
	else:
		menu_position = round(menu_position)
	
	debug_canvas.set_transform(menu_hidden.interpolate_with(menu_active, menu_position))

func _input(event):
	if event.is_action_pressed("ui_debug"):
		# open debug menu
		debug_active = !debug_active;

func _on_LineEdit_text_entered(line):
	emit_signal("clear_in")
	debug_print_line("")
	var command = line.split(' ', true, 1)
	match command[0]:
		"start", "s":
				command_start(command)
		"stop", "kill", "k":
			command_stop(command)
		"list", "ls", "l":
			command_list(command)
		"restart", "killall":
			command_restart(command)
		"print", "p":
			command_print(command)
		"raw_emit", "emit", "r", "e": # Send a signal over the MessageBus
			command_emit(command)
		"clear","cls": # Clear the output
			command_clear(command)
		"help", "h":
			command_help(command)
		_:
			debug_print_line("Command not recognized.\n")

func debug_print_line(string):
	emit_signal("print_text", string.c_unescape())

# Commands

#   start: Loads scene from res://scenes/*.tscn by filename, and starts it
func command_start (command):
	if command.size() > 1:
		MessageBus.emit_signal("start_tcsn", command[1])
		debug_print_line("start '" + command[1] + "'\n")
	else:
		debug_print_line("Usage: start scene")

#   stop: Stops scene by name of root node.
func command_stop (command):
	if command.size() > 1 and command[1] != "Debug":
		MessageBus.emit_signal("kill_scene", command[1])
		debug_print_line("kill '" + command[1] + "'\n")
	else:
		debug_print_line("Usage: kill scene")

#   list: Lists names of active scenes (children of Root)
func command_list (command):
	debug_print_line("list: ")
	MessageBus.emit_signal("list_scenes")

#   restart: Kills the current tree and replants Root
func command_restart (command):
	MessageBus.emit_signal("return_to_title")

#   print: prints a message to the in-game debug console
func command_print(command):
	if command.size() > 1:
		debug_print_line(command[1] + "\n")

#   emit: emits a message onto the MessageBus (!Extremely Danger!)
func command_emit (command):
	var mbus_signal = command[1].split(' ', true, 1)
	match mbus_signal.size():
		2:
			debug_print_line("Message: " + String(mbus_signal) + "\n")
			MessageBus.emit_signal(mbus_signal[0], mbus_signal[1])
		1:
			debug_print_line("Message: " + String(mbus_signal) + "\n")
			MessageBus.emit_signal(mbus_signal[0])
		0: debug_print_line( "Usage: raw_emit signal [value]\n")

#   clear: clears the debug output
func command_clear (command):
	emit_signal("clear_out");

#   help: Prints help dialogue
func command_help (command):
	if (command.size() == 1):
		debug_print_line("Ship's Commander V0.1\n")
		debug_print_line("Valid commands:\nstart, stop, list, restart, print, emit, clear, help\n")
	else:
		debug_print_line(command[1])
		match command[1]:
			"start", "s":
				debug_print_line(" filename\nAliases: 'start', 's'\n")
				debug_print_line("Loads and runs the scene filename.tscn\n")
			"stop", "kill", "k":
				debug_print_line(" scene\nAliases: 'stop', 'kill', 'k'\n")
				debug_print_line("Kills an active scene whose name matches node.\n")
			"list", "ls", "l":
				debug_print_line("\nAliases: 'list', 'ls', 'l'\n")
				debug_print_line("Lists the currently active scenes\n")
			"restart", "killall":
				debug_print_line("\nAliases: 'restart', 'killall'\n")
				debug_print_line("Kills the current scene tree and plants a new Root.\n")
			"print", "p":
				debug_print_line(" string\nAliases: 'print', 'p'\n")
				debug_print_line("Prints a string to the in-game debug console\n")
			"raw_emit", "emit", "r", "e":
				debug_print_line(" signal [message]\nAliases: 'raw_emit', 'emit', 'r', 'e'\n")
				debug_print_line("Puts a message on the MessageBus without validation.\n")
			"clear","cls":
				debug_print_line("\nAliases: 'clear', 'cls'\n")
				debug_print_line("Clears the debug output.\n")
			"help", "h":
				debug_print_line(" [command]\nAliases: 'help', 'h'\n")
				debug_print_line("Prints information about a command.\n")
			_:
				debug_print_line(command[1] + "\nIsn't a valid command\n")
	debug_print_line("\n")
