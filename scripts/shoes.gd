extends Area2D

signal grab_shoes
var pickup = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if pickup:
		body.pick_up_shoes()
		queue_free()


func _on_pickup_timer_timeout():
	pickup = true
