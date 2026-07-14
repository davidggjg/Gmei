extends Node
## Persisted player-facing settings (camera mode, difficulty, audio, controls).
## Stored as a plain ConfigFile under user:// so it works identically on
## desktop (for testing) and Android.

signal settings_changed

const SETTINGS_PATH := "user://settings.cfg"

const CAMERA_FIRST_PERSON := "first_person"
const CAMERA_THIRD_PERSON := "third_person"

var camera_mode: String = CAMERA_FIRST_PERSON
var difficulty_id: String = "normal"
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var mouse_sensitivity: float = 0.25
var touch_sensitivity: float = 0.35
var invert_y: bool = false
var show_touch_controls: bool = true
var flashlight_hold_mode: bool = false

func _ready() -> void:
	load_settings()

func load_settings() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SETTINGS_PATH)
	if err != OK:
		save_settings() # first run: write defaults
		return
	camera_mode = cfg.get_value("video", "camera_mode", camera_mode)
	difficulty_id = cfg.get_value("gameplay", "difficulty_id", difficulty_id)
	music_volume = cfg.get_value("audio", "music_volume", music_volume)
	sfx_volume = cfg.get_value("audio", "sfx_volume", sfx_volume)
	mouse_sensitivity = cfg.get_value("controls", "mouse_sensitivity", mouse_sensitivity)
	touch_sensitivity = cfg.get_value("controls", "touch_sensitivity", touch_sensitivity)
	invert_y = cfg.get_value("controls", "invert_y", invert_y)
	show_touch_controls = cfg.get_value("controls", "show_touch_controls", show_touch_controls)
	flashlight_hold_mode = cfg.get_value("controls", "flashlight_hold_mode", flashlight_hold_mode)

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("video", "camera_mode", camera_mode)
	cfg.set_value("gameplay", "difficulty_id", difficulty_id)
	cfg.set_value("audio", "music_volume", music_volume)
	cfg.set_value("audio", "sfx_volume", sfx_volume)
	cfg.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	cfg.set_value("controls", "touch_sensitivity", touch_sensitivity)
	cfg.set_value("controls", "invert_y", invert_y)
	cfg.set_value("controls", "show_touch_controls", show_touch_controls)
	cfg.set_value("controls", "flashlight_hold_mode", flashlight_hold_mode)
	cfg.save(SETTINGS_PATH)

func set_camera_mode(mode: String) -> void:
	camera_mode = mode
	save_settings()
	settings_changed.emit()

func set_difficulty(id: String) -> void:
	difficulty_id = id
	save_settings()
	settings_changed.emit()

func get_difficulty_profile() -> DifficultyProfile:
	return DifficultyDB.get_profile(difficulty_id)

func reset_to_defaults() -> void:
	camera_mode = CAMERA_FIRST_PERSON
	difficulty_id = "normal"
	music_volume = 0.8
	sfx_volume = 1.0
	mouse_sensitivity = 0.25
	touch_sensitivity = 0.35
	invert_y = false
	show_touch_controls = true
	flashlight_hold_mode = false
	save_settings()
	settings_changed.emit()
