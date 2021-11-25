extends Node2D

# Path to Ship class, for instantiating new Ships in code
var Ship = preload("res://scenes/Game/Ship.tscn")

# Consts and enums
const NO_SHIP = -1
enum  {MISS = -1, READY = 0, HIT = 1, SUNK = 2, LOST = 3}

var bottom_board:Array # Player board
var top_board:Array    # Opponent board
var ships = []         # list of Ships
var ship_data = []     # Data used to generate ships
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
	# If the ship's already been hit here, don't bother beating it again
	if ship[1] != READY:
		return ship[1]
	if ship[0] > NO_SHIP:
		# Decide whether HIT or SUNK
		res = ships[ship[0]].hit(pos)
	# If ship sunk,
	if res == SUNK:
		# remove it from the count
		ship_count -= 1
	# If we have no more ships left, we LOST
	if ship_count == 0:
		res = LOST
	# Record the result on the board, and return it
	ship[1] = res
	return res

# fire: Store the results of firing on an opponent
#   pos: board position fired on
#   res: result of firing on the opponent
func fire(pos, res):
	if top_board[pos.x][pos.y] == READY:
		top_board[pos.x][pos.y] = res
		return res
	else:
		return top_board[pos.x][pos.y]

# Place a ship on the board at board-space coordinates
func place_ship(in_position, in_size, in_orientation, in_variant = 0):
	# Save the ship data
	ship_data.append([in_position, in_size, in_orientation])
	# Create a new Ship, and give it some data
	var ship = Ship.instance()
	ship._init(in_position, in_size, in_orientation, in_variant)
	# Mark the ship on the board
	for pos in ship.get_extent():
		bottom_board[pos.x][pos.y] = [ships.size(), READY]
	# Add the ship to the ships array, and keep count
	ships.append(ship)
	ship_count += 1
	# Add the ship to the scene tree
	add_child(ship)


func query_bottom(pos):
	return bottom_board[pos.x][pos.y]

func query_top(pos):
	return top_board[pos.x][pos.y]

# Get the number of live ships
func get_ship_count():
	return ship_count

# _init: Constructor
func _init():
	# Initialize the bottom_board to a len*len array
	for x in board_len:
		bottom_board.append([])
		for y in board_len:
			bottom_board[x].append([NO_SHIP, READY])
	# Initialize the top_board to a len*len array
	for x in board_len:
		top_board.append([])
		for y in board_len:
			top_board[x].append(READY)

#   worldspace_to_boardspace: convert a Vector2 in world-space to board-space
func worldspace_to_boardspace(coordinate:Vector2):
	# subtract 36 to get the position relative to (0,0) on the board, and integer divide by 32
	return Vector2(int(coordinate.x - 36) >> 5, int(coordinate.y-36) >> 5)
