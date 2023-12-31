extends Area2D

var active = false
var speed = 2000

signal strike

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_timer(time):
	
	$StartTimer.wait_time = time
	$StartTimer.start()
	print("arrow_timer: ", time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		position.x += speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_start_timer_timeout():
	active = true


func _on_body_entered(body):
	strike.emit()
