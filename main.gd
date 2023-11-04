extends Node

var arrow_scene = preload("res://scenes/arrow.tscn")
var boulder_scene = preload("res://scenes/boulder.tscn")
var key_scene = preload("res://scenes/key.tscn")
var door_scene = preload("res://scenes/door.tscn")
var maze_utils = preload("res://scripts/maze_utils.gd").new()

@onready var player: CharacterBody2D = %Player
var score: int = 0
var level: int = 5
var door_level
var n_arrows: int = 0
var n_boulders: int = 0
var timer: int = 3000
var lives: int 
var bombs: int
var maze

var cell_scaler: int = 64
var path = Vector2i(17, 9)
var wall = Vector2i(12, 5)
var exit = Vector2i(17, 8)
var item_distance_to_player: int = 100
var width: int = 0
var height: int = 0
var maze_ylim = Vector2i.ZERO
var maze_xlim = Vector2i.ZERO
var maze_ylim_len: int = 0
var maze_xlim_len: int = 0
var exit_path
var trim: int = 2


func _ready():
	lives = 3
	bombs = 3
	player = $Player
	player.init(bombs)

func new_game():
	if level >= 6:
		end_game(true)
		return
	queue_free_items()
	var viewport_size = get_viewport().size # if visible_rect is different in the future: var c = get_viewport().get_visible_rect().size
	width = viewport_size.x/cell_scaler
	height = viewport_size.y/cell_scaler

#	trim = 2 if level > 5 else 6 - level
#
#	maze_xlim = trim_vector(Vector2i(0, width-1), trim)
#	maze_ylim = trim_vector(Vector2i(0, height-1), trim)
#	maze_xlim_len = maze_xlim[1] - maze_xlim[0] + 1
#	maze_ylim_len = maze_ylim[1] - maze_ylim[0] + 1
#	var maze = maze_utils.create_maze(maze_xlim_len, maze_ylim_len)
#
#	fill_tilemap(full_board(width, height), 0)
#	fill_tilemap(maze, trim)
	
	
#	exit_path = Vector2(maze_xlim[1]+1, maze_ylim[1])
#	var exit_cell = Vector2(maze_xlim[1]+2, maze_ylim[1])
#	$TileMap.set_cell(0, exit_path, 0, path)
#	$TileMap.set_cell(0, exit_cell, 0, exit)
#
#	door_level = 1 + level
#	if door_level > 4:
#		door_level = 4
#	place_items(door_level, exit_path)
#
#	player.position = cell_to_pos(Vector2i(trim, trim))
#	var win_x = (exit_path.x + 1) * cell_scaler
#	player.win_x = win_x
#	player.show()
#	$HUD.timer += timer
#	$HUD.update_lives(lives)
#
#	n_boulders = 0 if level == 0 else level/2
#	n_arrows = level - n_boulders
#	spawn_boulder(n_boulders)
#
#	$ArrowTimer.wait_time = 3
#	$ArrowTimer.paused = false
#	$ArrowTimer.start()
	
	# 3, 7, 11, 15, 19
	%HUD.timer = 99999
	
	
	fill_tilemap(full_board(width, height), 0)
	maze = maze_utils.create_maze(19, 19)
	fill_tilemap(maze, 1)
	
	



func reduce_maze(_maze):
	# reduce maze by two from all sides
	var new_maze = []
	var len = len(_maze) 
	if len < 7:
		return _maze
	for i in range(2, len-2):
		var new_row = _maze[i].slice(2, len-2)
		new_maze.append(new_row)
	return new_maze
	
	
func _on_test_timer_timeout():
	maze_utils.print_grid(maze)
	if maze != null:
		var _maze = reduce_maze(maze)
		
		var __maze = maze_utils.fix_maze(_maze)
		
		maze = __maze
		
		
		
		fill_tilemap(full_board(width, height), 0)
		fill_tilemap(maze, 1)


	
func limit_maze():
	print("limitting maze")


func cell_inside_maze(cell):
	var is_inside_x = cell.x >= maze_xlim.x and cell.x <= maze_xlim.y
	var is_inside_y = cell.y >= maze_ylim.x and cell.y <= maze_ylim.y
	return is_inside_x and is_inside_y


func place_key():
	# place keys randomly
	var all_cells = $TileMap.get_used_cells(0)
	var valid_cells = all_cells.duplicate()
	for cell in all_cells:
		var atlas_coords = $TileMap.get_cell_atlas_coords(0, cell)
		var player_dis = distance_to_player(cell_to_pos(cell))
		if atlas_coords == wall or player_dis < item_distance_to_player or !cell_inside_maze(cell):
			valid_cells.erase(cell)

	var key_cell = randi() % valid_cells.size()
	valid_cells.erase(key_cell)
	var key_instance = key_scene.instantiate()
	add_child(key_instance)
	key_instance.position = cell_to_pos(valid_cells[key_cell])
	key_instance.show()
	key_instance.grab_key.connect(item_grabbed)


func place_door(_door_level, pos):
	# place chest at exit
	var door_instance = door_scene.instantiate()
	add_child(door_instance)
	door_instance.position = pos
	door_instance.init(_door_level)
	door_instance.show()
	door_instance.door_handle.connect(open_door)


func place_items(_door_level, exit_path):
	place_key()
	var door_pos = cell_to_pos(Vector2i(exit_path ))
	place_door(_door_level, door_pos)

func trim_vector(vector: Vector2i, trim=1):
	vector[0] += trim
	vector[1] -= trim
	return vector

func _input(event):
	if event is InputEventKey and event.keycode == 73:
		var pressed = event.keycode
		new_game()


func queue_free_items():
	get_tree().call_group("arrows", "queue_free")
	get_tree().call_group("boulders", "queue_free")
	get_tree().call_group("keys", "queue_free")
	get_tree().call_group("doors", "queue_free")
	get_tree().call_group("shoes", "queue_free")
	get_tree().call_group("bombs", "queue_free")


func end_game(won=false):
	$ArrowTimer.paused = true
	queue_free_items()
	level = 0
	lives = 3
	bombs = 3
	$Player.position = cell_to_pos(Vector2i(trim, trim))
	$Player.init(bombs)
	$Player.hide()
	fill_tilemap(full_board(width, height), 0)
	$HUD.game_over(won)
	$HUD.timer = 0

func strike():
	lives -= 1
	if lives < 1:
		end_game()
		return
	$HUD.update_lives(lives)
	$Player.become_ethereal()


func try_to_jump(position, direction):
	var cell = pos_to_cell(position)
	var potential_wall = $TileMap.get_cell_atlas_coords(0, cell+direction)
	var other_side = $TileMap.get_cell_atlas_coords(0, cell+2*direction)
	if potential_wall == wall and other_side == path:
		return cell_to_pos(cell+2*direction)
	return null


func cell_ahead(position, direction):
	var cell = pos_to_cell(position)
	return cell_to_pos(cell+direction)


func remove_wall(position):
	$TileMap.set_cell(0, pos_to_cell(position), 0, path)


func update_bombs(bombs):
	$HUD.update_bombs(bombs)


func full_board(x, y):
	var board = []
	for i in range(x):
		var row = []
		for j in range(y):
			row.append(0)
		board.append(row)
	return board


func fill_tilemap(maze_blueprint, trim):
	var x_index = 0
	for x in maze_blueprint:
		var y_index = 0
		for y in x:
			var cell = Vector2(x_index+trim, y_index+trim)
			if y == 0:
				$TileMap.set_cell(0, cell, 0, wall)
			else:
				$TileMap.set_cell(0, cell, 0, path)
			y_index += 1
		x_index += 1


func distance_to_player(coords):
	return $Player.position.distance_to(coords)


func cell_to_pos(cell):
	return cell * cell_scaler + Vector2i(cell_scaler/2, cell_scaler/2)


func pos_to_cell(pos):
	return Vector2i((pos.x/cell_scaler), (pos.y/cell_scaler))

func _process(delta):
	pass


func item_grabbed():
	%Player.has_key = true


func open_door():
	if %Player.has_key:
		%Player.has_key = false
		get_tree().call_group("doors", "queue_free")
		if door_level > 1:
			door_level -= 1
			place_items(door_level, exit_path)


func exit_maze():
	%Player.has_key = false
	level += 1
	new_game()


func _on_arrow_timer_timeout():
	var taken_spots = []
	for i in range(n_arrows):
		var random_y = 0
		while true:
			random_y = (randi() % maze_ylim_len*cell_scaler) + trim*cell_scaler
			if random_y not in taken_spots:
				taken_spots.append(random_y)
				break
		var arrow_instance = arrow_scene.instantiate()
		arrow_instance.strike.connect(strike)
		add_child(arrow_instance)
		arrow_instance.position = Vector2((trim-1)*cell_scaler, random_y)
		arrow_instance.set_timer(1.5 + i*0.2)


func spawn_boulder(boulders = 1):
	var taken_spots = []
	for i in boulders:
		var random_x = 0
		while true:
			random_x = (randi() % maze_xlim_len*cell_scaler) + trim*cell_scaler
			if random_x not in taken_spots:
				taken_spots.append(random_x)
				break
		var boulder_instance = boulder_scene.instantiate()
		add_child(boulder_instance)
		boulder_instance.position = Vector2i(random_x, (trim-1)*cell_scaler)
		boulder_instance.boulder_gone.connect(spawn_boulder)
		boulder_instance.strike.connect(strike)


