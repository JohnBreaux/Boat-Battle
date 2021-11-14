extends Control

# This is the rendered element of a "ship", generated when the game transitions from the placing state to the gameplay state

# Enum denoting the orientation (X is 0, Y is 1)
enum Orientation {X = 0, Y = 1}

# Size of ship in board units
var size
# Coordinates of ship's center. Ship extends [-(size-1 >> 1), (size/2 >> 1)]
var position
# Variable storing whether the ship is sunk, for rendering purposes
var sunk = false
# Orientation of the ship (see enum Orientation)
var orientation = Orientation.Y

# Ship sprite metadata
#   sprite: the texture atlas containing all ship parts
var atlas # = TODO: figure out how to use one sprite for multiple textures
#   texture: the offset into the texture atlas of the first part of the ship.
var texture = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# member functions:
#   getSize: get the size of the ship, in board-units (2 for 2-ship, 3 for 3-ship, ...)
func getSize():
	return size

#   getPosition: get the position of the ship's center, in board units
func getPosition():
	return position

#   getOrientation: get the orientation of the ship (see enum Orientation)
func getOrientation():
	return orientation

#   getSunk: get whether the ship is sunk
func getSunk():
	return sunk

func getExtent():
	var extent = []
	#vertical orientation
	if orientation == 1:
		for i in size:
			var pos
			pos.x = position.x
			pos.y = position.y - ((size - 1) / 2) + i
			extent.append(pos)
	#horizontal orientation
	if orientation == 0:
		for i in size:
			var pos
			pos.x = position.x - ((size - 1) / 2) + i
			pos.y = position.y
			extent.append(pos)
	print(extent)
	return extent
#   setSunk: sink the ship
func setSunk():
	sunk = true

#   _init: called on object initialization. Accepts args if called via <Ship>.new(...)
#     in_position: position of the ship, in board-coordinates; (0,0) by default
#     in_size: size of the ship, in board-units; 2 by default
#     in_orientation: orientation of the ship (see enum Orientation); vertical by default
func _init(in_position = Vector2(0,0), in_size = 2, in_orientation = Orientation.Y):
	position = in_position
	size = in_size
	orientation = in_orientation
