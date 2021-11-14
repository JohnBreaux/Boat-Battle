extends Control

# This is the rendered element of a "ship", generated when the game transitions from the placing state to the gameplay state

# Enum denoting the orientation (X is 0, Y is 1)
enum Orientation {X = 0, Y = 1}

# Size of ship in board units
var size
# Coordinates of ship's center. Ship extends [-(size-1 >> 1), (size/2 >> 1)]
var boardposition
# Variable storing whether the ship is sunk, for rendering purposes
var sunk = false
# Orientation of the ship (see enum Orientation)
var orientation = Orientation.Y
# array of spots thats been hit
var hit = []

# Ship sprite metadata
#   sprite: the texture atlas containing all ship parts
var atlas # = TODO: figure out how to use one sprite for multiple textures
#   variant: for ship 3. A is 0, B is 1
var variant = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# member functions:
#   getSize: get the size of the ship, in board-units (2 for 2-ship, 3 for 3-ship, ...)
func getSize():
	return size

#   getPosition: get the position of the ship's center, in board units
func getPosition():
	return boardposition

#   getOrientation: get the orientation of the ship (see enum Orientation)
func getOrientation():
	return orientation

#   getSunk: get whether the ship is sunk
func getSunk():
	return sunk

# returns an array of the positions that the ship occupies
func getExtent():
	var extent = []
	#vertical orientation
	if orientation == 1:
		for i in size:
			var pos
			pos.x = boardposition.x
			pos.y = boardposition.y - ((size - 1) / 2) + i
			extent.append(pos)
	#horizontal orientation
	if orientation == 0:
		for i in size:
			var pos
			pos.x = boardposition.x - ((size - 1) / 2) + i
			pos.y = boardposition.y
			extent.append(pos)
	print(extent)
	return extent
	
# generates a texture at the spot (index should start at 0)
func texture(index):
	var state = 0 # floating
	if(hit[index]):
		state = 1 # sunk
	var textureSize = 32
	var t = AtlasTexture.new()
	t.atlas = load("res://assets/game/TextureAtlas.png")
	t.region (
		(size * textureSize) * variant + (32 * index),
		(size - 2) * textureSize * 2 + (32 * state),
		textureSize,
		textureSize
	)
	
	pass
	
#   setSunk: sink the ship
func setSunk():
	sunk = true

#   _init: called on object initialization. Accepts args if called via <Ship>.new(...)
#     in_position: position of the ship, in board-coordinates; (0,0) by default
#     in_size: size of the ship, in board-units; 2 by default
#     in_orientation: orientation of the ship (see enum Orientation); vertical by default
func _init(in_position = Vector2(0,0), in_size = 2, in_orientation = Orientation.Y):
	boardposition = in_position
	size = in_size
	orientation = in_orientation
