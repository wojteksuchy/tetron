extends CenterContainer

enum states {STOPPED, PLAYING, PAUSED, STOP, PLAY, PAUSE}
enum directions{ROTATE_LEFT, ROTATE_RIGHT}


const DISABLED = true
const ENABLED = false
const MIN_AUDIO_LEVEL = -24
const START_POS = 5
const END_POS = 25
const TICK_SPEED = 1.0
const FAST_MULTIPLE = 10
const MAX_LEVEL = 100

var state  = states.STOPPED

var gui 
var music_position = 0.0
var grid = []
var cols 
onready var shape: ShapeData
var next_shape: ShapeData
var pos = 0 #grid_position
var count = 0

func _ready() -> void:
	gui = $GUI
	gui.connect("button_pressed", self, "_button_pressed")
	gui.set_button_states(ENABLED)
	cols = gui.grid.get_columns()
	gui.reset_stats()
	randomize()


func clear_grid() -> void:
	grid.clear()
	grid.resize(gui.grid.get_child_count())
	for i in grid.size():
		grid[i] = false
	gui.clear_all_cells()





func move_shape(new_position, rotate_direction = null) -> bool:
	remove_shape_from_grid()
	# rotate and store undo direction
	rotate_direction = rotate(rotate_direction)
	# update position if we can place shape else undo rotation
	var ok = place_shape(new_position)
	if ok:
		pos = new_position
	else:
		rotate(rotate_direction)
	add_shape_to_grid()
	return ok


func rotate(rotate_direction) -> int:
	match rotate_direction:
		directions.ROTATE_LEFT:
			shape.rotate_left()
			rotate_direction = directions.ROTATE_RIGHT
		directions.ROTATE_RIGHT:
			shape.rotate_right()
			rotate_direction = directions.ROTATE_LEFT
	return rotate_direction


func add_shape_to_grid() -> void:
	place_shape(pos, true, false, shape.color)


func remove_shape_from_grid() -> void:
	place_shape(pos, true)


func lock_shape_to_grid() -> void:
	place_shape(pos, false, true)


func place_shape(index, add_tiles = false, lock = false, color = Color(0)) -> bool:
	var ok = true
	var size = shape.coordinates.size() # size of the shape 
	var offset = shape.coordinates[0]
	var y = 0
	while y < size and ok:
		for x in size:
			if shape.grid[x][y]:
				var grid_position = index + (y + offset) * cols + x + offset
				if lock:
					grid[grid_position] = true
				else:
					var gx = index % cols + x + offset
					if gx < 0 or gx >= cols or grid_position >= grid.size() or grid_position >= 0 and grid[grid_position]:
						ok = !ok
						break
					if add_tiles and grid_position >=0:
						gui.grid.get_child(grid_position).modulate = color
		y += 1
	return ok

func _button_pressed(button_name) -> void:
	match button_name:
		"NewGame":
			gui.set_button_states(DISABLED)
			_start_game()
			#yield(get_tree().create_timer(3.0), "timeout")
			#_game_over()
		"Pause":
			_pause()
		"Music":
			if state == states.PLAYING:
				if _is_music_on():
					_music(states.PLAY)
				else:
					_music(states.STOP)
		"Sound":
			if state == states.PLAYING:
				if _is_sound_on():
					_sound(states.PLAY)
				else:
					_sound(states.STOP)
		"About":
			gui.set_button_state("About", DISABLED)


func _start_game() -> void:
	print("game playing")
	state = states.PLAYING
	music_position = 0.0
	if _is_music_on():
		_music(states.PLAY)
	clear_grid()
	gui.reset_stats(gui.high_score)
	new_shape()


func new_shape() -> void:
	if next_shape:
		shape = next_shape
	else:
		shape = Shapes.get_shape()
	next_shape = Shapes.get_shape()
	gui.set_next_shape(next_shape)
	pos = START_POS
	add_shape_to_grid()
	normal_drop()
	level_up()


func level_up() -> void:
	count += 1
	if count % 10 == 0:
		incrase_level()


func incrase_level() -> void:
	if gui.level < MAX_LEVEL:
		gui.level += 1
		$Ticker.set_wait_time(TICK_SPEED / gui.level)


func normal_drop() -> void:
	$Ticker.start(TICK_SPEED / gui.level)


func soft_drop() -> void:
	$Ticker.stop()
	$Ticker.start(TICK_SPEED / gui.level / FAST_MULTIPLE)


func hard_drop() -> void:
	$Ticker.stop()
	$Ticker.start(TICK_SPEED / MAX_LEVEL)


func _game_over() -> void:
	$Ticker.stop()
	gui.set_button_states(ENABLED)
	if _is_music_on():
		_music(states.STOP)
	state = states.STOPPED
	print("game stopped")


func add_to_score(rows) -> void:
	gui.lines += rows
	var score = 10 * int(pow(2, rows - 1))
	print("Added %d to score" % score)
	gui.score += score
	update_high_score()


func update_high_score() -> void:
	if gui.score > gui.high_score:
		gui.high_score = gui.score


func _music(action) -> void:
	if action == states.PLAY:
		$MusicPlayer.volume_db = gui.music
		if !$MusicPlayer.is_playing():
			$MusicPlayer.play(music_position)
		print("Music on. Level: %d", gui.music)
	else:
		music_position = $MusicPlayer.get_playback_position()
		$MusicPlayer.stop()
		print("Music off")


func _is_music_on() -> bool:
	return gui.music > gui.min_volume


func _is_sound_on() -> bool:
	return gui.sound > gui.min_volume


func _sound(action) -> void:
	if action == states.PLAY:
		print("Sound on. Level: %d", gui.sound)
	else:
		print("Sound off")


func _pause() -> void:
	if state == states.PLAYING:
		gui.set_button_text("Pause", "Resume")
		state = states.PAUSED
		if _is_music_on():
			_music(states.PAUSE)
	else:
		gui.set_button_text("Pause", "Pause")
		state = states.PLAYING
		if _is_music_on():
			_music(states.PLAY)

func _pause_game() -> void:
	pass






























