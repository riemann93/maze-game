extends CharacterBody2D

var speed = 800
@export var win_x: int

signal exit

var item_table = {
	"key_red": 0,
	"key_blue": 0,
	"key_yellow": 0,
	"key_green": 0
}


func _ready():
	pass

func get_input():
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_dir * speed
	if position.x > win_x:
		exit.emit()
	
func _physics_process(delta):
	get_input()	
	move_and_slide()

func set_win_x(x):
	win_x = x
