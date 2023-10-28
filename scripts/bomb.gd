extends Area2D

var active = false
var bomb_time = 3
var counter = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = str(bomb_time)


func ignite():
	active = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		$Sprite.modulate = Color(1, 1, 1, 1)
		counter += delta
		$Label.text = str(bomb_time - int(counter))
		if counter > bomb_time:
			boom()
	else:
		$Sprite.modulate = Color(1, 1, 1, 0.3)
	

func boom():
	var areas = get_overlapping_areas()
	var bodies = get_overlapping_bodies()
	get_parent().remove_wall(position)
	queue_free()
