extends Control

var atlas = preload("res://assets/game/HitMissAtlas.png")
var sprites = []
var hits = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Signal to pass the fire location back to yet-unknown nodes
signal fire_at

func _init(topBoard):
	hits = topBoard

func _on_Fire_pressed():
	var crosshair = get_node("Crosshair")
	# Check if the crosshair is in a valid position
	if crosshair.validate_position(crosshair.position):
		var crosshair_pos = crosshair.world_to_board_space(crosshair.position)
		if(hits[crosshair_pos.x][crosshair_pos.y] == 0):
			# fires at position
			print("Fire at position: ", crosshair_pos)
			emit_signal("fire_at", crosshair_pos)
			# Close the Firing menu
			queue_free()
			return
	#if invalid position popup appears
	var dialog = get_node("FireDialog")
	dialog.popup_centered()

func _on_FireDialog_confirmed():
	get_node("Crosshair").visible = true
	
const OFFSET = Vector2(18, 18)

func texture(index):
	if(hits[index.x][index.y] != 0):
		var textureSize = 32
		# It's okay to create a new texture every time, as resources are refcounted
		var t = AtlasTexture.new()
		t.set_atlas(atlas)
		t.margin = Rect2(0, 0, 0, 0)
		t.region = Rect2(
			0 if(hits[index.x][index.y] < 0) else textureSize,
			0,
			textureSize,
			textureSize
		)
		# Create a new Sprite to house the texture, or use the existing sprite
		var sprite = Sprite.new()
		sprite.texture = t
		sprite.position = Vector2(index.x, index.y) * textureSize + OFFSET
		
		printt(t.get_height(), t.get_width())
		
		$board_blue.add_child(sprite)
