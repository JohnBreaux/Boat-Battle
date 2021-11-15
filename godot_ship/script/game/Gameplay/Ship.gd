extends Node2D

# This is the rendered element of a "ship", generated when the game transitions from the placing state to the gameplay state

# Enum denoting the orientation (X is 0, Y is 1)
enum Orientation {X = 0, Y = 1}
enum  {MISS = -1, READY = 0, HIT = 1, SUNK = 2}

# Size of ship in board units
var size
var health
# Coordinates of ship's center. Ship extends [-(size-1 >> 1), (size/2 >> 1)]
var boardposition = Vector2(-1,-1)
# Variable storing whether the ship is sunk, for rendering purposes
var sunk = false
# Orientation of the ship (see enum Orientation)
var orientation = Orientation.Y
# array of spots thats been hit
var hits = []
# Variable storing the positions of each piece of the ship
var extents = []

# Ship sprite metadata
#   atlas: the texture atlas containing all ship parts
var atlas = preload("res://assets/game/TextureAtlas.png")
#   sprites: the individual sprite nodes which make up the ship
var sprites = []
#   variant: Ships of the same length can have different textures
#     variant A is 0, variant B is 1, ...
var variant = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# member functions:
#   getShip():
func get_ship():
	return [boardposition, size, orientation, variant]

#   getSunk: get whether the ship is sunk
func get_sunk():
	return sunk

func hit(pos):
	# Assume the opponent missed
	var res = MISS
	# Find the position in the extents
	var index = extents.find(pos)
	# If that position exists:
	if (index > -1):
		# Hit the ship piece at that location
		hits[index] = true
		res = HIT
		# Decrement its health
		health -= 1
	# If there's no more health,
	if health == 0:
		# Sink the ship.
		set_sunk()
		res = SUNK
	return res

# update: (re)calculates extents and textures
func update():
	# Calculate the extents (shouldn't change)
	extents = get_extent()
	# Update the textures
	for i in size:
		texture(i)

# returns an array of the positions that the ship occupies
func get_extent():
	var extent = []
	# Find each tile of the ship
	for i in size:
		# Calculate the x axis position
		var x = boardposition.x - (1 - orientation) * ( (size - 1) / 2 - i )
		# Calculate the y axis position
		var y = boardposition.y - orientation * ( (size - 1) / 2 - i )
		# Append the point onto the array
		extent.push_back(Vector2(x,y))
	return extent

# Update textures
func texture(index):
	var state = 0 # ready
	if(hits[index]):
		state = 1 # hit
	var textureSize = 32
	# It's okay to create a new texture every time, as resources are refcounted
	var t = AtlasTexture.new()
	t.set_atlas(atlas)
	t.margin = Rect2(0, 0, 32, 32)
	t.region = Rect2(
		(size * variant + index) * textureSize,
		#(size * textureSize) * variant + (32 * index),
		(size - 2) * textureSize * 2 + (32 * state),
		textureSize,
		textureSize
	)
	# Create a new Sprite to house the texture, or use the existing sprite
	var sprite = sprites[index]
	if sprite == null:
		sprite = Sprite.new()
	sprite.texture = t
	# This is relative to the ship
	#   (index + 1)        => Index, but 1-based
	#   (floor((size-1)/2) => Offset from edge to 'center' of ship
	#   Vector2(0.5,0.5)   => Center the texture on the axis of rotation
	#   32                 => Converts from board-units to pixels
	sprite.position = Vector2((index + 1) - (floor((size-1)/2) + 0.5), 0.5) * textureSize
	sprite.rotation = 0
	# Add the sprite to the "sprites" group, persistently
	sprite.add_to_group("Ship Sprites", true)
	# Add the sprite node to an array so it can be modified later, unless it's already there
	if not sprites[index]:
		sprites[index] = sprite
		add_child(sprite)

#   setSunk: sink the ship
func set_sunk():
	sunk = true

#   _init: called on object initialization. Accepts args if called via <Ship>.new(...)
#     in_position: position of the ship, in board-coordinates; (0,0) by default
#     in_size: size of the ship, in board-units; 2 by default
#     in_orientation: orientation of the ship (see enum Orientation); vertical by default
#     in_variant: Which ship is this?
func _init(in_position = Vector2(0,0), in_size = 0, in_orientation = Orientation.Y, in_variant = 0):
	# Set the ship's positions
	boardposition = in_position
	position = boardposition * 32
	# Set the ship's size and health
	size = in_size
	health = size
	# Set the ship's orientation/rotation
	orientation = in_orientation
	rotation = orientation * PI/2
	# Set the ship's variant(A, B, ... )
	variant = in_variant
	# Resize the size-based arrays
	hits.resize(in_size)
	sprites.resize(in_size)
	# Update the extents and draw the textures
	update()
