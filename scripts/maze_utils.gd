func carve_maze(board, x, y, directions, depth=0):
	var copy_of_directions = directions[0].duplicate()
	copy_of_directions.shuffle()
	directions.append(copy_of_directions)
	for dir in directions[depth]:
		var new_x = x + dir[0] * 2
		var new_y = y + dir[1] * 2
		if new_x >= 0 and new_x < len(board) and new_y >= 0 and new_y < len(board[0]):
			if board[new_x][new_y] == 0:
				board[new_x][new_y] = 1
				board[x + dir[0]][y + dir[1]] = 1
				carve_maze(board, new_x, new_y, directions, depth+1)


func create_maze(x, y):
	var board = []
	var directions = [[[0, 1], [1, 0], [0, -1], [-1, 0]]]

	# Initialize board with zeros
	for i in range(x):
		var row = []
		for j in range(y):
			row.append(0)
		board.append(row)

	# Start carving from one cell inside the perimeter
	board[0][0] = 1
	carve_maze(board, 0, 0, directions)
	return board
