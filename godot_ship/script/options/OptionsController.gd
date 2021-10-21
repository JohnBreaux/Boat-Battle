extends Node

# signals
# Subscribe to these if you want to be notified about changes to the volume
signal change_theme (theme)
signal change_mus_volume (volume)
signal change_sfx_volume (volume)

# Option variables
var theme = "dark"
var mus_vol = 100
var sfx_vol = 100

func _ready():
	pass

# Setters
func set_theme(theme_name):
	match theme_name:
		"dark","light":
			theme = String(theme_name)
			emit_signal("change_theme", theme)
func set_mus_vol(volume):
	mus_vol = volume
	emit_signal("change_mus_volume", mus_vol)
func set_sfx_vol(volume):
	sfx_vol = volume
	emit_signal("change_sfx_volume", sfx_vol)

# Getters
func get_theme():
	return theme
func get_mus_volume():
	return mus_vol
func get_sfx_volume():
	return sfx_vol
