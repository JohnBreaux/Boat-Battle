extends Control

var light_theme = load("res://light_theme.tres")
var dark_theme = load("res://dark_theme.tres")


# Path to Player class, for instantiating new Players in code
var Player = preload("res://scenes/Game/Player.tscn")

var Victory = preload("res://scenes/Game/Victory.tscn")


# Array of instances of the Player class; stores the Players
var players = [] # = player1, player2, ...
var players_ready = []
# turn counter
var turn = 0
# winner
var winner = 0

# Every game is a multiplayer game, even the ones that aren't.
# We're taking the Minecraft approach, baby
var network_id

# Called when the node enters the scene tree for the first time.
func _ready():

	get_node("ConfirmationDialog").get_ok().text = "Yes"
	get_node("ConfirmationDialog").get_cancel().text = "No"
	get_node("ConfirmationDialog").get_ok().rect_min_size.x = 100
	get_node("ConfirmationDialog").get_cancel().rect_min_size.x = 100
	if multiplayer:
		# TODO: Spawn a lobby where people can either connect to a peer or create a server
		pass
	game_setup()

# Function used to keep track of which players are ready
# TODO: Change this to keep track of ready states only
func player_ready():
	pass

# Member functions:
#   game_start: starts the game
sync func game_setup():
	# If there's no server connected, create one
	if not Net.connected:
		# TODO: Create a fake peer who we can automate, for single-player mode
		Net.start_host()
	network_id = Net.get_network_id()
	pass

#   game_start:
func game_start():
	# Make sure we're the server
	pass

#   _on_player_ready: Player Ready signal handler
func _on_player_ready():
	print ("_on_player_ready")
	Net.send(1, ["player_ready", Net.Mail.REPLY])

#   victory_screen: display the victory screen
func victory_screen():
	# TODO: Create the victory screen, fill it with knowledge
	pass

#   display_turn: display which turn it is on the screen
func display_turn():
	# TODO: Update the turn display, if there is one?
	pass

#   _on_Forfeit_pressed: Handle forfeit button press
func _on_Forfeit_pressed():
	AudioBus.emit_signal("button_clicked")
	get_node("ConfirmationDialog").popup()

#   end: end the Game
func end():
	queue_free()

#   _on_Button_button_down: Handle win button press
#   TODO: This isn't a thing any more
func _on_Button_button_down():
	AudioBus.emit_signal("button_clicked")
	var victory = Victory.instance()
	add_child(victory)
	victory.connect("exit_main", self, "end")

func _on_ConfirmationDialog_confirmed():
	end()

