extends Control
# Ignore discarded return values
# warning-ignore-all:return_value_discarded
onready var player_list = find_node("Player List")
onready var ip_address  = find_node("IP Address")
onready var name_popup  = find_node("Change Name")
onready var game_popup  = find_node("Connect to Game")

# TODO: Write a function to update Player List with the list of attached players

func _on_peers_updated():
	var connected_peers = ""
	for peer in Net.peer_info:
		connected_peers += ("%s\n" % Net.peer_info[peer]["name"])
		pass
	player_list.text = connected_peers.rsplit("\n", true, 1)[0].c_unescape()
	pass

func set_IP_Address_text(show):
	# Print the IP address and port
	if show:
		ip_address.text = "IP: %s\nPort: %s" % [Net.get_ip(), Net.DEFAULT_PORT]
	else:
		ip_address.text = ""

func _ready():
	Net.connect("peers_updated", self, "_on_peers_updated")
	Net.connect("disconnected",  self, "_on_Net_disconnected")
	name_popup.get_node("Name Entry").text = Net.get_hostname()
	_on_peers_updated()
	pass

func show_Connected_Options(show, host = false):
	# [Hide]/Show the host options
	get_node("Lobby Options/Connected Options/Host Options").visible = host
	# [Hide]/Show the host and connect buttons
	get_node("Lobby Options/Host or Connect").visible = !show
	# [Show]/Hide the host options
	get_node("Lobby Options/Connected Options").visible = show

# Buttons
#   Host Button: Host a game
#     Hides the connect button
func _on_Host_Button_pressed():
	# Make noise
	AudioBus.emit_signal("button_clicked")
	# Show "Connected Options"
	show_Connected_Options(true, true)
	# Show the host IP address
	set_IP_Address_text(true)
	# Begin hosting
	Net.start_host()

#   Disconnect
#     Disconnect from (or stop hosting) a game
#     Shows the host/connect buttons
func _on_Disconnect_Button_pressed():
	# Make noise
	AudioBus.emit_signal("button_clicked")
	# Disconnect
	Net.disconnect_host()
	# Hide "Connected Options"
	show_Connected_Options(false)
	# Hide the host IP address
	set_IP_Address_text(false)

func _on_Start_Game_pressed():
	# If there are enough players for a game
	if Net.peer_info.size() >= 2:
		# Start the game for all players
		rpc("start_game")
	pass # Replace with function body.

func _on_Net_disconnected():
	# Hide "Connected Options"
	show_Connected_Options(false)
	# Hide the host IP address
	set_IP_Address_text(false)

func _on_Change_Name_Button_pressed():
	# Make noise
	AudioBus.emit_signal("button_clicked")
	# Show the Change Name dialogue
	get_node("Change Name").popup_centered()

func _on_Connect_Button_pressed():
	# Make noise
	AudioBus.emit_signal("button_clicked")
	# Show the Connect to Game dialogue
	get_node("Connect to Game").popup_centered()

func _on_Exit_Lobby_pressed():
	# Make noise
	AudioBus.emit_signal("button_clicked")
	# Disconnect
	if Net.connected:
		Net.disconnect_host()
	# Close Lobby menu
	queue_free()


func _on_IP_and_Port_Entry_text_entered(text):
	# Make noise
	AudioBus.emit_signal("button_clicked")
	# Split it into IP and Port segments
	var ip_port = text.split(":")
	# If text exists and contains valid IP address
	if ip_port.size() > 0 and ip_port[0].is_valid_ip_address():
		# Connect to host
		var connected = Net.callv("connect_host", ip_port)
		if connected == OK:
			# Show "Connected Options"
			show_Connected_Options(true)
			# Hide the popup
			game_popup.hide()


func _on_Name_Entry_text_entered(text):
	# Make noise
	AudioBus.emit_signal("button_clicked")
	# Check the length of the name
	if text.length() < 18:
		# Change the name
		Net.change_name(text)
		# Hide the popup
		name_popup.hide()

sync func start_game():
	MessageBus.emit_signal("change_scene", "Gameplay")
	queue_free()


