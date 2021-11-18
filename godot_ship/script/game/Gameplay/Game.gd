extends Control

var light_theme = load("res://light_theme.tres")
var dark_theme = load("res://dark_theme.tres")


# Path to Player class, for instantiating new Players in code
onready var Player = preload("res://scenes/Game/Player.tscn")

onready var Victory = preload("res://scenes/Game/Victory.tscn")


# Array of instances of the Player class; stores the Players
var players = {} # = player1, player2, ...
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
remote func player_ready(pid):
	print (get_tree().is_network_server())
	var who = pid
	# Here are some checks you can do, for example
	assert(get_tree().is_network_server())
	assert(who in Network.peer_info) # Exists
	assert(not who in players_ready) # Was not added yet

	players_ready.append(who)

	if players_ready.size() == Network.peer_info.size():
		rpc("game_start")

# Member functions:
#   game_start: starts the game
func game_setup():
	# If there's no server connected, create one
	if not Network.connected:
		# TODO: Create a fake peer who we can automate, for single-player mode
		Network.start_server()
	network_id = Network.get_network_id()
	# Create players for every player in Network.peer_info
	for k in Network.peer_info.keys():
		# Create a new player
		var player = Player.instance()
		# Set the player's opponent, for now
		# Give the player a recognizable name, like "1", instead of "@@97"
		player.name = str(k)
		# The player controls themselves
		player.set_network_master(k)
		# Add the player to the list of players
		players[k] = player
		# Add the player to the scene tree
		add_child(player)
	pass
	
	# Connect to your own player_ready signal
	players[network_id].connect("player_ready", self, "_on_player_ready")
	# Have your player set up the board:
	players[network_id].set_up_begin()

func game_start():
	# Make sure we're the server
	assert(get_tree().is_network_server())
	while not winner:
		for id in players.keys():
			var hit = players[id].rpc_id(id, "turn_start")
			var result = players[hit["id"]].rpc_id(hit["id"], "hit", hit["target"])
			players[id].rpc_id(id, "mark", hit["target"], result)
		pass

func _on_player_ready(pid):
	print ("_on_player_ready")
	match pid:
		1: player_ready(pid)
		_: rpc("player_ready", pid)

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

