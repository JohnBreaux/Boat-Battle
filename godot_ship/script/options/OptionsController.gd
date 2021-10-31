extends Node

# signals
# Subscribe to these if you want to be notified about changes to the volume
signal change_theme (theme)
signal change_mus_volume (volume)
signal change_sfx_volume (volume)

# Option variables
var f = File.new()
var options_file = "user://options.save"
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

#Option Save File
func save_options():
	f.open(options_file, File.WRITE)
	f.store_var(theme)
	f.store_var(mus_vol)
	f.store_var(sfx_vol)
	f.close()
func load_options():
	if f.file_exists(options_file):
		f.open(options_file, File.READ)
		theme = f.get_var()
		mus_vol = f.get_var()
		sfx_vol = f.get_var()
		f.close()

# Getters
func get_theme():
	return theme
func get_mus_volume():
	return mus_vol
func get_sfx_volume():
	return sfx_vol
