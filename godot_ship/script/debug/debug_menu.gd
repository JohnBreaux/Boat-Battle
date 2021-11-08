extends Control


var debug_canvas

var debug_active = false
var menu_position = 0.0
var menu_velocity = 4

var history = []
var history_pos = 0

onready var expression = Expression.new()

# helptext: args list and help blurb accessed by function name
var helptext = {
#	command_id               [args                 "Help text"                                                ]
	"command_help":          [" [command]",        "Print information about command.\n"                       ],
	"command_history":       ["",                  "Print the history log.\n"                                 ],
	"command_perf":          [" stat",             "Print performance info (fps, nodes, proctime, ... )\n"    ],

	"command_list":          [" [path]",           "List children of path, or of present working node.\n"     ],
	"command_start":         [" filename",         "Load PackedScene filename.tscn as child.\n"               ],
	"command_kill":          [" name",             "Kill child node with matching name.\n"                    ],

	"command_pwd":           ["",                  "Print the Present Working Node.\n"                        ],
	"command_cd":            [" path",             "Change the Present Working Node to path.\n"               ],

	"command_print":         [" string",           "Print string to the in-game debug console.\n"             ],
	"command_clear":         ["",                  "Clear the debug output.\n"                                ],
#	!EXTREMELY DANGER {
	"command_emit":          [" signal [message]", "Emit a message on MessageBus.signal without validation.\n"],
	"command_call":          [" func [args ...]",  "Call func(...) with arguments args.\n"                    ],
	"command_exec":          [" expression ...",   "Evaluate an arbitrary expression, and print the result.\n"],
#	}
	"command_listprops":     ["",                  "List properties of the Present Working Node\n"            ],
	"command_getprop":       [" prop",             "Get the value of property prop\n"                         ],
	"command_setprop":       [" prop value",       "Set the property prop to value.\n"                        ],

	"command_restart":       ["",                  "Kill the current scene tree and plant a new Root.\n"      ],
	"command_exit":          ["",                  "Quits the program.\n"                                     ],

	"command_empty":         ["",                  "No Operation.\n"                                          ],
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

	["restart", "killall"]:         "command_restart",
	["exit", "quit"]:               "command_exit",

	[""]:                           "command_empty"
}

#List of all of Godot's builtin types
var types = ["nil", "bool","int","float","String","Vector2","Rect2",
			 "Vector3","Transform2D","Plane","Quat","AABB","Basis","Transform",
			 "Color","NodePath","RID","Object","Dictionary","Array","PoolByteArray",
			 "PoolIntArray","PoolRealArray","PoolStringArray","PoolVector2Array",
			 "PoolVector3Array","PoolColorAray"]

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
	command_help([""])
	debug_print_line("> ")

#   _process: Called every frame. Controls slide-in animation and focus-grabbing
#     params: delta: elapsed time
#     returns: void
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

# Signal-processing functions:
#   _on_LineEdit_text_entered: process incoming text line
#     params: line: Line of text entered by user
#     returns: void
func _on_LineEdit_text_entered(line):
	if line != "":
		history_append(line)
	emit_signal("clear_in")
	debug_print_line(line + "\n")
	var command = line.split(' ', true, 1)
	var command_func = parse(command[0])
	if command_func:
		call(command_func, command)
	else:
		debug_print_line("dbg: command not found: " + command[0] + "\n")
	debug_print_line("> ")

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
	emit_signal("print_text", string.c_unescape())

#   complete_path: complete a relative or absolute path, and returns the node it refers to
#     params: path: relative or absolute path to a node
#     returns: void
func complete_path(path):
	if path.is_rel_path(): # convert to absolute path
		path = String(present_working_node.get_path()) + "/" + path
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
	return "Usage: " + alias + helptext[parse(alias)][0] + "\n"

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
				"true", "1", "ok":
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
			debug_print_line("No cast from String to " + types[typeof(type)] + "\n")
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

# Commands. All commands take in a parameter called command,
# which contains a partially tokenized command
#   start: Loads scene from res://scenes/*.tscn by filename, and starts it
func command_start (command):
	if command.size() > 1:
		var pack = load("res://scenes/" + command[1] + ".tscn");
		present_working_node.add_child(pack.instance());
		debug_print_line("started '" + command[1] + "'\n")
	else:
		debug_print_line(get_usage(command[0]))

#   stop: kills a child of current working node
func command_kill (command):
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
		debug_print_line(get_usage(command[0]))

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
	if command.size() > 1:
		var mbus_signal = command[1].split(' ', true, 1)
		match mbus_signal.size():
			2:
				debug_print_line("Message: " + String(mbus_signal) + "\n")
				MessageBus.emit_signal(mbus_signal[0], mbus_signal[1])
			1:
				debug_print_line("Message: " + String(mbus_signal) + "\n")
				MessageBus.emit_signal(mbus_signal[0])
			0: debug_print_line(get_usage(command[0]))
	else:
		debug_print_line(get_usage(command[0]))

#   clear: clears the debug output
func command_clear (_command):
	emit_signal("clear_out");

#   pwd: print the present working node's path
func command_pwd (_command):
	debug_print_line(String(present_working_node.get_path()) + "\n")

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
			debug_print_line(key[0] + " ")
		debug_print_line("\n")
	else:
		var command_func = parse(command[1])
		var aliases
		var text
		if command_func in helptext:
			text = helptext[command_func]
			aliases = lookup(command[1])
			debug_print_line(command[1] + text[0] + ":\n  Aliases: " + String(aliases) + "\n  "+ text[1])
		else:
			debug_print_line(get_canonical(command[0]) + ": command not found: " + command[1] + "\n")

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
		if present_working_node.has_method(call_cmd[0]):
			call_ret = present_working_node.callv(call_cmd[0], call_args)
		else:
			debug_print_line("We're sorry, but your call could not be completed as dialed.\n"
			+ "Please hang up and try your call again.\n")
			return
		debug_print_line(variant_to_string(call_ret) + "\n")
	else:
		debug_print_line(get_usage(command[0]))

#   exec: execute an arbitrary GDScript expression as present working node
func command_exec(command):
	if command.size() > 1:
		var res
		var err = expression.parse(command[1])
		if err == OK:
			res = expression.execute([], present_working_node, false);
			if expression.has_execute_failed():
				debug_print_line(command[0] + ": command not found: " + command[1])
				res = ""
		else:
			res = expression.get_error_text()
		debug_print_line(variant_to_string(res) + "\n")
	else:
		debug_print_line(get_usage(command[0]))

#   listprops: list properties (variables) of present working node
func command_listprops(_command):
	var proplist = present_working_node.get_property_list()
	debug_print_line(String(proplist) + "\n")
	pass

#   getprop: get the value of a named property of the present working node
func command_getprop(command):
	if command.size() > 1 && command[1].is_valid_identifier():
		var res = present_working_node.get(command[1])
		debug_print_line(variant_to_string(res) + "\n")
	else:
		debug_print_line(get_usage(command[0]))

#   setprop: set the value of a named property of the present working node
func command_setprop(command):
	if command.size() > 1:
		var prop = command[1].split(' ', true, 1)
		if prop.size() > 1 && prop[0].is_valid_identifier():
			var type = typeof(present_working_node.get(prop[0]))
			var variant = string_to_variant(prop[1], type)
			if typeof(variant) > TYPE_NIL:
				present_working_node.set(prop[0], string_to_variant(prop[1], type))
	else:
		debug_print_line(get_usage(command[0]))

#   history: print the command history
func command_history(_command):
	var lnum = 0
	for line in history:
		if line:
			debug_print_line(String(lnum) + ": " + line + "\n")
			lnum += 1
	#debug_print_line("history_pos = " + String(history_pos) + "\n")

#   perf: Print the value of a Godot Engine performance counter
func command_perf(command):
	if command.size() > 1:
		var stat = perf(command[1])
		if stat:
			debug_print_line(String(stat) + "\n")
		else:
			debug_print_line("null\n")
	else:
		debug_print_line(get_usage(command[0]))

func perf(attribute):
	if attribute.is_valid_integer():
		return Performance.get_monitor(int(attribute))
	match attribute:
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
