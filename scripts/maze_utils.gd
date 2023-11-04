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

# Flood fill algorithm to mark all reachable cells.
func flood_fill(board, x, y, visited):
	if x < 0 or x >= len(board) or y < 0 or y >= len(board[0]) or board[x][y] == 0 or visited[x][y] == 0:
		return
	visited[x][y] = 0
	flood_fill(board, x + 1, y, visited)
	flood_fill(board, x - 1, y, visited)
	flood_fill(board, x, y + 1, visited)
	flood_fill(board, x, y - 1, visited)

# Function to connect the nearest unvisited cell to the visited section.
func connect_sections(board, unvisited):
	for x in range(len(board)):
		for y in range(len(board[0])):
			if not unvisited[x][y]:
				continue
			for dir in [[1, 0], [-1, 0], [0, 1], [0, -1]]:
				var new_x = x + dir[0]
				var new_y = y + dir[1]
				if 0 <= new_x and new_x < len(board) and 0 <= new_y and new_y < len(board[0]) and board[new_x][new_y] == 1:
					board[x][y] = 1
					return # We connect one unvisited cell at a time for simplicity

# Fix the maze to make all paths connected.
func fix_maze(board):
	var visited = []
	for i in range(len(board)):
		visited.append([])
		for j in range(len(board[0])):
			visited[i].append(1)

	flood_fill(board, 0, 0, visited)
	print_grid(board)
	print_grid(visited)
	# Check for any cell that is not visited and connect it.
	var all_connected = false
#	while not all_connected:
#		all_connected = true
#		for i in range(len(board)):
#			for j in range(len(board[0])):
#				if not visited[i][j] and board[i][j] == 1:
#					connect_sections(board, visited)
#					flood_fill(board, i, j, visited)
#					all_connected = false
#					break
#			if not all_connected:
#				break
	return board

func print_grid(board):
	var horizontal_line = ""
	for x in range(len(board)+1):
		horizontal_line += "##"
	horizontal_line += "\n"
	var output = horizontal_line
	for i in range(len(board)):
		output += "#"
		for j in range(len(board[i])):
			var cell
			if board[j][i] == 1:
				cell = "  "
			else:
				cell = "##" 
			output += cell
		output += "#\n"
	output += horizontal_line
	print(output)
#
