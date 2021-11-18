extends Node

const DEFAULT_PORT = 35879
const LOCALHOST = "127.0.0.1"

# Store peer info in a dictionary, by player ID
var peer_info = {}
# Store this player's hostname
var local_info = {"hostname": ""}

var connected = false

# Network -- handles server and client setup, and facilitates communication between the two
#   start_server: Host the game
#     port: TCP port
#     max_players: Largest number of players allowed to connect at a time
func start_server(port = DEFAULT_PORT, max_players = 2):
	get_hostname()
	peer_info[1] = local_info
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, max_players)
	get_tree().network_peer = peer
	connected = true
	return

func connect_server(ip = LOCALHOST, port = DEFAULT_PORT):
	get_hostname()
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().network_peer = peer
	return

func disconnect_server():
	get_tree().network_peer = null
	connected = false

func get_hostname():
	if local_info["hostname"] == "":
		var hostname = []
		var _ret = OS.execute("hostname", [], true, hostname)
		local_info["hostname"] = hostname[0].split("\n")[0]
	return local_info["hostname"]

func get_network_id():
	return get_tree().get_network_unique_id()

func get_ip():
	print(IP.resolve_hostname(get_hostname(), IP.TYPE_IPV4))
	pass

func _ready():
	var _trash 
	_trash = get_tree().connect("network_peer_connected", self, "_peer_connected")
	_trash = get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")
	_trash = get_tree().connect("connected_to_server", self, "_server_connected")
	_trash = get_tree().connect("connection_failed", self, "_connection_fail")
	_trash = get_tree().connect("server_disconnected", self, "_server_disconnected")

func _peer_connected(id):
	rpc_id(id, "register_peer", local_info)
	pass

func _peer_disconnected(id):
	peer_info.erase(id)
	pass

func _server_connected():
	# On connection to the server, you get a global network id
	# Save your info at this id
	peer_info[get_network_id()] = local_info
	connected = true
	pass

func _server_disconnected():
	connected = false
	pass

func _connection_fail():
	connected = false
	pass

remote func register_peer(info):
	# Save player information under the sender id's peer info
	peer_info[get_tree().get_rpc_sender_id()] = info
	pass
