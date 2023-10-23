extends Node

var score = 0
var has_key = false
var cell_scaler = 64
var path = Vector2i(17, 9)
var wall = Vector2i(12, 5)
var item_distance_to_player = 100


func _ready():
	var viewport_size = get_viewport().size # if visible_rect is different in the future: var c = get_viewport().get_visible_rect().size
	var width = viewport_size.x/cell_scaler
	var height = viewport_size.y/cell_scaler
	var maze_blueprint = []
	for x in range(width):
		var column = []
		for y in range(height):
			column.append(y)
		maze_blueprint.append(column)
	
	var maze = create_maze(25, 15)
	
	_fill_tilemap(maze)
	_place_items()
	$HUD.update_score(score)

func carve_maze(board, x, y, directions):
	directions.shuffle()
	for dir in directions:
		var new_x = x + dir[0] * 2
		var new_y = y + dir[1] * 2
		if new_x > 0 and new_x < len(board) - 1 and new_y > 0 and new_y < len(board[0]) - 1:
			if board[new_x][new_y] == 0:
				board[new_x][new_y] = 1
				board[x + dir[0]][y + dir[1]] = 1
				carve_maze(board, new_x, new_y, directions)

func create_maze(x, y):
	var board = []
	var directions = [[0, 1], [1, 0], [0, -1], [-1, 0]]

	# Initialize board with zeros
	for i in range(x):
		var row = []
		for j in range(y):
			row.append(0)
		board.append(row)

	# Initialize perimeter with wall
	for i in range(x):
		board[i][0] = 0
		board[i][y - 1] = 0
	for j in range(y):
		board[0][j] = 0
		board[x - 1][j] = 0

	# Start carving from one cell inside the perimeter
	board[1][1] = 1
	carve_maze(board, 1, 1, directions)
	
	return board



func _fill_tilemap(maze_blueprint):
	var x_index = 0
	for x in maze_blueprint:
		var y_index = 0
		for y in x:
			var cell = Vector2(x_index, y_index)
			if y == 0:
				$TileMap.set_cell(0, cell, 0, wall)
			else:
				$TileMap.set_cell(0, cell, 0, path)
			y_index += 1
		x_index += 1
	


func _place_items():
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
	print("has key")
	pass

func _chest_grabbed():
	if has_key:
		has_key = false
		score += 1
		$HUD.update_score(score)
		var maze = create_maze(25, 15)
		_fill_tilemap(maze)
		_place_items()
	else:
		print("No Key!")

func _on_key_body_entered(body):
	if body.name == "Player":
		print("Key picked up")
		self._key_grabbed()
	pass # Replace with function body.


func _on_chest_body_entered(body):
	if body.name == "Player":
		print("grabbing chest")
		self._chest_grabbed()
	pass # Replace with function body.
