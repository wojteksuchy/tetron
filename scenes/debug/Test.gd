extends Control

var shape: ShapeData

func _on_PickShape_button_down() -> void:
	shape = Shapes.get_shape()
	$Shape.text = shape.name
	_show_grid()

func _on_RotateLeft_button_down() -> void:
	shape.rotate_left()
	_show_grid()


func _on_RotateRight_button_down() -> void:
	shape.rotate_right()
	_show_grid()


func _show_grid() -> void:
	$Grid.text = ""
	for row in shape.grid:
		for column in row:
			if column:
				$Grid.text += "x "
			else:
				$Grid.text += "_ "
		$Grid.text += "\n" # new line
