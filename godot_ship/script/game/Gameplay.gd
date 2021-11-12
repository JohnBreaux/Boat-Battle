extends Control

signal two_ship_collide
signal three_shipA_collide
signal three_shipB_collide
signal four_ship_collide
signal five_ship_collide

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if find_next_valid_focus(): find_next_valid_focus().grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Forfeit_pressed():
	AudioBus.emit_signal("button_clicked")
	queue_free();
	MessageBus.emit_signal("change_scene", "Title")


func _on_2Ship_body_entered(body):
	var _errno = emit_signal("two_ship_collide", "2Ship")
	print("Emitting two_ship_collide")
	
func _on_3ShipA_body_entered(body):
	emit_signal("three_shipA_collide", "3ShipA")
	print("Emitting three_shipA_collide")
	
func _on_3ShipB_body_entered(body):
	emit_signal("three_shipB_collide", "3ShipA")
	print("Emitting three_shipB_collide")
	
func _on_4Ship_body_entered(body):
	emit_signal("four_ship_collide", "4Ship")
	print("Emitting four_ship_collide")

func _on_5Ship_body_entered(body):
	emit_signal("five_ship_collide", "5Ship")
	print("Emitting five_ship_collide")
	
