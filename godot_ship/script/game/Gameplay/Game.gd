extends Control

# warning-ignore-all:unused_signal
# warning-ignore-all:return_value_discarded

enum  {MISS = -1, READY = 0, HIT = 1, SUNK = 2, LOST = 3}

# Signals
#   Sent when game is ready
signal game_ready

# Path to Player class, for instantiating new Players in code
var Player = preload("res://scenes/Game/Player.tscn")
# Path to Victory class, which handles the victory screen
var Victory = preload("res://scenes/Game/Victory.tscn")


# Array of instances of the Player class; stores the Players
var player
var players_ready = []

# Every game is a multiplayer game, even the ones that aren't.
# We're taking the Minecraft approach, baby
var network_id

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Forfeit Confirmation").get_ok().text = "Yes"
	get_node("Forfeit Confirmation").get_cancel().text = "No"
	get_node("Forfeit Confirmation").get_ok().rect_min_size.x = 100
	get_node("Forfeit Confirmation").get_cancel().rect_min_size.x = 100

	if Net.connected:
		Net.connect("disconnected", self, "connection_error")
		Net.connect("incoming",     self, "_on_Net_incoming")
		pass
	game_setup()

# Function used to keep track of which players are ready
func player_ready(sender):
	players_ready.append(sender)
	print_debug("%s ready (%d/%d)" % [sender, players_ready.size(), Net.peer_info.size()])
	if (players_ready.size() >= Net.peer_info.size()):
		emit_signal("game_ready")

# Member functions:
#   game_setup: starts the game
sync func game_setup():
	# If there's no server connected, create one
	if not Net.connected:
		# TODO: Create a fake peer who we can automate, for single-player mode
		Net.start_host()
	network_id = Net.get_network_id()
	player = Player.instance()
	player.connect("player_ready", self, "_on_player_ready")
	add_child(player)
	player.set_up_begin()
	yield(self, "game_ready")
	if Net.hosting:
		state_fire()

#   state_fire: The firing state. Displays fire menu, then notifies opponent.
remote func state_fire():
	var pos = player.turn_start()
	if pos is GDScriptFunctionState:
		pos = yield(pos, "completed")
	rpc("state_check", pos)

#   state_check: The checking state. Branches out to the other states.
#     pos: Position which the opponent is trying to fire upon
remote func state_check(pos):
	var res = player.hit(pos)
	# Tell the opponent
	Net.send(0, ["hit", res], Net.REPLY)
	rpc("play_hit_sound", res)
	match res:
		LOST:
			# the other player wins
			rpc("state_win", player.board.ship_data)
		SUNK, HIT:
			# Hit
			rpc("state_fire")
		MISS:
			# Our turn to fire
			state_fire()
	pass

#   state_win: The winning state. If you reach here, you've won.
#     ships: The opponent's ship data, so that their board can be shown
remote func state_win(ships):
	# Send ships back to the opponent:
	rpc("state_lose", player.board.ship_data)
	# Show the victory screen
	victory_screen(ships, true)

#   state_lose: The losing state. If you reach here, you've lost.
#     ships: The opponent's ship data, so that their board can be shown
remote func state_lose(ships):
	# Show the not-victory screen
	victory_screen(ships, false)

#   play_hit_sound: Play a hit sound depending on the severity of the hit
#     value: Lost/Sunk/Hit/Miss
remote func play_hit_sound(value):
	match value:
		LOST, SUNK:
			AudioBus.emit_signal("ship_sunk")
		HIT:
			AudioBus.emit_signal("ship_hit")
		MISS:
			AudioBus.emit_signal("ship_missed")

#   hit: Update the local player's board when the opponent fires
#     pos: Opponent's target
func hit(pos):
	pos = Vector2(pos[0], pos[1])
	var res = player.hit(pos)
	return res

#   mark: Update the local player's hit/miss board when opponent replies
func mark(res):
	return player.mark(res)

#   _on_Net_incoming: Handle mail.
func _on_Net_incoming(mail):
	if mail.size() == 3:
		var sender   = int(mail[0])
		var message  = mail[1]
		var mailtype = int(mail[2])
		match mailtype:
			Net.REPLY:
				print_debug ("got REPLY")
					# message is a REPLY (return value)
				match message[0]:
					# on "fire": fire(result)
					"fire":
						hit(message[1])
					# on "hit": mark(state)
					"hit":
						mark(message[1])
					"forfeit":
						pass
			Net.READY:
				print_debug ("got READY")
				# Add player to the ready array
				player_ready(sender)
			_:
				# Unhandled mail type
				print_debug ("got %d?" % mailtype)

#   _on_player_ready: Player Ready signal handler
func _on_player_ready():
	Net.send(0, [], Net.READY)
	player_ready(Net.get_network_id())

#   victory_screen: display the victory screen
func victory_screen(ships, winner = true):
	# Stop listening for opponent disconnections
	Net.disconnect("disconnected", self, "connection_error")
	# Hide the buttons
	get_node("Buttons").hide()
	# Create a new Victory screen
	var victory = Victory.instance()
	# Allow victory to end the game
	victory.connect("end_game", self, "end")
	# Tell victory whether we've won or lost
	victory.set_win(winner)
	# If we were given ships to display
	if ships:
		# Give victory the ships
		victory.reveal_ships(ships)
	# Add victory to the scene tree
	add_child(victory)

#   _on_Forfeit_pressed: Handle forfeit button press
func _on_Forfeit_pressed():
	AudioBus.emit_signal("button_clicked")
	get_node("Forfeit Confirmation").popup_centered()

#   end: end the Game
sync func end():
	# Return to the lobby
	MessageBus.emit_signal("change_scene", "Multiplayer")
	queue_free()


func connection_error():
	get_node("Connection Error").popup_centered()

#   _on_Button_button_down: Handle win button press
#   TODO: This isn't a thing any more
func _on_Button_button_down():
	AudioBus.emit_signal("button_clicked")
	var victory = Victory.instance()
	add_child(victory)
	victory.connect("exit_main", self, "end")

func _on_Forfeit_Confirmation_confirmed():
	if Net.connected:
		# Send forfeit request to all users
		rpc("end")
	else:
		end()

func _on_Connection_Error_confirmed():
	# End the game
	end()

