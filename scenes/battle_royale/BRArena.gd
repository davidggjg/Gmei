extends Node3D

const PlayerScene := preload("res://scenes/player/Player.tscn")
const HUDScene := preload("res://scenes/ui/HUD.tscn")
const PauseMenuScene := preload("res://scenes/ui/PauseMenu.tscn")
const BotScene := preload("res://scenes/battle_royale/BRBot.tscn")
const ResultScreenScene := preload("res://scenes/battle_royale/BRResultScreen.tscn")
const PickupScene := preload("res://scenes/items/Pickup.tscn")

const LOOT_SEED := 42017
const LOOT_TABLE := [
	{"id": "ammo_pistol", "count": 20}, {"id": "ammo_pistol", "count": 14},
	{"id": "ammo_shotgun", "count": 8}, {"id": "shotgun", "count": 1},
	{"id": "ammo_rifle", "count": 30}, {"id": "ammo_rifle", "count": 20}, {"id": "rifle", "count": 1},
	{"id": "herb_green", "count": 2}, {"id": "first_aid", "count": 1},
	{"id": "handgun", "count": 1}, {"id": "ammo_pistol", "count": 25},
]

@export var bot_count: int = 7
@export var spawn_radius: float = 45.0
@export var loot_count: int = 26
@export var loot_scatter_radius: float = 55.0

@onready var nav_region: NavigationRegion3D = $NavigationRegion3D
@onready var safe_zone: SafeZone = $SafeZone
@onready var alive_label: Label = $UILayer/Root/AliveLabel
@onready var zone_label: Label = $UILayer/Root/ZoneLabel

var player: Player
var bots: Array = []
var result_screen: BRResultScreen
var _match_over: bool = false

func _ready() -> void:
	GameManager.current_mode = GameManager.Mode.BATTLE_ROYALE
	await get_tree().process_frame
	nav_region.bake_navigation_mesh()
	_spawn_loot()
	_spawn_player()
	_spawn_bots()
	_spawn_ui()

	safe_zone.register_actor(player, player.health)
	safe_zone.shrink_started.connect(_on_zone_shrink_started)
	player.health.died.connect(func(_s): _check_match_end())

	_update_alive_label()

func _spawn_player() -> void:
	player = PlayerScene.instantiate()
	add_child(player)
	player.global_position = Vector3(0, 0.2, 0)
	player.inventory.add_item(ItemDB.KNIFE, 1)

func _spawn_bots() -> void:
	for i in range(bot_count):
		var bot: BRBot = BotScene.instantiate()
		add_child(bot)
		var angle: float = (TAU / float(bot_count)) * i
		var dist: float = randf_range(spawn_radius * 0.5, spawn_radius)
		bot.global_position = Vector3(cos(angle) * dist, 0.2, sin(angle) * dist)
		bot.safe_zone = safe_zone
		safe_zone.register_actor(bot, bot.health)
		bot.died_signal.connect(_on_bot_died)
		bots.append(bot)

func _spawn_loot() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = LOOT_SEED
	for i in range(loot_count):
		var entry: Dictionary = LOOT_TABLE[rng.randi() % LOOT_TABLE.size()]
		var pickup := PickupScene.instantiate()
		pickup.item_id = entry["id"]
		pickup.count = entry["count"]
		var angle := rng.randf_range(0, TAU)
		var dist := rng.randf_range(6.0, loot_scatter_radius)
		add_child(pickup)
		pickup.global_position = Vector3(cos(angle) * dist, 0.1, sin(angle) * dist)

func _spawn_ui() -> void:
	var hud := HUDScene.instantiate()
	add_child(hud)
	hud.bind_player(player)

	var pause_menu := PauseMenuScene.instantiate()
	add_child(pause_menu)

	result_screen = ResultScreenScene.instantiate()
	add_child(result_screen)

func _on_bot_died(_bot: Node) -> void:
	_update_alive_label()
	_check_match_end()

func _alive_bots() -> Array:
	return bots.filter(func(b): return is_instance_valid(b) and not b.health.is_dead)

func _update_alive_label() -> void:
	var total_alive: int = _alive_bots().size() + (0 if player.health.is_dead else 1)
	alive_label.text = "%s: %d" % [Loc.t("HUD_PLAYERS_ALIVE"), total_alive]

func _check_match_end() -> void:
	if _match_over:
		return
	var alive_bots := _alive_bots()
	if player.health.is_dead:
		_match_over = true
		get_tree().paused = true
		result_screen.show_result(false, alive_bots.size() + 1, bot_count + 1)
	elif alive_bots.is_empty():
		_match_over = true
		get_tree().paused = true
		result_screen.show_result(true, 1, bot_count + 1)

func _on_zone_shrink_started(_target_radius: float, duration: float) -> void:
	zone_label.text = Loc.t("BR_ZONE_SHRINKING")
	zone_label.visible = true
	get_tree().create_timer(duration).timeout.connect(func():
		if is_instance_valid(zone_label):
			zone_label.visible = false
	)
