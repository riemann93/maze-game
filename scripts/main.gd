extends Node

var arrow_scene = preload("res://scenes/arrow.tscn")
var maze_utils = preload("res://scripts/maze_utils.gd").new()

var score = 0
var chests_to_win = 1
var has_key = false
var cell_scaler = 64
var path = Vector2i(17, 9)
var wall = Vector2i(12, 5)
var item_distance_to_player = 100
var width = 0
var height = 0
var maze_ylim = Vector2i.ZERO
var maze_xlim = Vector2i.ZERO
var maze_ylim_len = 0
var maze_xlim_len = 0
var trim = 1


func _ready():
	pass

func new_game(level=0):
	if level > 4:
#		fill_tilemap(full_board(width, height), 0)
#		await get_tree().process_frame
		end_game(true)
		return
	var viewport_size = get_viewport().size # if visible_rect is different in the future: var c = get_viewport().get_visible_rect().size
	width = viewport_size.x/cell_scaler
	height = viewport_size.y/cell_scaler
	
	
	trim = 1 if level > 5 else 5 - level
	print(trim)
	
	maze_xlim = trim_vector(Vector2i(0, width-1), trim)
	maze_ylim = trim_vector(Vector2i(0, height-1), trim)
	maze_xlim_len = maze_xlim[1] - maze_xlim[0] + 1
	maze_ylim_len = maze_ylim[1] - maze_ylim[0] + 1
	var maze = maze_utils.create_maze(maze_xlim_len, maze_ylim_len)
	
	fill_tilemap(full_board(width, height), 0)
	fill_tilemap(maze, trim)
	place_items(trim)
	$Player.position = _cell_to_pos(Vector2i(trim, trim))
	$Player.show()
	$HUD.update_score(score)
	
	if level > 0:
		$ArrowTimer.wait_time = (1/(level*0.3 + 1)) * 5 
		$ArrowTimer.paused = false
		$ArrowTimer.start()
	

func trim_vector(vector: Vector2i, trim=1):
	vector[0] += trim
	vector[1] -= trim
	return vector


func end_game(won=false):
	print("but then i took an arrow to the knee!")
	$ArrowTimer.paused = true
	get_tree().call_group("arrows", "queue_free")
	score = 0
	trim = 1
	$Player.hide()
	$Key.hide()
	$Chest.hide()
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
	


func place_items(trim):
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
	
	$Key.position = _cell_to_pos(valid_cells[key_cell])
	$Chest.position = _cell_to_pos(valid_cells[chest_cell])
	$Key.show()
	$Chest.show()


func _distance_to_player(coords):
	return $Player.position.distance_to(coords)


func _cell_to_pos(cell):
	return cell * cell_scaler + Vector2i(cell_scaler/2, cell_scaler/2)
	
	
func _process(delta):
	pass
	

func _key_grabbed():
	$Key.position.x = 0
	$Key.position.y = 0
	self.has_key = true
	

func _chest_grabbed():
	if has_key:
		score += 1
		if score % chests_to_win == 0:
			new_game(score/chests_to_win)
		has_key = false
		$HUD.update_score(score)
		place_items(trim)


func _on_key_body_entered(body):
	if body.name == "Player":
		self._key_grabbed()


func _on_chest_body_entered(body):
	if body.name == "Player":
		self._chest_grabbed()


func _on_arrow_timer_timeout():
	if maze_ylim != Vector2i.ZERO and maze_ylim_len != 0:
		var arrow_instance = arrow_scene.instantiate()
		arrow_instance.strike.connect(strike)
		add_child(arrow_instance)
		var random_y = (randi() % maze_ylim_len*cell_scaler) + trim*cell_scaler
		arrow_instance.position = Vector2(0, random_y)
