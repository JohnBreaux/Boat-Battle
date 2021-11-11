extends Node

# Path to Board class, for instantiating new Boards in code
var Board = "res://script/game/Gameplay/Board.gd"

var pid
var board

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#   hit: Called when opponent fires on us.
#     Update internal state, and return bool hit/miss
func hit():
	pass

#   placeShip: called when ships are placed.
#     forwards Ship locations to the Board, so that it may construct a ship
#     ship: a list of ship properties {possition, orientation, size}
func placeShips(_ship):
	pass

#   setUp: set up the board given the placed ship locations
#     translates the ship positions in the Setup UI to board-space, then places each ship
#     ships: a list of lists of ship properties {{position, orientation, size}, ...}
func setUp(_ships):
	pass

#   turnStart: start player's turn
#     Initiates the player's turn, and blocks until the player selects a location to fire upon
#     returns: fire {player, coordinates}
func turnStart():
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

