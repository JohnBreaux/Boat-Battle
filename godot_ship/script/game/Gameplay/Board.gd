extends Node

# Path to Ship class, for instantiating new Ships in code
onready var Ship = load("res://script/game/Gameplay/Ship.gd")

var bottom_board # Player board
var top_board    # Opponent board
var ships       # list of Ships
var ship_count   # number of 'active' (un-sunk) ships

# Called when the node enters the scene tree for the first time.
func _ready():
	ships = []
	shipCount = 0

# TODO: What state?
func getState():
	pass

# Place a ship on the board at board-space coordinates
func placeShip(in_position, in_size, in_orientation):
	ships.append(Ship.new(in_position, in_size, in_orientation))
	pass

func getBottomBoard():
	pass

func getShipCount():
	pass

func _init():
	# Initialize the bottom_board to a 10x10 array
	for i in range(10):
		bottom_board.append([])
		for _i in range(0, 10):
			bottom_board[i].resize(10)
	# Initialize the top_board to a 10x10 array
	for i in range(10):
		top_board.append([])
		for _i in range(0, 10):
			top_board[i].resize(10)

#   worldspace_to_boardspace: convert a Vector2 in world-space to board-space
func worldspace_to_boardspace(coordinate:Vector2):
	# subtract 36 to get the position relative to (0,0) on the board, and integer divide by 32
	return Vector2(int(coordinate.x - 36) >> 5, int(coordinate.y-36) >> 5)
