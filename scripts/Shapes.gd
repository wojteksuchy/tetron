extends GridContainer

var _shapes := []
var _index := 0

func _ready() -> void:
	for shape in get_children():
		var data = ShapeData.new()
		data.name = shape.name
		data.color = shape.modulate
		
		var size = shape.columns
		var s2 = size/2
		data.coordinates = range(-s2, s2 + 1)
		
		if size % 2 == 0:
			data.coordinates.remove(s2)
		data.grid = _get_grid(size, shape.get_children())
		_shapes.append(data)


func get_shape() -> ShapeData:
	if _index == 0:
		_shapes.shuffle()
		_index = _shapes.size()
	_index -= 1
	var shape_data = ShapeData.new()
	shape_data.name = _shapes[_index].name
	shape_data.color = _shapes[_index].color
	shape_data.coordinates = _shapes[_index].coordinates
	shape_data.grid = _shapes[_index].grid
	return shape_data


func _get_grid(number_of_columns :int, cells :Array) -> Array:
	var grid := []
	var row := []
	var index := 0
	for cell in cells:
		row.append(cell.modulate.a > 0.1)
		index += 1
		if index == number_of_columns:
			grid.append(row)
			index = 0
			row = []
	return grid	
		
		
		
		
