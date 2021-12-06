extends Control

# Path to Board class, for instantiating new Boards in code
var Board = preload("res://scenes/Game/Board.tscn")

# Sidnals
#   request to return to lobby
signal end_game
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Reveal a list of ships
func reveal_ships(ships:Array):
	var board = Board.instance()
	add_child(board);
	for ship in ships:
		board.callv("place_ship", ship)

func set_win(won:bool):
	var Text = find_node("Text")
	if won:
		Text.text = "You win!"
	else:
		Text.text = "You lose"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Restart_pressed():
	AudioBus.emit_signal("button_clicked")
	emit_signal("end_game")


# returns player(s) back to main menu
func _on_Exit_to_Title_pressed():
	AudioBus.emit_signal("button_clicked")
	# Disconnect from peer
	Net.disconnect_host()
	# Force return to title
	MessageBus.emit_signal("return_to_title")
