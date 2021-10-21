extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var held = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var click_radius = 32
var orient = 0;

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if (event.position - position).length() < click_radius:
			if not held and event.pressed:
				held = true;
				
		if held and not event.pressed:
			held = false;
			position = position.snapped(Vector2(32, 32)) + Vector2(2, 2)
			
	if event is InputEventMouseMotion and held:
		position = event.position;
		
	if event.is_action_pressed("ui_rotate"):
		if(event.position - position).length() < click_radius:
			rotate(PI/2);
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func pickup():
	if held:
		return
	mode = RigidBody2D.MODE_STATIC
	held = true

func drop(impulse=Vector2.ZERO):
	if held:
		mode = RigidBody2D.MODE_RIGID
		apply_central_impulse(impulse)
		held = false
