extends Control

# Declare member variables here.
var debug_canvas
var debug_transform

var debug_active = false
var menu_position = 0.0
var menu_velocity = 2

# positions when the menu is hidden/active
var menu_hidden = Transform2D(Vector2(1,0), Vector2(0,1), Vector2(0,-180))
var menu_active = Transform2D(Vector2(1,0), Vector2(0,1), Vector2(0,   0))

# Called when the node enters the scene tree for the first time.
func _ready():
	debug_canvas = get_node("debug_canvas")
	debug_transform = debug_canvas.get_transform()

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



func _on_LineEdit_text_entered(new_text):
	
	pass # Replace with function body.
