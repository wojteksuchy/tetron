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
const WAIT_TIME = 0.15
const REPEAT_DELAY = 0.05
const FILE_NAME = "user://tetron.json"

var state  = states.STOPPED

var gui 
var music_position = 0.0
var grid = []
var cols 
var shape: ShapeData
var next_shape: ShapeData
var pos = 0 #grid_position
var count = 0
var bonus = 0

func _ready() -> void:
	gui = $GUI
	gui.connect("button_pressed", self, "_button_pressed")
	gui.set_button_states(ENABLED)
	cols = gui.grid.get_columns()
	gui.reset_stats()
	load_game()
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
			if shape.grid[y][x]:
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
					$SoundPlayer.volume_db = gui.sound
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


func _input(event: InputEvent) -> void:
	if state == states.PLAYING:
		if event.is_action_pressed("ui_page_up"):
			incrase_level()
		if event.is_action_pressed("ui_down"):
			bonus = 2
			soft_drop()
		if event.is_action_released("ui_down"):
			bonus = 0
			normal_drop()
		if event.is_action_pressed("ui_accept"):
			hard_drop()
		if event.is_action_pressed("ui_left"):
			move_left()
			$LeftTimer.start(WAIT_TIME)
		if event.is_action_released("ui_left"):
			$LeftTimer.stop()
		if event.is_action_pressed("ui_right"):
			move_right()
			$RightTimer.start(WAIT_TIME)
		if event.is_action_released("ui_right"):
			$RightTimer.stop()
		if event.is_action_pressed("ui_up"):
			if event.shift:
				move_shape(pos, directions.ROTATE_RIGHT)
			else:
				move_shape(pos, directions.ROTATE_LEFT)
		if event.is_action_pressed("ui_cancel"):
			_game_over()
		if event is InputEventKey:
			get_tree().set_input_as_handled()



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
	save_game()


func add_to_score(rows) -> void:
	gui.lines += rows
	var score = 10 * int(pow(2, rows - 1))
	print("Added %d to score" % score)
	gui.score += score
	update_high_score()


func update_high_score() -> void:
	if gui.score > gui.high_score:
		gui.high_score = gui.score


func move_left() -> void:
	if pos % cols > 0:
		move_shape(pos - 1)


func move_right() -> void:
	if pos % cols < cols - 1:
		move_shape(pos + 1)


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
		pause_game()
		if _is_music_on():
			_music(states.PAUSE)
	else:
		gui.set_button_text("Pause", "Pause")
		state = states.PLAYING
		pause_game(false)
		if _is_music_on():
			_music(states.PLAY)

func pause_game(value = true) -> void:
	get_tree().paused = value


func check_rows() -> void:
	var i = grid.size() - 1
	var x = 0
	var row_number = grid.size() / cols - 1
	var rows = []
	while i >= 0:
		if grid[i]:
			x += 1
			i -= 1
			if x == cols: # complete row found
				rows.append(row_number)
				x = 0
				row_number -= 1
		else:
			# empty cell found
			i += x # set i to right-most column
			x = 0
			i -= cols # move i to next row
			row_number -= 1
	if rows.empty() == false:
		remove_rows(rows)


func remove_rows(rows) -> void:
		var rows_moved = 0
		add_to_score(rows.size())
		pause_game()
		if _is_sound_on():
			$SoundPlayer.play()
		yield(get_tree().create_timer(0.3), "timeout")
		pause_game(false)
		remove_shape_from_grid()
		for row_count in rows.size():	
			# Hide cells
			for n in cols:
				gui.grid.get_child((rows[row_count] + rows_moved) * cols + n).modulate = Color(0)
			# Move cells to fill the gap
			var to = (rows[row_count] + rows_moved) * cols + cols - 1
			var from = to - cols 
			while from >= 0:
				grid[to] = grid[from]
				gui.grid.get_child(to).modulate = gui.grid.get_child(from).modulate
				if from == 0: # Clear the top row
					grid[from] = false
					gui.grid.get_child(from).modulate = Color(0)
				from -= 1
				to -= 1
			rows_moved += 1
		add_shape_to_grid()


func _on_Ticker_timeout() -> void:
	var new_position = pos + cols
	if move_shape(new_position):
		gui.score += bonus
		update_high_score()
	else:
		if new_position <= END_POS:
			_game_over()
		else:
			lock_shape_to_grid()
			check_rows()
			new_shape()


func save_game() -> void:
	var data = {
		"music": gui.music,
		"sound": gui.sound,
		"high_score": gui.high_score
	}
	var file = File.new()
	file.open(FILE_NAME, File.WRITE)
	file.store_string(to_json(data))
	file.close()


func load_game() -> void:
	var file = File.new()
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		gui.settings(data)
		file.close()


func _on_LeftTimer_timeout() -> void:
	$LeftTimer.wait_time = REPEAT_DELAY
	move_left()


func _on_RightTimer_timeout() -> void:
	$RightTimer.wait_time = REPEAT_DELAY
	move_right()
