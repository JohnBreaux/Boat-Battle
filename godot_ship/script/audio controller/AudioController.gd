extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var _errno = 0
	_errno += AudioBus.connect("button_clicked", self, "_button_clicked")

func _button_clicked():
	$buttonSFX.play()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
