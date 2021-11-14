extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var _errno = 0
	_errno += AudioBus.connect("button_clicked", self, "_button_clicked")
	_errno += AudioBus.connect("ship_hit", self, "_ship_hit")
	_errno += AudioBus.connect("ship_missed", self, "_ship_missed")
	_errno += AudioBus.connect("ship_sunk", self, "_ship_sunk")

func _button_clicked():
	$buttonSFX.play()

func _ship_hit():
	$shipHitSFX.play()

func _ship_missed():
	$shipMissedSFX.play()

func _ship_sunk():
	$shipSunkSFX.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
