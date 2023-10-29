extends CharacterBody2D

var shoes_scene = preload("res://scenes/shoes.tscn")
var bomb_scene = preload("res://scenes/bomb.tscn")

var speed = 400
var is_ethereal = false
var has_shoes = true
var has_key = false
var is_jumping = false
var is_throwing = false
var holding_bomb = false
var current_bomb
var bombs = 0

var directions = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
var last_direction = Vector2i(0, 0)

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


func init(_bombs):
	bombs = _bombs
	get_parent().update_bombs(bombs)


func pick_up_shoes():
	has_shoes = true
	$SpriteShoes.show()
	


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
	if Input.is_action_pressed("jump"):
		jump(last_direction)
	if Input.is_action_pressed("bomb") and !is_throwing and bombs > 0:
		holding_bomb = true
		hold_bomb()
	if not Input.is_action_pressed("bomb") and holding_bomb:
		holding_bomb = false
		throw_bomb()
		

func hold_bomb():
	if !current_bomb:
		var bomb_instance = bomb_scene.instantiate()
		get_parent().add_child(bomb_instance)
		current_bomb = bomb_instance
	if last_direction != Vector2i(0, 0):
		var bomb_pos = get_parent().cell_ahead(position, last_direction)
		current_bomb.position = bomb_pos


func throw_bomb():
	is_throwing = true
	$ThrowCD.start()
	current_bomb.ignite()
	current_bomb = null
	bombs -= 1
	get_parent().update_bombs(bombs)
	

func get_input():
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	if position.x > win_x:
		exit.emit()
	
func _physics_process(delta):
	get_input()	
	move_and_slide()

func set_win_x(x):
	win_x = x


func jump(direction):
	if direction != Vector2i(0, 0) and is_jumping == false and has_shoes == true:
		var new_position = get_parent().try_to_jump(position, direction)
		if new_position:
			$JumpCD.start()
			is_jumping = true
			has_shoes = false
			$SpriteShoes.hide()
			var old_position = position
			position = new_position 
			var shoes_instance = shoes_scene.instantiate()
			shoes_instance.position = old_position
			get_parent().add_child(shoes_instance)


func become_ethereal():
	collision_layer &= ~(1 << 1)
	$EtherealTimer.start()
	$Sprite.modulate = Color(1, 1, 1, 0.3)


func _on_ethereal_timer_timeout():
	collision_layer |= (1 << 1)
	$Sprite.modulate = Color(1, 1, 1, 1)


func _on_jump_cd_timeout():
	is_jumping = false


func _on_throw_cd_timeout():
	is_throwing = false
