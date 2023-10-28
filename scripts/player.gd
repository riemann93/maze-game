extends CharacterBody2D

var speed = 200
var is_ethereal = false

var directions = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
var last_direction = Vector2i(0, 0)
var is_jumping = false

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


func is_direction_pressed():
	if Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		return true
	else:
		return false


func _process(delta):
	if Input.is_action_pressed("ui_up"):
		last_direction = directions[0]
	elif Input.is_action_pressed("ui_down"):
		last_direction = directions[1]
	elif Input.is_action_pressed("ui_left"):
		last_direction = directions[2]
	elif Input.is_action_pressed("ui_right"):
		last_direction = directions[3]
	if Input.is_action_pressed("jump") and Input:
		jump(last_direction)


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


func jump(direction):
	if direction != Vector2i(0, 0) and is_jumping == false:
		is_jumping = true
		$JumpCD.start()
		get_parent().try_to_jump(position, direction)


func become_ethereal():
	print("im invincibleeeeee!!!!")
	collision_layer &= ~(1 << 1)
	$EtherealTimer.start()
	$Sprite.modulate = Color(1, 1, 1, 0.3)


func _on_ethereal_timer_timeout():
	print("I can die...")
	collision_layer |= (1 << 1)
	$Sprite.modulate = Color(1, 1, 1, 1)


func _on_jump_cd_timeout():
	is_jumping = false
