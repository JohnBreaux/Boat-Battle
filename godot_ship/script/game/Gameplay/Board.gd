extends Node2D

# Path to Ship class, for instantiating new Ships in code
onready var Ship = load("res://script/game/Gameplay/Ship.gd")

# Consts and enums
const NO_SHIP = -1
enum  {MISS = -1, READY = 0, HIT = 1, SUNK = 2}

var bottom_board:Array # Player board
var top_board:Array    # Opponent board
var ships = []         # list of Ships
var ship_count = 0     # number of 'active' (un-sunk) ships

# a board is square. This is its side length
var board_len = 10

# The top board must be marked by textures. This is where they are stored:
var sprites = []

# Here are where the hit/miss textures are loaded, so that they may be used:
var hit_texture = preload("res://assets/game/Hit.png")
var miss_texture = preload("res://assets/game/Miss.png")


# TODO: What state?
func get_state():
	pass

# Evaluate being hit by an opponent
#   pos: board position opponent fired at
func hit(pos):
	var res = MISS
	# Get the ship-metadata for that location
	var ship = bottom_board[pos.x][pos.y]
	# If there's a ship there, which exists, and hasn't been hit,
	if ship and ship[0] > NO_SHIP and ship[1] == READY:
		# Hit the ship, and store whether HIT or SUNK
		res = ships[ship[0]].hit(pos)
		# TODO: display KABOOM
		# Update the ship
		ships[ship[0]].update()
		# Mark the ship as hit
		ship[1] = HIT
	else:
		# Mark that position as a miss, with no ship
		bottom_board[pos.x][pos.y] = [NO_SHIP, MISS]
	# If ship sunk,
	if res == SUNK:
		# remove it from the count
		ship_count -= 1
	return res

# fire: Store the results of firing on an opponent
#   pos: board position fired on
#   res: result of firing on the opponent
func fire(pos, res):
	if top_board[pos.x][pos.y] == null:
		top_board[pos.x][pos.y] = res
		return true
	return false

# Place a ship on the board at board-space coordinates
func place_ship(in_position, in_size, in_orientation, in_variant = 0):
	var ship = Ship.new(in_position, in_size, in_orientation, in_variant)
	for pos in ship.get_extent():
		bottom_board[pos.x][pos.y] = [ships.size(), READY]
	ships.append(ship)
	ship_count += 1
	add_child(ship)

# Not sure why this is necessary yet
func get_bottom_board():
	return bottom_board

# Get the number of live ships
func get_ship_count():
	return ship_count

# _init: Constructor
func _init():
	# Initialize the bottom_board to a 10x10 array
	for _row in range(board_len):
		bottom_board.append([])
	for column in bottom_board:
		column.resize(10)
	# Initialize the top_board to a 10x10 array
	for _row in range(board_len):
		top_board.append([])
	for column in top_board:
		column.resize(board_len)

#   worldspace_to_boardspace: convert a Vector2 in world-space to board-space
func worldspace_to_boardspace(coordinate:Vector2):
	# subtract 36 to get the position relative to (0,0) on the board, and integer divide by 32
	return Vector2(int(coordinate.x - 36) >> 5, int(coordinate.y-36) >> 5)
