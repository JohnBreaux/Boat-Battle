extends Node

# Constants
#   DEFAULT_PORT: The port GodotShip will listen on/connect to by default
const DEFAULT_PORT = 35879
#   LOCALHOST: loopback address
const LOCALHOST = "127.0.0.1"

# Enums, used for mail types
#   Mail types:
#     0: REQUEST: Message is a request for information
#     1: REPLY: Message is a reply
#     2: READY: Message is "ready"
#     3: ACK:   Message is an acknowledgement
enum {REQUEST, REPLY, READY, ACK}

# Signals
#   incoming(mail): Sent when there's an incoming message
signal incoming
#   peers_updated(): Sent when the peer list is updated
signal peers_updated
#   disconnected():  Sent when unexpectedly disconnected
signal disconnected
# Variables
#   inbox: Array: Message history
var inbox = []
#   connected: Boolean: True when in the Connected state
var connected = false
#   hosting: Boolean:   True when in the Hosting state
var hosting = false
#   peer_info: Dictionary: Store peer info in a dictionary, by player ID
var peer_info = {}
#   local_info: Dictionary: Store this player's info
var local_info = {"name": ""}

# Network -- handles server and client setup, and facilitates communication between the two
#   receive: Receive a message (called by sender's `send` function)
#     mail: The message received from the sender (implicitly JSON-decoded by JSONRPC)
#     mail_type: Type of mail (see "Mail Types" enum above)
remote func receive(mail):
	# Unpack the mail
	# Uses json parser of unknown stability, how fun
	mail = parse_json(mail)
	# Get the sender's ID and force letter to be properly addressed
	mail[0] = get_tree().get_rpc_sender_id()
	# print_debug it, for posterity
	print_debug("recv: ", mail)
	# Add the mail to the inbox (so it can be read back later if necessary
	inbox.append(mail)
	# Sent it off to anything that expects mail
	emit_signal("incoming", mail)

#   send: Send a message
#     id: Peer ID of the recipient
#     mail: Variant of a json-encodable type (non-Object) to send
#     mail_type: Type of mail (see "Mail Types" enum above)
func send(id, mail, mail_type = REPLY):
	print_debug("send: [%d, %s, %d]" % [id, mail, mail_type])
	# Make the recipient receive the mail
	rpc_id(id, "receive", to_json([-1, mail, mail_type]))

# Host
#   start_host: Host the game
#     port: TCP port
#     max_players: Largest number of players allowed to connect at a time (the host does not count)
func start_host(port = DEFAULT_PORT, max_players = 1):
	get_hostname()
	peer_info[1] = local_info
	# Notify that peer list has updated
	emit_signal("peers_updated")
	# Create a new NetworkedMultiplayerENet (handles multiplayer communication through ENet)
	var peer = NetworkedMultiplayerENet.new()
	# Create a server
	peer.create_server(port, max_players)
	# Add the server to the scene tree
	get_tree().network_peer = peer
	# Update state
	connected = true
	hosting = true

#   accept_guests:
#     Select whether to accept new guests
func accept_guests(accept:bool):
	if hosting:
		multiplayer.refuse_new_network_connections = not accept

# Guest
#   connect_host: Connect to a host
func connect_host(ip = LOCALHOST, port = DEFAULT_PORT):
	get_hostname()
	var peer = NetworkedMultiplayerENet.new()
	var ret = peer.create_client(ip, int(port))
	get_tree().network_peer = peer
	return ret

#   disconnect_host
func disconnect_host():
	# Send intent to disconnect
	rpc("unregister_peer", get_network_id())
	# Set state to disconnected
	connected = false
	hosting = false
	# Attempt disconnection
	if get_tree().network_peer:
		get_tree().network_peer.close_connection()
	# Disconnect
	get_tree().network_peer = null
	# Clear peer info
	peer_info = {}
	# Notify that peer list has updated
	emit_signal("peers_updated")

#   change_name: Change the local name, and re-register with all peers (including self)
func change_name(name):
	# Change name locally
	local_info["name"] = name
	# If connected, update peers
	if connected:
		# Send updated info info to all peers
		rpc("register_peer", local_info)

# Helper Functions
#   get_hostname: Asks the host machine to provide its hostname,
#     and if the peer name isn't set, set it to the hostname
func get_hostname():
	var hostname = []
	# Execute the `hostname` command
	var _ret = OS.execute("hostname", [], true, hostname)
	# If there's no name set, set it to the hostname
	if local_info["name"] == "":
		local_info["name"] = hostname[0].split("\n")[0]
	return hostname[0].split("\n")[0]

func get_network_id():
	return get_tree().get_network_unique_id()

func get_ip():
	return IP.resolve_hostname(get_hostname(), IP.TYPE_IPV4)
	pass

func _ready():
	var _trash
	_trash = get_tree().connect("network_peer_connected",    self, "_peer_connected"   )
	_trash = get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")
	_trash = get_tree().connect("connected_to_server",       self, "_host_connected"   )
	_trash = get_tree().connect("server_disconnected",       self, "_host_disconnected")
	_trash = get_tree().connect("connection_failed",         self, "_connection_fail"  )

# Signal Handlers
func _peer_connected(id):
	# Send peer info to remote peer
	rpc_id(id, "register_peer", local_info)

func _peer_disconnected(id):
	# Unregister the peer locally
	unregister_peer(id)


func _host_connected():
	# On connection to the server, you get a global network id
	# Save your info at this id
	peer_info[get_network_id()] = local_info
	# Set state to connected
	connected = true

func _host_disconnected():
	# Ensure host is disconnected
	disconnect_host()
	# Send disconnection message to listeners
	emit_signal("disconnected")

func _connection_fail():
	# Ensure Net state is clear
	disconnect_host()

sync func register_peer(info):
	# Save player information under the sender id's peer info
	peer_info[get_tree().get_rpc_sender_id()] = info
	emit_signal("peers_updated")

sync func unregister_peer(id):
	peer_info.erase(id)
	emit_signal("peers_updated")
