extends Control

# warning-ignore-all:unused_signal

# Signals
signal fire # fire(position)
signal hit  # hit (state: see Miss/Ready/Hit/Sunk enum in Board.gd)
signal win  # win (): sent when opponent player lost

# Path to Player class, for instantiating new Players in code
var Player = preload("res://scenes/Game/Player.tscn")

var Victory = preload("res://scenes/Game/Victory.tscn")


# Array of instances of the Player class; stores the Players
var player
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
	players_ready.append(Net.get_network_id())
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

#   game_start: Runs on host. Controls the game.
func game_start():
	var state = "P1_fire"
	# Make sure we're the server
	while true:
		match state:
			"P1_fire":
				# Tell local player to fire

				# Wait for result

				# Send fire REQUEST to P2
				pass
			"P2_check":
				# Wait for hit
				var ret = yield(self, "hit")
				# Record the hit

				#
				pass
			"P2_fire":
				pass
			"P1_check":
				# Check if
				pass
			"P1_win":
				pass
			"P2_win":
				pass
	pass

func fire_on(id, pos:Vector2):
	# REQUEST fire on opponent
	Net.send(id, ["fire", pos], Net.REQUEST)
	# Wait for REPLY

func return_hit(id, ship_status):

	Net.send(id, ["hit", ship_status], Net.REPLY)

func _on_win():
	pass

func _on_Net_incoming(mail):
	if mail.size() == 3:
		var sender   = mail[0]
		var message  = mail[1]
		var mailtype = mail[2]
		match mailtype:
			# if message is a REQUEST (to perform an action)
			Net.REQUEST:
				match message[0]:
					# Opponent asks for player.fire()
					"fire":
						emit_signal("fire", message[1])
					# Opponent asks for hit(pos)
					"hit":
						pass
					_:
						pass
			Net.REPLY:
					# message is a REPLY (return value)
				match message[0]:
					"fire":
						emit_signal("hit", message[1])
					# Return value of
					"hit":
						pass
				pass
			Net.READY:
				# Add player to the ready array
				players_ready.append(sender)
				pass

#   _on_player_ready: Player Ready signal handler
func _on_player_ready():
	print ("_on_player_ready")
	Net.send(1, [], Net.READY)

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

