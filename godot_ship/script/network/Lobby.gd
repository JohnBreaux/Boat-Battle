extends Control
# Ignore discarded return values
# warning-ignore:return_value_discarded
onready var player_list = find_node("Player List")
onready var ip = find_node("IP Address")

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
		ip.text = "IP: %s\nPort: %s" % [Net.get_ip(), Net.DEFAULT_PORT]
	else:
		ip.text = ""

func _ready():
	Net.connect("peers_updated", self, "_on_peers_updated")
	Net.connect("disconnected",  self, "_on_Net_disconnected")
	_on_peers_updated()
	pass

func show_Connected_Options(show):
	# Hide the host and connect buttons
	get_node("Lobby Options/Host or Connect").visible = !show
	# Show the host options
	get_node("Lobby Options/Connected Options").visible = show

# Buttons
#   Host Button: Host a game
#     Hides the connect button
func _on_Host_Button_pressed():
	# Show "Connected Options"
	show_Connected_Options(true)
	# Show the host IP address
	set_IP_Address_text(true)
	# Begin hosting
	Net.start_host()

#   Disconnect 
#     Disconnect from (or stop hosting) a game
#     Shows the host/connect buttons
func _on_Disconnect_Button_pressed():
	# Disconnect
	Net.disconnect_host()
	# Hide "Connected Options"
	show_Connected_Options(false)
	# Hide the host IP address
	set_IP_Address_text(false)

func _on_Net_disconnected():
	# Hide "Connected Options"
	show_Connected_Options(false)
	# Hide the host IP address
	set_IP_Address_text(false)

func _on_Change_Name_Button_pressed():
	# Show the Change Name dialogue
	get_node("Change Name").popup_centered()
	pass

func _on_Connect_Button_pressed():
	# Show the Connect to Game dialogue
	get_node("Connect to Game").popup_centered()
	pass

func _on_Connect_to_Game_confirmed():
	# Get the IP and port specified by the player
	var ipbox = find_node("IP and Port Entry")
	# Split it into IP and Port segments
	var ip_port = ipbox.text.split(":")
	# If text exists and contains valid IP address
	if ip_port.size() > 0 and ip_port[0].is_valid_ip_address():
		# Connect to host
		Net.callv("connect_host", ip_port)
		# Show "Connected Options"
		show_Connected_Options(true)

func _on_Exit_Lobby_pressed():
	# Disconnect
	if Net.connected:
		Net.disconnect_host()
	# Close Lobby menu
	queue_free()


func _on_IP_and_Port_Entry_text_entered(text):
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
			find_node("Connect to Game").hide()


func _on_Name_Entry_text_entered(text):
	# Change the name
	Net.change_name(text)
	# Hide the popup
	find_node("Change Name").hide()
