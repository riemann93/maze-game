extends Area2D

var item = "chest_%s"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func init(color):
	print(color)
	item = item % color
	var load_string_f = "res://art/chest_%s.png"
	var load_string = load_string_f % color
	var chest_sprite = load(load_string)
	$Sprite2D.texture = chest_sprite
	$Sprite2D.show() 

func _on_key_area_entered(area):
	print("box!")
	pass # Replace with function body.
