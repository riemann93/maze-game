extends Area2D

var active = false
var speed = 500

signal strike
signal boulder_gone

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	var start_timer = get_node("StartTimer")
	start_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		position.y += speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	boulder_gone.emit()
	queue_free()


func _on_start_timer_timeout():
	active = true


func _on_body_entered(body):
	print("Boulder hit")
	strike.emit()
