extends CharacterBody2D

var speed = 800
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
	
func _physics_process(delta):
	get_input()	
	move_and_slide()

func loot(item):
	item_table[item] = 1
	
	print("loot. table: ", item_table)
