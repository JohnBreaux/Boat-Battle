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

func _unhandled_input(event):
	if event.is_action_pressed("ui_debug"):
		# open debug menu
		debug_active = !debug_active;

func _on_LineEdit_text_entered(line):
	var command = line.split(' ', true, 1)
	if command.size() > 0:
		print("match ", command)
		match command[0]:
			"open":
				if command.size() > 1:
					MessageBus.emit_signal("change_scene", command[1])
				else:
					debug_print_line("Usage: open scene")
			"kill":
				if command.size() > 1:
					MessageBus.emit_signal("kill_scene", command[1])
				else:
					debug_print_line("Usage: kill scene")
			"restart":
				MessageBus.emit_signal("return_to_title")
	else:
		pass

func debug_print_line(string):
	debug_output.set_line(debug_line, string)
	debug_line += 1
