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
signal clear_line
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
	emit_signal("clear_line")
	debug_print_line("")
	var command = line.split(' ', true, 1)
	if command.size() > 0:
		match command[0]:
			"start":
				if command.size() > 1:
					MessageBus.emit_signal("change_scene", command[1])
					debug_print_line("start '" + command[1] + "'\n".c_unescape())
				else:
					debug_print_line("Usage: start scene")
			"kill":
				if command.size() > 1 and command[1] != "Debug":
					MessageBus.emit_signal("kill_scene", command[1])
					debug_print_line("kill '" + command[1] + "'\n".c_unescape())
				else:
					debug_print_line("Usage: kill scene")
			"restart":
				MessageBus.emit_signal("return_to_title")
			"print":
				if command.size() > 1:
					debug_print_line(command[1].c_unescape())
			"raw_emit":
				var mbus_signal = command[1].split(' ', true, 1)
				match mbus_signal.size():
					2: MessageBus.emit_signal(mbus_signal[0], mbus_signal[1])
					1: MessageBus.emit_signal(mbus_signal[0])
					0: debug_print_line( "Usage: raw_emit signal [value]\n")
			_:
				debug_print_line("BY YOUR COMMAND.\n")

func debug_print_line(string):
	emit_signal("print_text", string.c_unescape())
