extends Node

class ShipData:
	var Coor: Vector2
	var Length: int
	var Orientation: bool #vertical is true, (Trueship = vertical) (Falseship = horizontal)

var light_theme = load("res://light_theme.tres")
var dark_theme = load("res://dark_theme.tres")

# Preloaded assets, to be used later
# TODO: Move Setup into the Player. It's just here, for now, so that it can be tested and the game doesn't appear broken
onready var Setup = preload("res://scenes/Game/Setup.tscn")
# TODO: Move Fire into the Player. See above.
onready var Fire  = preload("res://scenes/Game/Fire.tscn")

# Path to Player class, for instantiating new Players in code
onready var Player = preload("res://scenes/Game/Player.tscn")

onready var Victory = preload("res://scenes/Game/Victory.tscn")


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
	# TODO: Move Setup into the Player.
	var setup = Setup.instance()
	setup.connect("game_ready", self, "game_setup")
	add_child(setup)
	
	get_node("ConfirmationDialog").get_ok().text = "Yes"
	get_node("ConfirmationDialog").get_cancel().text = "No"
	get_node("ConfirmationDialog").get_ok().rect_min_size.x = 100
	get_node("ConfirmationDialog").get_cancel().rect_min_size.x = 100
	
	var _errno = 0;
	_errno += OptionsController.connect("change_theme", self, "_on_change_theme")
	_on_change_theme(OptionsController.get_theme())

# TODO: Move Setup into the Player.
func game_setup(_ships):
	print_debug("Congrats! Setup complete.")
	# TODO: Move Fire into the Player.
	add_child(Fire.instance())

# Member functions:
#   game_start: starts the game
func game_start():
	pass

#   victory_screen: display the victory screen
func victory_screen():
	# TODO: Create the victory screen, fill it with knowledge
	pass

#   display_turn(): display which turn it is on the screen
func display_turn():
	# TODO: Update the turn display, if there is one?
	pass

func _on_Forfeit_pressed():
	AudioBus.emit_signal("button_clicked")
	get_node("ConfirmationDialog").popup()

func end():
	queue_free()

func _on_Button_button_down():
	AudioBus.emit_signal("button_clicked")
	var victory = Victory.instance()
	add_child(victory)
	victory.connect("exit_main", self, "end")

func _on_ConfirmationDialog_confirmed():
	end()

func _on_change_theme(theme):
	if theme == "light":
		get_node("Buttons").set_theme(light_theme)
	elif theme == "dark":
		get_node("Buttons").set_theme(dark_theme)
