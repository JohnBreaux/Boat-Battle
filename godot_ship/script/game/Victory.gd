extends Control

# Path to Board class, for instantiating new Boards in code
var Board = preload("res://scenes/Game/Board.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Reveal a list of ships
func reveal_ships(ships:Array):
	var board = Board.instance()
	add_child(board);
	for ship in ships:
		board.callv("place_ship", ship)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_restart_button_down():
	AudioBus.emit_signal("button_clicked")
	MessageBus.emit_signal("change_scene", "Multiplayer")
	MessageBus.emit_signal("kill_scene", "Game")


# returns player(s) back to main menu
func _on_exit_to_main_button_down():
	AudioBus.emit_signal("button_clicked")
	MessageBus.emit_signal("return_to_title")
