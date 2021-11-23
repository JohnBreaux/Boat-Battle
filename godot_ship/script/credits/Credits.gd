extends Control

var light_theme = load("res://light_theme.tres")
var dark_theme = load("res://dark_theme.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	var _errno = 0;
	_errno += OptionsController.connect("change_theme", self, "_on_change_theme")
	_on_change_theme(OptionsController.get_theme())

func _on_Back_pressed():
	AudioBus.emit_signal("button_clicked")
	queue_free()
	pass # Replace with function body.

func _on_change_theme(theme):
	if theme == "light":
		self.set_theme(light_theme)
	elif theme == "dark":
		self.set_theme(dark_theme)
