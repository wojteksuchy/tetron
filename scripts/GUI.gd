extends CenterContainer



var music := -20
var sound := -20
var min_volume

var level = 1 setget set_level
var score = 0 setget set_score
var lines = 0 setget set_lines
var high_score = 0 setget set_high_score

var grid: GridContainer
var next: GridContainer
var number_of_cells := 200


signal button_pressed(button_name)

func _ready() -> void:
	grid = find_node("Grid")
	next = find_node("NextShape")
	min_volume = find_node("Music").get_min()
	find_node("Sound").set_min(min_volume)
	add_cells(grid, number_of_cells)
	clear_all_cells()


func set_level(value) -> void:
	find_node("Level").text = str(value)
	level = value


func set_score(value) -> void:
	find_node("Score").text = str(value)
	score = value


func set_high_score(value) -> void:
	find_node("HighScore").text = "%08d" % value
	high_score = value


func set_lines(value) -> void:
	find_node("Lines").text = str(value)
	lines = value


func set_next_shape(shape: ShapeData) -> void:
	clear_cells(next)
	var i = 0
	for column in shape.coordinates.size():
		for row in [0,1]:
			if shape.grid[row][column]:
				next.get_child(i).modulate = shape.color
			i += 1


func reset_stats(_high_score = 0, _score = 0, _lines = 0, _level = 1) -> void:
	self.high_score = _high_score
	self.score = _score
	self.lines = _lines
	self.level = _level


func settings(data) -> void:
	self.high_score = data.high_score
	find_node("Music").value = data.music
	find_node("Sound").value = data.sound


func add_cells(grid_node: GridContainer, how_many_cells: int ) -> void:
	var number_cells = grid_node.get_child_count() # how many cells is onready in grid
	while number_cells < how_many_cells:
		grid_node.add_child(grid_node.get_child(0).duplicate())
		number_cells += 1

func clear_all_cells() -> void:
	clear_cells(grid)
	clear_cells(next)


func clear_cells(grid_node: GridContainer) -> void:
	for cell in grid_node.get_children():
		cell.modulate.a = 0.0


func set_button_state(button: String, state: bool) -> void:
	find_node(button).set_disabled(state)


func set_button_text(button: String, text: String) -> void:
	find_node(button).set_text(text)


func set_button_states(playing: bool) -> void:
	set_button_state("NewGame", playing)
	set_button_state("About", playing)
	set_button_state("Pause", !playing)


func _on_NewGame_button_down() -> void:
	emit_signal("button_pressed", "NewGame")


func _on_Pause_button_down() -> void:
	emit_signal("button_pressed", "Pause")


func _on_About_button_down() -> void:
	$AboutBox.popup_centered()
	emit_signal("button_pressed", "About")
	set_button_state("About", true)


func _on_AboutBox_popup_hide() -> void:
	set_button_state("About", false)


func _on_Music_value_changed(value: float) -> void:
	music = value
	emit_signal("button_pressed", "Music")


func _on_Sound_value_changed(value: float) -> void:
	sound = value
	emit_signal("button_pressed", "Sound")
