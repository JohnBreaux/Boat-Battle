extends Node

# Path to Ship class, for instantiating new Ships in code
onready var Ship = load("res://script/game/Gameplay/Ship.gd")

var bottom_board # Player board
var top_board    # Opponent board
var ships       # list of Ships
var ship_count   # number of 'active' (un-sunk) ships

# a board is square. This is its side lengths
var board_len = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	ships = []
	ship_count = 0

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
	return ship_count

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

# Coordinates of ship's center. Ship extends [-(size-1 >> 1), (size/2 >> 1)]
func shiptoboard(ship:Ship):
	for i in range (ship.)
	pass
