extends Node

# Path to Player class, for instantiating new Players in code
var Player = "res://script/game/Gameplay/Player.gd"

# Array of instances of the Player class; stores the Players
var players # = player1, player2, ...
# turn counter
var turn = 0
# Variable transporting hit state between players
var hit = false
# Variable tracking whether a game is multiplayer (so that the correct Player type can be spawned)
# TODO: Multiplayer
var is_multiplayer = false

# Called when the node enters the scene tree for the first time.
func _ready():
	game_start()

# Member functions:
#   game_start: starts the game
func game_start():
	pass

#   victory_screen: display the victory screen
func victory_screen():
	pass

#   display_turn(): display which turn it is on the screen
func display_turn():
	pass
