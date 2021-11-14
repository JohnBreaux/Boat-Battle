extends Control

onready var master_slider  = find_node("Master Slider", true, true)
onready var music_slider  = find_node("Music Slider", true, true)
onready var sound_slider  = find_node("SFX Slider", true, true)
onready var theme_buttons = find_node("Buttons", true, true).get_children()

var light_theme = load("res://light_theme.tres")
var dark_theme = load("res://dark_theme.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	OptionsController.load_options()
	find_next_valid_focus().grab_focus()
	master_slider.value = db2linear(OptionsController.get_mas_volume())
	music_slider.value = db2linear(OptionsController.get_mus_volume())
	sound_slider.value = db2linear(OptionsController.get_sfx_volume())
	
	var _errno = 0;
	_errno += OptionsController.connect("change_theme", self, "_on_change_theme")
	_on_change_theme(OptionsController.get_theme())

func _on_Button_pressed():
	AudioBus.emit_signal("button_clicked")
	queue_free()
	#MessageBus.emit_signal("change_scene", "Title")

func _on_Master_Slider_value_changed(value):
	value = linear2db(value)
	AudioBus.emit_signal("button_clicked")
	OptionsController.set_vol(value, "mas_vol")

func _on_Music_Slider_value_changed(value):
	value = linear2db(value)
	AudioBus.emit_signal("button_clicked")
	OptionsController.set_vol(value, "mus_vol")

func _on_SFX_Slider_value_changed(value):
	value = linear2db(value)
	AudioBus.emit_signal("button_clicked")
	OptionsController.set_vol(value, "sfx_vol")

func _on_Light_pressed():
	AudioBus.emit_signal("button_clicked")
	OptionsController.set_theme("light")

func _on_Dark_pressed():
	AudioBus.emit_signal("button_clicked")
	OptionsController.set_theme("dark")
	
func _on_change_theme(theme):
	if theme == "light":
		self.set_theme(light_theme)
	elif theme == "dark":
		self.set_theme(dark_theme)
