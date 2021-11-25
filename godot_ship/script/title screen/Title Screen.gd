extends Control

var light_theme = load("res://light_theme.tres")
var dark_theme = load("res://dark_theme.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Singleplayer.grab_focus()
	var _errno = 0;
	_errno += OptionsController.connect("change_theme", self, "_on_change_theme")
	_on_change_theme(OptionsController.get_theme())

func _on_Singleplayer_pressed():
	AudioBus.emit_signal("button_clicked")
	MessageBus.emit_signal("change_scene", "Gameplay")
	queue_free()

func _on_Multiplayer_pressed():
	AudioBus.emit_signal("button_clicked")
	MessageBus.emit_signal("change_scene", "Multiplayer")
	queue_free()

func _on_Options_pressed():
	AudioBus.emit_signal("button_clicked")
	MessageBus.emit_signal("change_scene", "Options")
	queue_free()

func _on_Credits_pressed():
	AudioBus.emit_signal("button_clicked")
	MessageBus.emit_signal("change_scene", "Credits")
	queue_free()

func _on_Quit_pressed():
	AudioBus.emit_signal("button_clicked")
	MessageBus.emit_signal("quit")
	queue_free()

func _on_change_theme(theme):
	if theme == "light":
		self.set_theme(light_theme)
	elif theme == "dark":
		self.set_theme(dark_theme)
