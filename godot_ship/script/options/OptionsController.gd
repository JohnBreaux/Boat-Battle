extends Node

# signals
# Subscribe to these if you want to be notified about changes to the volume
signal change_theme (theme)

# Option variables
var f = File.new()
var options_file = "user://options.save"
var theme = "dark"
var mas_vol = linear2db(1)
var mus_vol = linear2db(1)
var sfx_vol = linear2db(1)

func _ready():
	load_options()

# Setters
func set_theme(theme_name):
	match theme_name:
		"dark","light":
			theme = String(theme_name)
			save_options()
			emit_signal("change_theme", theme)
	save_options()
	
func set_vol(volume, type):
	if type == "mas_vol":
		mas_vol = volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), mas_vol)
	elif type == "mus_vol":
		mus_vol = volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), mus_vol)
	elif type == "sfx_vol":
		sfx_vol = volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_vol)
	save_options()
	
#func set_mas_vol(volume):
#	mas_vol = volume
#	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), mas_vol)
#func set_mus_vol(volume):
#	mus_vol = volume
#	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), mus_vol)
#func set_sfx_vol(volume):
#	sfx_vol = volume
#	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_vol)

#Option Save File
func save_options():
	f.open(options_file, File.WRITE)
	f.store_var(theme)
	f.store_var(mas_vol)
	f.store_var(mus_vol)
	f.store_var(sfx_vol)
	f.close()
func load_options():
	if f.file_exists(options_file):
		f.open(options_file, File.READ)
		theme = f.get_var()
		mas_vol = f.get_var()
		mus_vol = f.get_var()
		sfx_vol = f.get_var()
		f.close()
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), mas_vol)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), mus_vol)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_vol)

# Getters
func get_theme():
	return theme
func get_mas_volume():
	return mas_vol
func get_mus_volume():
	return mus_vol
func get_sfx_volume():
	return sfx_vol
