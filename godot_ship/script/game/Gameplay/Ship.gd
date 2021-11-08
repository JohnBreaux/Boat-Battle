extends Node

# This is the rendered element of a "ship", auto-generated when 

var size = 0 # Size of ship in units
var position # Coordinates of ship's center. Ship extends [-(size-1 >> 1), (size/2 >> 1)]
var sunk = false
var orientation = false

# index into ship sprite table
var texture = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func getSize():
	return size

func getPosition():
	return position

func getOrientation():
	return orientation
	
func getSunk():
	return sunk

func setSunk():
	sunk = true

func makeShip(in_position, in_size, in_orientation):
	position = in_position
	size = in_size
	orientation = in_orientation
