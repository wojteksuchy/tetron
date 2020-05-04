extends Node

class_name ShapeData

var color: Color 
var grid: Array 
var coordinates: Array #local coordinates


func rotate_left() -> void:
	_rotate_grid(1, -1)


func rotate_right() -> void:
	_rotate_grid(-1, 1)


func _rotate_grid(sign_of_x: int, sign_of_y: int) -> void:
	var rotate_grid = grid.duplicate(true)
	for x in coordinates:
		for y in coordinates:
			# Map x and y to array
			var x1 = coordinates.find(x)
			var y1 = coordinates.find(y)
			var x2 = coordinates.find(sign_of_y * y)
			var y2 = coordinates.find(sign_of_x * x)
			rotate_grid[y1][x1] = grid[y2][x2]
	grid = rotate_grid
