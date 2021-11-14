extends Node

# Path to Board class, for instantiating new Boards in code
var Board = "res://script/game/Gameplay/Board.gd"

# Player ID of this player
var pid
# board (an instance of the Board class)
onready var board = Board.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Member functions:
#   hit: Called when opponent fires on us.
#     Update internal state, and return bool hit/miss
func hit():
	pass

#   place_ship: called when ships are placed.
#     forwards Ship locations to the Board, so that it may construct a ship
#     ship: a list of ship properties {position, orientation, size}
func place_ship(_ship):
	pass

#   setUp: set up the board given the placed ship locations
#     translates the ship positions in the Setup UI to board-space, then places each ship
#     ships: a list of lists of ship properties {{position, orientation, size}, ...}
func set_up(_ships):
	pass

#   turnStart: start player's turn
#     Initiates the player's turn, and blocks until the player selects a location to fire upon
#     returns: fire = [player id, target coordinates]
func turnStart():
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
func forfeit():
	pass

#   getShipCount: get the number of ships the player has left alive
func getShipCount():
	pass

