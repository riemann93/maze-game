extends StaticBody2D

var sprite_string_f = "res://art/door_%s.png"

signal door_handle


func init(door_level):
	# load specific sprite
	var sprite_string = sprite_string_f % door_level
	var door_sprite = load(sprite_string)
	$Sprite2D.texture = door_sprite

	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		print("dude entered: ", body.name)
		door_handle.emit()
