extends Node2D

enum states {STOPPED, PLAYING, PAUSED, STOP, PLAY, PAUSE}

const DISABLED := true
const ENABLED := false
const MIN_AUDIO_LEVEL := -24


var gui: Node
var state :int = states.STOPPED
var music_position := 0.0


func _ready() -> void:
	gui = $GUI
	gui.connect("button_pressed", self, "_button_pressed")
	gui.set_button_states(ENABLED)


func _button_pressed(button_name) -> void:
	match button_name:
		"NewGame":
			gui.set_button_states(DISABLED)
			_start_game()
			yield(get_tree().create_timer(3.0), "timeout")
			_game_over()
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


func _game_over() -> void:
	gui.set_button_states(ENABLED)
	if _is_music_on():
		_music(states.STOP)
	state = states.STOPPED
	print("game stopped")


func _music(action: int) -> void:
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


func _sound(action: int) -> void:
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






























