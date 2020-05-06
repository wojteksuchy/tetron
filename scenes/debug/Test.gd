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


var main


func _input(event: InputEvent) -> void:
	if main:
		var new_position = main.pos
		var rotate_direction = null
		if event.is_action_pressed("ui_down"):
			new_position += main.cols
		if event.is_action_pressed("ui_left"):
			new_position -= 1
		if event.is_action_pressed("ui_right"):
			new_position += 1
		if event.is_action_pressed("ui_up"):
			new_position -= main.cols
		if event.is_action_pressed("ui_page_down"):
			rotate_direction = main.directions.ROTATE_LEFT
		if event.is_action_pressed("ui_page_up"):
			rotate_direction = main.directions.ROTATE_RIGHT
		if new_position != main.pos or rotate_direction != null:
			main.move_shape(new_position, rotate_direction)
			get_tree().set_input_as_handled()

func _on_AddShapeToGrid_button_down() -> void:
	main = $Main
	main.clear_grid()
	main.shape = Shapes.get_shape()
	main.pos = int($SpinBox.value)
	main.add_shape_to_grid()


func _on_RemoveShapeFromGrid_button_down() -> void:
	main.remove_shape_from_grid()


func _on_Lock_button_down() -> void:
	main.lock_shape_to_grid()
