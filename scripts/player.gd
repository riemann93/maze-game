extends CharacterBody2D

var speed = 800

func _ready():
	pass

func get_input():
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_dir * speed
	
func _physics_process(delta):
	get_input()	
	move_and_slide()
