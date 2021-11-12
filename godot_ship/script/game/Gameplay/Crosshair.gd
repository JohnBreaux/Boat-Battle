extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var snapped = false #when snapped if true crosshair stops following mouse

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if snapped == false:
		position += (get_global_mouse_position() - position)/10

func _input(event):
	#Check if left click is being clicked and the sprite is visible (i.e only checks for inputs after ship positions are confirmed)
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and visible == true:
		#Locks the position of the crosshair with left click
		snapped = true
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and visible == true:
		#Unlocks the position of the crosshair with right click
		snapped = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
