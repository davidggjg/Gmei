extends Node
## Top-level orchestrator: current game mode, scene transitions, pause state.

enum Mode { NONE, CAMPAIGN, BATTLE_ROYALE }

const SCENE_MAIN_MENU := "res://scenes/ui/MainMenu.tscn"
const SCENE_MANSION := "res://scenes/levels/MansionLevel.tscn"
const SCENE_BATTLE_ROYALE := "res://scenes/battle_royale/BRArena.tscn"

signal pause_state_changed(is_paused: bool)
signal mode_changed(mode: Mode)
signal player_died

var current_mode: Mode = Mode.NONE
var is_paused: bool = false

var _fade_layer: CanvasLayer
var _fade_rect: ColorRect

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_fade_layer()

func _build_fade_layer() -> void:
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100
	_fade_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_fade_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_layer.add_child(_fade_rect)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and current_mode != Mode.NONE:
		toggle_pause()

func toggle_pause() -> void:
	set_paused(not is_paused)

func set_paused(value: bool) -> void:
	is_paused = value
	get_tree().paused = value
	pause_state_changed.emit(is_paused)

func start_new_campaign() -> void:
	SaveManager.delete_save()
	current_mode = Mode.CAMPAIGN
	mode_changed.emit(current_mode)
	_goto_scene(SCENE_MANSION)

func continue_campaign() -> void:
	current_mode = Mode.CAMPAIGN
	mode_changed.emit(current_mode)
	_goto_scene(SCENE_MANSION)

func start_battle_royale() -> void:
	current_mode = Mode.BATTLE_ROYALE
	mode_changed.emit(current_mode)
	_goto_scene(SCENE_BATTLE_ROYALE)

func goto_main_menu() -> void:
	current_mode = Mode.NONE
	set_paused(false)
	mode_changed.emit(current_mode)
	_goto_scene(SCENE_MAIN_MENU)

func on_player_died() -> void:
	player_died.emit()

func restart_current_scene() -> void:
	set_paused(false)
	get_tree().reload_current_scene()

func quit_game() -> void:
	get_tree().quit()

func _goto_scene(path: String) -> void:
	set_paused(false)
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", 1.0, 0.35)
	await tween.finished
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	var tween_in := create_tween()
	tween_in.tween_property(_fade_rect, "color:a", 0.0, 0.35)
