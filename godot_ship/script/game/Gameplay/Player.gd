extends Node

# Path to Board class, for instantiating new Boards in code
var Board = preload("res://scenes/Game/Board.tscn")

# Preloaded assets, to be used later
# TODO: Move Setup into the Player. It's just here, for now, so that it can be tested and the game doesn't appear broken
var Setup = preload("res://scenes/Game/Setup.tscn")
# TODO: Move Fire into the Player. See above.
var Fire  = preload("res://scenes/Game/Fire.tscn")

signal player_ready


# Player ID of this player
var pid
# board (an instance of the Board class)
onready var board = Board.instance()

# Called when the node enters the scene tree for the first time.
func _ready():
	var setup = Setup.instance()
	setup.connect("board_ready", self, "set_up")
	add_child(setup)

# Member functions:
#   hit: Called when opponent fires on us.
#     Update internal state, and return bool hit/miss, hit = true, miss = false
func hit(pos):
	var res = board.hit(pos)
	if res == -1:
		return true
	else:
		return false
	pass

#   place_ship: called when ships are placed.
#     forwards Ship locations to the Board, so that it may construct a ship
#     ship: a list of ship properties {position, orientation, size, variant}
func place_ship(pos, size, orientation, variant):
	board.place_ship(pos, size, orientation, variant)

#   setUp: set up the board given the placed ship locations
#     translates the ship positions in the Setup UI to board-space, then places each ship
#     ships: a list of lists of ship properties [[position, orientation, size, variant], ...]
func set_up(ships):
	# Place all the ships
	for i in ships:
		place_ship(i[0], i[1], i[2], i[3])
	emit_signal("player_ready")
	# Add the board to the tree
	add_child(board)

#   turnStart: start player's turn
#     Initiates the player's turn, and blocks until the player selects a location to fire upon
#     returns: fire = [player id, target coordinates]
func turnStart():
	# TODO: Yielf until Fire return
	add_child(Fire.instance())
	var player_id = 0
	var target = Vector2(0,0)
	return [player_id, target]
	pass

#   getBoard: returns the player's board
#     returns: board
func getBoard():
	return board

#   forfeit: ends game for player
#     Sinks all ships
#		hits every single board tile
func forfeit():
	for i in 10:
		for j in 10:
			var pos
			pos.x = i
			pos.y = j
			hit(pos)

#   getShipCount: get the number of ships the player has left alive
func getShipCount():
	var count = board.get_ship_count()
	return count
	pass

