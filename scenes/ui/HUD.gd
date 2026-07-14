extends CanvasLayer
class_name HUD

@onready var health_bar: ProgressBar = $Root/BottomLeft/HealthBar
@onready var stamina_bar: ProgressBar = $Root/BottomLeft/StaminaBar
@onready var ammo_label: Label = $Root/BottomRight/AmmoLabel
@onready var interact_prompt: Label = $Root/CenterPrompt
@onready var crosshair: Label = $Root/Crosshair
@onready var death_screen: Control = $Root/DeathScreen
@onready var death_retry_button: Button = $Root/DeathScreen/Panel/VBox/RetryButton
@onready var death_menu_button: Button = $Root/DeathScreen/Panel/VBox/MenuButton
@onready var death_title: Label = $Root/DeathScreen/Panel/VBox/Title
@onready var inventory_ui: InventoryUI = $Root/InventoryUIInstance
@onready var hit_marker: Label = $Root/HitMarker

var player: Player
var _hit_marker_tween: Tween

func _ready() -> void:
	Loc.apply_rtl($Root)
	interact_prompt.visible = false
	death_screen.visible = false
	hit_marker.visible = false
	death_title.text = Loc.t("GAME_OVER_TITLE")
	death_retry_button.text = Loc.t("GAME_OVER_RETRY")
	death_menu_button.text = Loc.t("GAME_OVER_MENU")
	death_retry_button.pressed.connect(func(): GameManager.restart_current_scene())
	death_menu_button.pressed.connect(func(): GameManager.goto_main_menu())
	GameManager.player_died.connect(_on_player_died)

func bind_player(p: Player) -> void:
	player = p
	player.health.health_changed.connect(_on_health_changed)
	player.stamina.stamina_changed.connect(_on_stamina_changed)
	player.inventory.inventory_changed.connect(_refresh_ammo)
	player.inventory.weapon_equipped.connect(func(_id): _refresh_ammo())
	player.interact_prompt_changed.connect(_on_interact_prompt_changed)
	player.shot_hit_confirmed.connect(_flash_hit_marker)
	_on_health_changed(player.health.current_health, player.health.max_health)
	_on_stamina_changed(player.stamina.current_stamina, player.stamina.max_stamina)
	_refresh_ammo()
	inventory_ui.bind_player(player)

func _on_health_changed(current: float, max_health: float) -> void:
	health_bar.max_value = max_health
	health_bar.value = current

func _on_stamina_changed(current: float, max_stamina: float) -> void:
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current

func _refresh_ammo() -> void:
	if player == null:
		return
	var weapon := player.inventory.get_equipped_weapon()
	if weapon == null:
		ammo_label.text = ""
		return
	if weapon.is_melee:
		ammo_label.text = Loc.t(weapon.name_key)
	else:
		var reserve := player.inventory.get_count(weapon.ammo_item_id)
		ammo_label.text = "%s\n%d / %d" % [Loc.t(weapon.name_key), player.inventory.current_magazine(), reserve]

func _on_interact_prompt_changed(text: String) -> void:
	interact_prompt.visible = text != ""
	interact_prompt.text = text

func _flash_hit_marker() -> void:
	hit_marker.visible = true
	hit_marker.modulate.a = 1.0
	if _hit_marker_tween:
		_hit_marker_tween.kill()
	_hit_marker_tween = create_tween()
	_hit_marker_tween.tween_property(hit_marker, "modulate:a", 0.0, 0.25)
	_hit_marker_tween.tween_callback(func(): hit_marker.visible = false)

func _on_player_died() -> void:
	if GameManager.current_mode != GameManager.Mode.CAMPAIGN:
		return # Battle Royale shows its own BRResultScreen instead
	death_screen.visible = true
	death_screen.process_mode = Node.PROCESS_MODE_ALWAYS
