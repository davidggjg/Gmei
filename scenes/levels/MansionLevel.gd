extends Node3D

const PlayerScene := preload("res://scenes/player/Player.tscn")
const HUDScene := preload("res://scenes/ui/HUD.tscn")
const PauseMenuScene := preload("res://scenes/ui/PauseMenu.tscn")

@onready var nav_region: NavigationRegion3D = $NavigationRegion3D
@onready var player_spawn: Marker3D = $PlayerSpawn
@onready var jump_scare_trigger: Area3D = $Triggers/JumpScareTrigger
@onready var jump_scare_light: OmniLight3D = $Triggers/JumpScareLight
@onready var ui_layer: CanvasLayer = $UILayer

var player: Player
var _jump_scare_fired: bool = false

func _ready() -> void:
	GameManager.current_mode = GameManager.Mode.CAMPAIGN
	await get_tree().process_frame # let the procedurally-built CSG walls register their collision
	nav_region.bake_navigation_mesh()
	_spawn_player()
	_spawn_ui()
	jump_scare_trigger.body_entered.connect(_on_jump_scare_area_entered)
	# AudioManager.play_music(preload("res://assets/audio/mansion_theme.ogg")) once a real score exists

func _spawn_player() -> void:
	player = PlayerScene.instantiate()
	add_child(player)
	if SaveManager.has_save():
		var data := SaveManager.load_game()
		player.apply_save_data(data)
	else:
		player.global_position = player_spawn.global_position
		player.rotation.y = player_spawn.rotation.y
		player.inventory.add_item(ItemDB.KNIFE, 1)

func _spawn_ui() -> void:
	var hud := HUDScene.instantiate()
	ui_layer.add_child(hud)
	hud.bind_player(player)

	var pause_menu := PauseMenuScene.instantiate()
	ui_layer.add_child(pause_menu)

func _on_jump_scare_area_entered(body: Node3D) -> void:
	if _jump_scare_fired or not body.is_in_group("player"):
		return
	_jump_scare_fired = true
	_play_jump_scare()

func _play_jump_scare() -> void:
	var tween := create_tween()
	for i in range(6):
		tween.tween_property(jump_scare_light, "light_energy", 0.0, 0.04)
		tween.tween_property(jump_scare_light, "light_energy", 4.0, 0.04)
	tween.tween_property(jump_scare_light, "light_energy", 0.6, 0.3)
