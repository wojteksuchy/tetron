extends CenterContainer

const CELL_CLEAR_BACKGROUND1 := Color(0.1, 0.1, 0.1)
const CELL_CLEAR_BACKGROUND2 := Color(0) #Black

var grid: GridContainer
var next: GridContainer
var number_of_cells := 200
#onready var next := find_node("NextShape")

signal button_pressed(button_name)

func _ready() -> void:
	grid = find_node("Grid")
	next = find_node("NextShape")
	add_cells(grid, number_of_cells)
	clear_cells(grid, CELL_CLEAR_BACKGROUND1)
	clear_cells(next, CELL_CLEAR_BACKGROUND2)

func add_cells(grid_node: GridContainer, how_many_cells: int ) -> void:
	var number_cells = grid_node.get_child_count() # how many cells is onready in grid
	while number_cells < how_many_cells:
		grid_node.add_child(grid_node.get_child(0).duplicate())
		number_cells += 1

func clear_cells(grid_node: GridContainer, color: Color) -> void:
	for cell in grid_node.get_children():
		cell.modulate = color


func _on_NewGame_button_down() -> void:
	emit_signal("button_pressed", "NewGame")


func _on_Pause_button_down() -> void:
	emit_signal("button_pressed", "Pause")


func _on_Music_button_down() -> void:
	emit_signal("button_pressed", "Music")


func _on_About_button_down() -> void:
	$AboutBox.popup_centered()
	emit_signal("button_pressed", "About")

