extends Node

# Path to Player class, for instantiating new Players in code
var Player = "res://script/game/Gameplay/Player.gd"

var players # = player1, player2, ...
var turnCount = 0
var wasHit = false
var isMultiplayer = false

# Called when the node enters the scene tree for the first time.
func _ready():
	gameStart()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func gameStart():
	pass
	
func victoryScreen():
	pass
	
func displayTurn():
	pass
