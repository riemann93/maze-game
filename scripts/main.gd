extends Node

var arrow_scene = preload("res://scenes/arrow.tscn")
var boulder_scene = preload("res://scenes/boulder.tscn")
var key_scene = preload("res://scenes/key.tscn")
var chest_scene = preload("res://scenes/chest.tscn")
var maze_utils = preload("res://scripts/maze_utils.gd").new()

var score = 0
var chests_to_win = 1
var level = 0
var has_key = false
var n_arrows = 0
var n_boulders = 0

var cell_scaler = 64
var path = Vector2i(17, 9)
var wall = Vector2i(12, 5)
var exit = Vector2i(17, 8)
var item_distance_to_player = 100
var width = 0
var height = 0
var maze_ylim = Vector2i.ZERO
var maze_xlim = Vector2i.ZERO
var maze_ylim_len = 0
var maze_xlim_len = 0
var trim = 2


func _ready():
	pass

func new_game():
	if level > 4:
		end_game(true)
		return
	
	get_tree().call_group("arrows", "queue_free")
	get_tree().call_group("boulders", "queue_free")
	get_tree().call_group("keys", "queue_free")
	
	var viewport_size = get_viewport().size # if visible_rect is different in the future: var c = get_viewport().get_visible_rect().size
	width = viewport_size.x/cell_scaler
	height = viewport_size.y/cell_scaler
	
	trim = 2 if level > 5 else 6 - level
	
	maze_xlim = trim_vector(Vector2i(0, width-1), trim)
	maze_ylim = trim_vector(Vector2i(0, height-1), trim)
	maze_xlim_len = maze_xlim[1] - maze_xlim[0] + 1
	maze_ylim_len = maze_ylim[1] - maze_ylim[0] + 1
	var maze = maze_utils.create_maze(maze_xlim_len, maze_ylim_len)
	
	fill_tilemap(full_board(width, height), 0)
	fill_tilemap(maze, trim)
	
	var exit_path = Vector2(maze_xlim[1]+1, maze_ylim[1])
	var exit_cell = Vector2(maze_xlim[1]+2, maze_ylim[1])
	$TileMap.set_cell(0, exit_path, 0, path)
	$TileMap.set_cell(0, exit_cell, 0, exit)
	
	place_keys(1) # should be level
	$Player.position = _cell_to_pos(Vector2i(trim, trim))
	$Player.show()
	$HUD.update_score(score)
	
	
	n_boulders = 0 if level == 0 else level/2
	n_arrows = level - n_boulders
	spawn_boulder(n_boulders)
	
	$ArrowTimer.wait_time = 3
	$ArrowTimer.paused = false
	$ArrowTimer.start()
	

func cell_inside_maze(cell):
	var is_inside_x = cell.x >= maze_xlim.x and cell.x <= maze_xlim.y
	var is_inside_y = cell.y >= maze_ylim.x and cell.y <= maze_ylim.y
	return is_inside_x and is_inside_y
#	if cell[0] > maze_xlim.[0] and cell[0] < maze_xlim[1] and cell[1] > maze_ylim.[0] and cell[1]
#		return true
#	else: 
#		return false

	
func place_keys(n_keys):
	var key_enum = {
		0: "red",
		1: "blue",
		2: "yellow",
		3: "green"
	}
	for i in n_keys:
		# place keys randomly
		var all_cells = $TileMap.get_used_cells(0)
		var valid_cells = all_cells.duplicate()
		for cell in all_cells:
			var atlas_coords = $TileMap.get_cell_atlas_coords(0, cell)
			var player_dis = _distance_to_player(_cell_to_pos(cell))
			if atlas_coords == wall or player_dis < item_distance_to_player or !cell_inside_maze(cell):
				valid_cells.erase(cell)
	
		var key_cell = randi() % valid_cells.size()
		valid_cells.erase(key_cell)
		var key_instance = key_scene.instantiate()
		key_instance.init(key_enum[i])
		add_child(key_instance)
		key_instance.position = _cell_to_pos(valid_cells[key_cell])
		print(key_instance.position)
		key_instance.show()
		
		# place chest at exit
		var chest_instance = chest_scene.instantiate()
		chest_instance.init(key_enum[i])
		add_child(chest_instance)

func trim_vector(vector: Vector2i, trim=1):
	vector[0] += trim
	vector[1] -= trim
	return vector

func _input(event):
	if event is InputEventKey and event.keycode == 73:
		var pressed = event.keycode
		print("I pressed")
		new_game()

func end_game(won=false):
	$ArrowTimer.paused = true
	get_tree().call_group("arrows", "queue_free")
	get_tree().call_group("boulders", "queue_free")
	score = 0
	trim = 1
	$Player.hide()
	$KeyOld.hide()
	$ChestOld.hide()
	$HUD.update_score(score)
	fill_tilemap(full_board(width, height), 0)
	$HUD.game_over(won)

func strike():
	end_game()


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
	


func place_items():
	var all_cells = $TileMap.get_used_cells(0)
	var valid_cells = all_cells.duplicate()
	for cell in all_cells:
		var atlas_coords = $TileMap.get_cell_atlas_coords(0, cell)
		var player_dis = _distance_to_player(_cell_to_pos(cell))
		if atlas_coords == wall or player_dis < item_distance_to_player:
			valid_cells.erase(cell)
	
	var key_cell = randi() % valid_cells.size()
	valid_cells.erase(key_cell)
	var chest_cell = randi() % valid_cells.size()
	
	$KeyOld.position = _cell_to_pos(valid_cells[key_cell])
	$ChestOld.position = _cell_to_pos(valid_cells[chest_cell])
	$KeyOld.show()
	$ChestOld.show()


func _distance_to_player(coords):
	return $Player.position.distance_to(coords)


func _cell_to_pos(cell):
	return cell * cell_scaler + Vector2i(cell_scaler/2, cell_scaler/2)
	
	
func _process(delta):
	pass
	

func _key_grabbed():
	$KeyOld.position.x = 0
	$KeyOld.position.y = 0
	self.has_key = true
	

func _chest_grabbed():
	if has_key:
		score += 1
		$HUD.update_score(score)
		has_key = false
		if score % chests_to_win == 0:
			level = score/chests_to_win
			new_game()
		else:
			place_items()


func _on_key_body_entered(body):
	if body.name == "Player":
		self._key_grabbed()


func _on_chest_body_entered(body):
	if body.name == "Player":
		self._chest_grabbed()


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
	
