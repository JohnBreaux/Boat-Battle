extends Control

# Declare member variables here.
var debug_output
var debug_line = 0

var debug_canvas
var debug_transform

var debug_active = false
var menu_position = 0.0
var menu_velocity = 4

onready var present_working_node = get_node("/root/Main")

# positions when the menu is hidden/active
var menu_hidden = Transform2D(Vector2(1,0), Vector2(0,1), Vector2(0,-170))
var menu_active = Transform2D(Vector2(1,0), Vector2(0,1), Vector2(0,   0))

# signals
signal clear_in  # clears the debug input
signal clear_out # clears the debug output
signal print_text(text) # Sends text for printing to the Out buffer

# Called when the node enters the scene tree for the first time.
func _ready():
	debug_canvas = get_node("debug_canvas")
	debug_transform = debug_canvas.get_transform()
	debug_output = get_node("debug_canvas/VBoxContainer/TextEdit")
	command_help([""])
	debug_print_line("> ")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (debug_active && menu_position < 1):
		# Move the menu down
		menu_position += menu_velocity * delta;
		$debug_canvas/VBoxContainer/LineEdit.grab_focus()
	elif (!debug_active && menu_position > 0):
		# Move the menu up
		menu_position -= menu_velocity * delta;
		# Clear the input box
		emit_signal("clear_in")
	else:
		menu_position = round(menu_position)
	
	debug_canvas.set_transform(menu_hidden.interpolate_with(menu_active, menu_position))

func _input(event):
	if event.is_action_pressed("ui_debug"):
		# open debug menu
		debug_active = !debug_active;
		# Hand the keyboard focus to the next valid focus
		if (!debug_active) && find_next_valid_focus(): find_next_valid_focus().grab_focus()

func _on_LineEdit_text_entered(line):
	emit_signal("clear_in")
	debug_print_line(line + "\n")
	var command = line.split(' ', true, 1)
	match command[0]:
		"start", "open", "o":
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
		"pwd", "pwn":
			command_pwd(command)
		"cd", "cn":
			command_cd(command)
		_:
			debug_print_line("Command not recognized.\n")
	debug_print_line("> ")

func debug_print_line(string):
	emit_signal("print_text", string.c_unescape())

# Commands

#   start: Loads scene from res://scenes/*.tscn by filename, and starts it
func command_start (command):
	if command.size() > 1:
		var pack = load("res://scenes/" + command[1] + ".tscn");
		present_working_node.add_child(pack.instance());
		debug_print_line("start '" + command[1] + "'\n")
	else:
		debug_print_line("Usage: start scene")

#   stop: kills a child of current working node
func command_stop (command):
	if command.size() > 1:
		var node = present_working_node.find_node(command[1], false, false)
		if node:
			if String(node.get_path()).match("*Debug*"):
				debug_print_line("YOU DIDN'T SAY THE MAGIC WORD!\n")
			else:
				node.queue_free()
				debug_print_line(command[1] + " killed\n")
		else:
			debug_print_line(command[0] + ": " + command[1] + " not found.\n")
	else:
		debug_print_line("Usage: kill name\n")

#   list: Lists children of node
func command_list (command):
	var node = null
	if (command.size() > 1):
		node = complete_path(command[1])
	if (!node):
		node = present_working_node
	var children = node.get_children()
	var names = []
	for i in range (children.size()):
		names.append(children[i].name)
	debug_print_line(String(names) + "\n")

#   restart: Kills the current tree and replants Root
func command_restart (_command):
	MessageBus.emit_signal("return_to_title")

#   print: prints a message to the in-game debug console
func command_print(command):
	if command.size() > 1:
		debug_print_line(command[1] + "\n")
	else:
		debug_print_line("\n")

#   emit: emits a message onto the MessageBus
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
func command_clear (_command):
	emit_signal("clear_out");

#   pwd: print the current working node's path
func command_pwd (_command):
	debug_print_line(String(present_working_node.get_path()) + "\n")
#   cd: change the current working node
func command_cd (command):
	if command.size() > 1:
		var node = complete_path(command[1])
		if node:
			present_working_node = node
		else:
			debug_print_line ('cn: no such node: ' + command[1] + '\n')
	else:
		debug_print_line("")
	pass

#   help: Prints help dialogue
func command_help (command):
	if (command.size() == 1):
		debug_print_line("Valid commands:\nhelp, start, stop, list, restart, print, emit, clear, pwn, cn\n")
	else:
		debug_print_line(command[1])
		match command[1]:
			"start", "open", "o":
				debug_print_line(" filename\nAliases: 'start', 'open', 'o'\n")
				debug_print_line("Load add the scene filename.tscn as child\n")
			"stop", "kill", "k":
				debug_print_line(" name\nAliases: 'stop', 'kill', 'k'\n")
				debug_print_line("Kill node with matching name\n")
			"list", "ls", "l":
				debug_print_line(" [path]\nAliases: 'list', 'ls', 'l'\n")
				debug_print_line("List node children\n")
			"restart", "killall":
				debug_print_line("\nAliases: 'restart', 'killall'\n")
				debug_print_line("Kill the current scene tree and plant a new Root.\n")
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
			"pwd", "pwn":
				debug_print_line("\nAliases: 'pwn', 'pwd'\n")
				debug_print_line("Prints the Present Working Node.\n")
			"cd", "cn":
				debug_print_line(" path/to/node\nAliases: 'cn', 'cd'\n")
				debug_print_line("Change the Present Working Node.\n")
			_:
				debug_print_line(command[1] + "\nIsn't a valid command\n")

# Completes a relative or absolute path, and returns the node it refers to
func complete_path(path):
	if path.is_rel_path(): # convert to absolute path
		path = String(present_working_node.get_path()) + "/" + path
	var node = get_node(path)
	if node:
		return node
	return null
