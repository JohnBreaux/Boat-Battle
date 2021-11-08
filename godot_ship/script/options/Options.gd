extends Control

onready var sound_slider  = find_node("SFX Slider", true, true)
onready var music_slider  = find_node("Volume Slider", true, true)
onready var theme_buttons = find_node("Buttons", true, true).get_children()


# Called when the node enters the scene tree for the first time.
func _ready():
	OptionsController.load_options()
	find_next_valid_focus().grab_focus()
	sound_slider.value = OptionsController.get_sfx_volume()
	music_slider.value = OptionsController.get_mus_volume()

func _on_Button_pressed():
	AudioBus.emit_signal("button_clicked")
	queue_free()
	#MessageBus.emit_signal("change_scene", "Title")

func _on_SFX_Slider_value_changed(value):
	AudioBus.emit_signal("button_clicked")
	OptionsController.set_sfx_vol(value)
	OptionsController.save_options()

func _on_Volume_Slider_value_changed(value):
	OptionsController.set_mus_vol(value)
	OptionsController.save_options()

func _on_Light_pressed():
	AudioBus.emit_signal("button_clicked")
	OptionsController.set_theme("light")
	OptionsController.save_options()

func _on_Dark_pressed():
	AudioBus.emit_signal("button_clicked")
	OptionsController.set_theme("dark")
	OptionsController.save_options()
