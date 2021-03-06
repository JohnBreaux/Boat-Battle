extends Control

# Hello, god class. Though, as an optional module, it's not the worst it could be.
# Smells of feature creep, because it absolutely is one.

var debug_canvas

var debug_active = false
var menu_moving = false
var menu_position = 0.0
var menu_velocity = 4

var history : Array = []
var history_pos = 0

# Controls whether to print to the screen
var echo = true

# Controls whether the player is allowed to cheat:
var cheats = false
var cheat_code = "989172bdaff124fc237b3f904a1886b91dc3ae718da15a6055ff416284f39a58"

onready var expression = Expression.new()

# metadata: args list, help blurb, and cheatmap accessed by function name
enum {ARGS, HELPTEXT, IS_CHEAT}
var command_metadata = {
#	command_id               [args                 "Help text"                                               is cheat]
	"command_help":          [" [command]",        "Print information about command.\n",                        false],
	"command_history":       ["",                  "Print the history log.\n",                                  false],
	"command_perf":          [" stat",             "Print performance info (fps, nodes, proctime, ... )\n",     false],

	"command_list":          [" [path]",           "List children of path, or of present working node.\n",      false],
	"command_start":         [" filename",         "Load PackedScene filename.tscn as child.\n",                true ],
	"command_kill":          [" name",             "Kill child node with matching name.\n",                     true ],

	"command_pwd":           ["",                  "Print the Present Working Node.\n",                         false],
	"command_cd":            [" path",             "Change the Present Working Node to path.\n",                false],

	"command_print":         [" string",           "Print string to the in-game debug console.\n",              false],
	"command_clear":         ["",                  "Clear the debug output.\n",                                 false],
#	!EXTREMELY DANGER {
	"command_emit":          [" signal [message]", "Emit a message on MessageBus.signal without validation.\n", true ],
	"command_call":          [" func [args ...]",  "Call func(...) with arguments args.\n",                     true ],
	"command_exec":          [" expression ...",   "Evaluate an arbitrary expression, and print the result.\n", true ],
#	}
	"command_listprops":     ["",                  "List properties of the Present Working Node\n",             true ],
	"command_getprop":       [" prop",             "Get the value of property prop\n",                          true ],
	"command_setprop":       [" prop value",       "Set the property prop to value.\n",                         true ],

	"command_script":        [" path",             "Load and execute a script at user://scripts/<name>\n",      false],
	"command_echo":          [" on/off",           "Controls whether lines should be printed to the screen\n",  true ],
	"command_cheat":         [" [password]",       "Controls whether cheats are enabled, using a fun code\n",   false],

	"command_restart":       ["",                  "Kill the current scene tree and plant a new Root.\n",       true ],
	"command_exit":          ["",                  "Quits the program.\n",                                      false],

	"command_empty":         ["",                  "No Operation.\n",                                           false],
}

# List of debug commands accessed by alias
# The first alias is the canonical alias, aka command name
var commands = {
#   [alias array]:                  "func_name"
	["help", "h"]:                  "command_help",
	["hist", "history"]:            "command_history",
	["perf", "performance"]:        "command_perf",

	["list", "ls", "l"]:            "command_list",
	["start", "open", "o"]:         "command_start",
	["kill", "stop", "k"]:          "command_kill",

	["pwd", "pwn"]:                 "command_pwd",
	["cd", "cn"]:                   "command_cd",

	["print", "p"]:                 "command_print",
	["clear","cls"]:                "command_clear",

	["emit", "e"]:                  "command_emit",
	["call", "func"]:               "command_call",
	["exec", "_", "$", ">"]:        "command_exec",

	["listprops", "lsp"]:           "command_listprops",
	["getprop","get", "g"]:         "command_getprop",
	["setprop","set", "s"]:         "command_setprop",

	["script", "sh"]:               "command_script",
	["@echo"]:                      "command_echo",
	["cheat", "*"]:                 "command_cheat",

	["restart", "killall"]:         "command_restart",
	["exit", "quit"]:               "command_exit",

	["", "#"]:                      "command_empty"
}

#List of all of Godot's builtin types
const types:Array = [
	"nil", "bool","int","float","String","Vector2","Rect2",
	"Vector3","Transform2D","Plane","Quat","AABB","Basis","Transform",
	"Color","NodePath","RID","Object","Dictionary","Array","PoolByteArray",
	"PoolIntArray","PoolRealArray","PoolStringArray","PoolVector2Array",
	"PoolVector3Array","PoolColorAray"
]

onready var present_working_node = get_node("/root/Main")

# positions when the menu is hidden/active
var menu_hidden = Transform2D(Vector2(1,0), Vector2(0,1), Vector2(0,-170))
var menu_active = Transform2D(Vector2(1,0), Vector2(0,1), Vector2(0,   0))

# signals
#   clear_in:  clear the debug input
signal clear_in
#   clear_out: clear the debug output
signal clear_out
#   print_text(text): Send text to the Out buffer
signal print_text(text)
#   history_event(text): Send text to the In buffer
signal history_event(text)

# Inherited functions:
#   _ready: Called when the node enters the scene tree for the first time.
#     params: none
#     returns: void
func _ready():
	debug_canvas = get_node("debug_canvas")
	debug_canvas.set_transform(menu_hidden) #initialize the debug menu as hidden
	command_help([""])
	debug_print_line("> ")

#   _process: Called every frame. Controls slide-in animation and focus-grabbing
#     params: delta: elapsed time
#     returns: void
func _process(delta):
	if (debug_active && menu_position < 1):
		# Move the menu down
		menu_position += menu_velocity * delta;
		menu_moving = true
		$debug_canvas/VBoxContainer/LineEdit.grab_focus()
	elif (!debug_active && menu_position > 0):
		# Move the menu up
		menu_position -= menu_velocity * delta;
		menu_moving = true
		# Clear the input box
		emit_signal("clear_in")
	elif (menu_position < 0 || menu_position > 1):
		menu_position = round(menu_position)
		menu_moving = true
	else:
		menu_moving = false
	if menu_moving:
		debug_canvas.set_transform(menu_hidden.interpolate_with(menu_active, menu_position))

#   _input: Process user input related to the debug menu
#     params: event: The input event which triggered _input call
#     returns: void
func _input(event):
	if event.is_action_pressed("ui_debug_open"):
		# open debug menu
		debug_active = !debug_active;
		# Hand the keyboard focus to the next valid focus
		if (!debug_active) && find_next_valid_focus(): find_next_valid_focus().grab_focus()
	if event.is_action_pressed("ui_debug_up") and debug_active:
		#traverse history up
		history_move(-1)
		pass
	if event.is_action_pressed("ui_debug_down") and debug_active:
		#traverse history down
		history_move(+1)

# Command-processing functions:
#   _on_LineEdit_text_entered: process incoming text line
#     params: line: Line of text entered by user
#     returns: void
func _on_LineEdit_text_entered(line):
	emit_signal("clear_in")
	debug_print_line(line + "\n")
	var command = line.split(' ', true, 1)
	if execute_command(command):
		history_append(line)
	else:
		debug_print_line("dbg: command not found: " + command[0] + "\n")
	debug_print_line("> ")

#   execute_command: execute a line of text as a command
#     params: command: partially tokenized PoolStringArray ["command_alias", "parameters ..."]
#     returns: name of executed function, or null if nothing executed
func execute_command(command):
	var command_func = parse(command[0])
	if command_func and is_command_allowed(command_func):
		call(command_func, command)
	else:
		command_func = null
	return command_func

#   is_command_allowed: Test if the command is allowed (not cheating, or cheating is on)
#     params: command_func: the name of the function to be executed
#     returns: true if command is valid, or false if command is cheat and cheating is disabled
func is_command_allowed(command_func):
	# return true if cheats or on, or command is not cheat
	return cheats or not command_metadata[command_func][IS_CHEAT]

# History_related helper functions:
#   history_append: add a line of text to the history
#     params: text: line of text (unparsed command) to add to history
#     returns: void
func history_append(text):
	history.resize(history_pos + 2)
	history[history_pos] = text
	history[history_pos + 1] = ""
	history_pos += 1

#   history_move: Traverse the history and update the user input box
#     params: rel_pos: amount to move, relative to the current history_pos
#     returns: void
func history_move(rel_pos):
	var new_pos = history_pos + rel_pos
	if new_pos >= 0 and new_pos < history.size():
		history_pos = new_pos;
		if history[history_pos]:
			emit_signal("history_event", history[history_pos])
		else:
			emit_signal("clear_in")

# Debug-related helper functions:
#   debug_print_line: request printing of c-escaped text to debug output
#     params: string: Text string to print
#     returns: void
func debug_print_line(string):
	if echo:
		emit_signal("print_text", string.c_unescape())

#   get_pwn: get the present working node if valid, otherwise cd to root
func get_pwn():
	if !is_instance_valid(present_working_node):
		debug_print_line("Node freed, traversing to /root/\n")
		present_working_node = get_node("/root/")
	return present_working_node


#   complete_path: complete a relative or absolute path, and returns the node it refers to
#     params: path: relative or absolute path to a node
#     returns: void
func complete_path(path):
	if path.is_rel_path(): # convert to absolute path
		path = String(get_pwn().get_path()) + "/" + path
	var node = get_node(path)
	if node:
		return node
	return null

# Command-lookup functions:
#   parse: parse command name and return associated func name
#     params: alias: alias of a command
#     returns: name of command function
func parse(alias):
	var key = lookup(alias)
	if key:
		return commands[key]
	return null

#   name_lookup: find key associated with function name
#     params: command_name: alias of a command
#     returns: key: Array containing all aliases of the given command
func lookup(alias):
	for key in commands.keys():
		if alias in key:
			return key
	return null

#   get_canonical: find the canonical name for a command
#     params: alias: alias of a command
#     returns: name: canonical name for a command
func get_canonical(alias):
	var names = lookup(alias)
	if names:
		return names[0]
	return null

#   get_usage: Construct the usage string for a command
#     params: alias: alias of a command
#     returns: usage string for the command, formatted for printing
func get_usage(alias):
	return "Usage: " + alias + command_metadata[parse(alias)][0] + "\n"

# String casting functions
#   variant_to_string: Cast arbitrary GDScript Variant to String
#     params: variant: variant to cast
#     returns: String representing the Variant as closely as possible
func variant_to_string(variant):
	var res
	match typeof(variant):
		TYPE_NIL:
			res = "null"
		TYPE_OBJECT: #No conversion from object to string; a unique case.
			if (variant):
				res = variant.to_string()
			else:
				res = "Object = null"
		_:
			res = String(variant)
	return res

#   string_to_variant: Cast a string to a specified GDScript type
#     params: string: string to be cast
#             type: type to cast string to
#     returns: GDScript Variant of given type
func string_to_variant(string, type):
	var res = null
	var list = listify_string(string)
	match type:
		TYPE_NIL:
			res = null
		TYPE_BOOL:
			match string.to_lower():
				"true", "1", "ok", "on":
					res = true
				_:
					res = false
		TYPE_INT:
			res = int(string)
		TYPE_REAL:
			res = float(string)
		TYPE_STRING:
			res = string
		TYPE_COLOR:
			res = Color(string)
		TYPE_NODE_PATH:
			res = NodePath(string)
		TYPE_ARRAY:
			res = list
		TYPE_RAW_ARRAY:
			res = PoolByteArray(list)
		TYPE_INT_ARRAY:
			res = PoolIntArray(list)
		TYPE_REAL_ARRAY:
			res = PoolRealArray(list)
		TYPE_STRING_ARRAY:
			res = list
		TYPE_COLOR_ARRAY:
			res = PoolColorArray(list)
		_:
			debug_print_line("No cast from String to %s\n" % types[typeof(type)])
	return res

#   listify_string: takes a string and turns it into a list, by splitting on commas and/or spaces
#     params: string: string to be made into a list
#     returns: PoolStringArray containing substrings of the list
func listify_string(string):
	var res = []
	if string.findn(', ') > -1:
		res = string.split(', ', true, 0)
	elif string.findn(',') > -1:
		res = string.split(',',  true, 0)
	else:
		res = string.split(' ',  true, 0)
	return res

#  file_exists: checks if a file exists at path
#    params: path: string denoting the path to a file
#    returns: bool denoting file's presence at path
func file_exists(path):
	var D = Directory.new()
	return D.file_exists(path)


# Commands. All commands take in a parameter called command,
# which contains a partially tokenized command
#   start: Loads scene from res://scenes/*.tscn by filename, and starts it
func command_start (command):
	if command.size() > 1:
		var path = "res://scenes/%s.tscn" % command[1]
		var pack = load(path) if file_exists(path) else null
		# Check if the resource was opened
		if pack:
			get_pwn().add_child(pack.instance());
			debug_print_line("started '%s'\n" % command[1])
		else:
			debug_print_line("Path not found: %s\n" % "res://scenes/%s.tscn" % command[1])
	else:
		debug_print_line(get_usage(command[0]))

#   stop: kills a child of current working node
func command_kill (command):
	if command.size() > 1:
		var node = get_pwn().find_node(command[1], false, false)
		if node:
			if String(node.get_path()).match("*Debug*"):
				debug_print_line("I'm sorry, Dave. I'm afraid I can't do that.\n")
			else:
				node.queue_free()
				debug_print_line("%s killed\n" % command[1])
		else:
			debug_print_line("%s: %s not found.\n" % [command[0], command[1]])
	else:
		debug_print_line(get_usage(command[0]))

#   list: Lists children of node
func command_list (command):
	var node = null
	if (command.size() > 1):
		node = complete_path(command[1])
	if (!node):
		node = get_pwn()
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
		debug_print_line(command[1])
	else:
		debug_print_line("\n")

#   emit: emits a message onto the MessageBus
func command_emit (command):
	if command.size() > 1:
		var mbus_signal = command[1].split(' ', true, 1)
		match mbus_signal.size():
			2:
				debug_print_line("Message: %s (%s)" % mbus_signal)
				MessageBus.emit_signal(mbus_signal[0], mbus_signal[1])
			1:
				debug_print_line("Message: %s" % mbus_signal)
				MessageBus.emit_signal(mbus_signal[0])
			0: debug_print_line(get_usage(command[0]))
	else:
		debug_print_line(get_usage(command[0]))

#   clear: clears the debug output
func command_clear (_command):
	emit_signal("clear_out");

#   pwd: print the present working node's path
func command_pwd (_command):
	debug_print_line(String(get_pwn().get_path()) + "\n")

#   cd: change the present working node
func command_cd (command):
	if command.size() > 1:
		var node = complete_path(command[1])
		if node:
			present_working_node = node
		else:
			debug_print_line (get_canonical(command[0]) + ': no such node: ' + command[1] + '\n')
	else:
		debug_print_line(get_usage(command[0]))

#   help: Prints help dialogue
func command_help (command):
	if (command.size() == 1):
		debug_print_line("Valid commands:\n")
		for key in commands:
			# if command is allowed in current context, print it
			if is_command_allowed(commands[key]):
				debug_print_line(key[0] + " ")
		debug_print_line("\n")
	else:
		var command_func = parse(command[1])
		if command_func in command_metadata and is_command_allowed(command_func):
			var text    = command_metadata[command_func]
			var aliases = String(lookup(command[1]))
			debug_print_line("%s%s:\n   Aliases: %s\n   %s" % [command[1], text[ARGS], aliases, text[HELPTEXT]])
		else:
			debug_print_line("%s: command not found: %s\n" % [command[0], command[1]])

#   exit: request program exit
func command_exit(_command):
	MessageBus.emit_signal("quit")

#   call: call arbitrary member function of present working node
func command_call(command):
	if command.size() > 1:
		var call_ret = null
		var call_args = []
		var call_cmd = command[1].split(' ', true, 1)
		if call_cmd.size() > 1:
			call_args = call_cmd[1].split(' ', false, 0)
		if get_pwn().has_method(call_cmd[0]):
			call_ret = get_pwn().callv(call_cmd[0], call_args)
		else:
			debug_print_line("We're sorry, but your call could not be completed as dialed.\n"
			+ "Please hang up and try your call again.\n")
			return
		debug_print_line("%s\n" % variant_to_string(call_ret))
	else:
		debug_print_line(get_usage(command[0]))

#   exec: execute an arbitrary GDScript expression as present working node
func command_exec(command):
	if command.size() > 1:
		var res
		var err = expression.parse(command[1])
		if err == OK:
			res = expression.execute([], get_pwn(), false);
			if expression.has_execute_failed():
				debug_print_line("%s: command not found: %s " % [command[0], command[1]])
				res = ""
		else:
			res = expression.get_error_text()
		debug_print_line("%s\n" % variant_to_string(res))
	else:
		debug_print_line(get_usage(command[0]))

#   listprops: list properties (variables) of present working node
func command_listprops(_command):
	var props = ""
	var proplist = get_pwn().get_property_list()
	proplist.sort_custom(self, "propSort")
	for prop in proplist:
		if prop["name"]:
			props += "%s %s\n" % [types[prop["type"]], prop["name"]]
		pass
	debug_print_line(props)
	pass
#     propsort: sort props by type, alphabetically
func propSort(a, b):
	if a["type"] == b["type"]:
		return a["name"] < b["name"]
	return types[a["type"]].to_lower() < types[b["type"]].to_lower()

#   getprop: get the value of a named property of the present working node
func command_getprop(command):
	if command.size() > 1:
		var res = get_pwn().get(command[1])
		debug_print_line(variant_to_string(res) + "\n")
	else:
		debug_print_line(get_usage(command[0]))

#   setprop: set the value of a named property of the present working node
func command_setprop(command):
	if command.size() > 1:
		var prop = command[1].split(' ', true, 1)
		if prop.size() > 1 && prop[0].is_valid_identifier():
			var type = typeof(get_pwn().get(prop[0]))
			var variant = string_to_variant(prop[1], type)
			if typeof(variant) > TYPE_NIL:
				get_pwn().set(prop[0], string_to_variant(prop[1], type))
	else:
		debug_print_line(get_usage(command[0]))

#   history: print the command history
func command_history(_command):
	var lnum = 0
	for line in history:
		if line:
			debug_print_line("%2d: %s\n" % [lnum, line])
			lnum += 1
	#debug_print_line("history_pos = " + String(history_pos) + "\n")

#   perf: Print the value of a Godot Engine performance counter
func command_perf(command):
	if command.size() > 1:
		var stat = perf(command[1])
		if stat:
			debug_print_line("%s\n" % String(stat))
		else:
			debug_print_line("null\n")
	else:
		debug_print_line(get_usage(command[0]))

#   script: run a script from user://scripts/
func command_script(command):
	var script = []
	if (command.size() > 1):
		var path = "user://scripts/" + command[1]
		var f = File.new()
		var err = f.open(path, File.READ)
		if err == OK:
			# Read the file
			while not f.eof_reached():
				script.push_back(f.get_line())
			f.close()
			# Save state and turn off echo
			var state = {"echo": echo,
						 "pwn": present_working_node,
						 "history_pos": history_pos,
						 "history": history,
						 "expression": expression,
						 "cheats": cheats}
			echo = false
			# Execute the script
			for cmd in script:
				cmd = cmd.split(' ', true, 1)
				execute_command(cmd)
			# Restore state
			echo = state["echo"]
			present_working_node = state["pwn"]
			history_pos = state["history_pos"]
			history = state["history"]
			expression = state["expression"]
			cheats = state["cheats"]
		else:
			debug_print_line("File not found: " + command[1] + "\n")
	else:
		debug_print_line(get_usage(command[0]))

#   echo: enable and disable echoing commands and their outputs to the terminal
func command_echo(command):
	if command.size() > 1:
		echo = string_to_variant(command[1], TYPE_BOOL)
	else:
		debug_print_line(get_usage(command[0]))

#   cheat: Disable cheats, or enable them if you say the magic word
func command_cheat(command):
	# check if there's more than one input to the command:
	if command.size() > 1:
		# hash the password
		var code = command[1].sha256_text()
		if code == cheat_code:
			debug_print_line("Cheats enabled.\n")
			cheats = true
			return
		debug_print_line("Ah ah ah, you didn't say the magic word!\n")
	cheats = false
	debug_print_line("Cheats disabled.\n")
	pass

# look-up table for performance monitor -> index pairs
# See https://docs.godotengine.org/en/stable/classes/class_performance.html
const monitor_lookup = {
	# Time
	"time:fps": 0,
	"time:process": 1,
	"time:physics process": 2,
	# Memory
	"memory:static": 3,
	"memory:dynamic": 4,
	"memory:static max": 5,
	"memory:dynamic max": 6,
	"memory:message buffer max": 7,
	# Objects
	"object:count": 8,
	"object:resource count": 9,
	"object:node count": 10,
	"object:orphan node count": 11,
	# Render
	"render:objects in frame": 12,
	"render:vertices in frame": 13,
	"render:material changes in frame": 14,
	"render:shader changes in frame": 15,
	"render:surface changes in frame": 16,
	"render:draw calls in frame": 17,
	"render:2d items in frame": 18,
	"render:2d draw calls in frame": 19,
	"render:video memory used": 20,
	"render:texture memory used": 21,
	"render:vertex memory used": 22,
	"render:total video memory used": 23,
	# Physics2D
	"physics2d:active objects": 24,
	"physics2d:collision pairs": 25,
	"physics2d:island count":26,
	# Physics3D
	"physics3d:active objects": 27,
	"physics3d:collision pairs": 28,
	"physics3d:island count": 29,
	# Audio
	"audio:output latency": 30
}

# Get a performance counter given a string
func perf(attribute):
	if attribute.is_valid_integer():
		return Performance.get_monitor(int(attribute))
	if attribute in monitor_lookup:
		return Performance.get_monitor(monitor_lookup[attribute.to_lower()])
	# Shortcut to popular counters
	match attribute.to_lower():
		"fps":
			return Performance.get_monitor(Performance.TIME_FPS)
		"proctime":
			return Performance.get_monitor(Performance.TIME_PROCESS)
		"objects":
			return Performance.get_monitor(Performance.OBJECT_COUNT)
		"nodes":
			return Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
		"resources":
			return Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)
	return ""

#   empty: No command
func command_empty(_command):
	pass
