extends Node

# Emitted when the player is ready
signal player_ready


# Preloaded assets, to be used later
# Path to Board class, for instantiating new Boards in code
var Board = preload("res://scenes/Game/Board.tscn")
# Path to Setup menu, so the player may set up their Board
var Setup = preload("res://scenes/Game/Setup.tscn")
# Path to Fire menu, so the player may fire on the opponent
var Fire  = preload("res://scenes/Game/Fire.tscn")

var pid #   Player ID
var board # Board

var fire_at_position # Position to fire at
var opponent_pid     # PID of opponent

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set the player ID according to which network peer ID we are
	pid = int(name)
	board = Board.instance()

remote func set_up_begin():
	var setup = Setup.instance()
	setup.connect("board_ready", self, "set_up")
	add_child(setup)

# Member functions:
#   hit: Called when opponent fires on us.
#     Update internal state, and return hit/miss/sunk
remote func hit(pos):
	var res = board.hit(pos)
	return res

#   mark: Called when the opponent returns hit/miss/sunk
#     Update internal state, return ack/nak
remote func mark(pos, value):
	# Mark the position on the top board
	board.fire(pos, value)

#   place_ship: called when ships are placed.
#     forwards Ship locations to the Board, so that it may construct a ship
#     ship: a list of ship properties {position, orientation, size, variant}
func place_ship(pos, size, orientation, variant):
	board.place_ship(pos, size, orientation, variant)

#   setup: set up the board given the placed ship locations
#     Places each ship onto the board
#     ships: a list of lists of ship properties [[position, orientation, size, variant], ...]
func set_up(ships):
	# Place all the ships
	for i in ships:
		place_ship(i[0], i[1], i[2], i[3])
	# Add the board to the tree
	add_child(board)
	emit_signal("player_ready", pid)

#   turn_start: start player's turn
#     Initiates the player's turn, and blocks until the player selects a location to fire upon
#     returns: fire = [player id, target coordinates]
remote func turn_start():
	print("turn_start")
	var fire = Fire.instance()
	
	add_child(fire)
	yield(fire, "fire_at")
	while not fire_at_position:
		pass
	var player_id = opponent_pid
	var target = fire_at_position
	fire_at_position = null
	return {"id": player_id, "target": target}

#   getBoard: returns the player's board
#     returns: board
func getBoard():
	return board

#   forfeit: ends game for player
#     Sinks all ships
#		Ensures there are no ships left behind
func forfeit():
	for i in 10:
		for j in 10:
			# Hit the board
			hit(Vector2(i, j))

#   getShipCount: get the number of ships the player has left alive
func getShipCount():
	return board.get_ship_count()


func _on_fire_at(pos):
	fire_at_position = pos
