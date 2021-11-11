extends Node

# Path to Ship class, for instantiating new Ships in code
onready var Ship = load("res://script/game/Gameplay/Ship.gd")

var bottomBoard # Player board
var topBoard    # Opponent board
var ships       # list of Ships
var shipCount   # number of 'active' (un-sunk) ships

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
	for i in range(10):
		bottomBoard.append([])
		for _i in range(0, 10):
			bottomBoard[i].resize(10)
	for i in range(10):
		topBoard.append([])
		for _i in range(0, 10):
			bottomBoard[i].resize(10)

func worldspace_to_boardspace(coordinate:Vector2):
	coordinate -= Vector2(36, 36)
	coordinate /= Vector2(32,32)
	return coordinate
