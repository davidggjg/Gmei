extends CharacterBody3D
class_name BRBot
## Ranged-combat bot for Battle Royale: loots, fights the player and other
## bots, and flees the shrinking safe zone. Stats scale with the active
## DifficultyProfile, same as the campaign enemies.

@export var base_max_health: float = 100.0
@export var base_move_speed: float = 3.3
@export var base_detection_radius: float = 26.0
@export var vision_fov_deg: float = 130.0
@export var preferred_engage_range: float = 12.0
@export var loot_search_radius: float = 30.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var inventory: Inventory = $Inventory
@onready var state_machine: StateMachine = $StateMachine
@onready var eyes: Node3D = $Eyes
@onready var body_visual: Node3D = $BotBodyVisual

var difficulty: DifficultyProfile
var move_speed: float = 3.3
var detection_radius: float = 26.0
var safe_zone: SafeZone
var current_target: Node3D = null

signal died_signal
signal killed_target(target: Node3D)

func _ready() -> void:
	add_to_group("br_bot")
	difficulty = SettingsManager.get_difficulty_profile()
	health.max_health = base_max_health * difficulty.enemy_health_mult
	move_speed = base_move_speed * difficulty.enemy_move_speed_mult
	detection_radius = base_detection_radius * difficulty.enemy_detection_radius_mult
	health.died.connect(_on_died)
	_grant_starting_loadout()

func _grant_starting_loadout() -> void:
	# Every bot drops in minimally armed (fair fight); a Shotgun is a scavenged upgrade.
	inventory.add_item(ItemDB.KNIFE, 1)
	inventory.add_item(ItemDB.HANDGUN, 1)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	inventory.add_item(ItemDB.AMMO_PISTOL, rng.randi_range(12, 30))
	inventory.equip_weapon(ItemDB.HANDGUN)

func move_toward_point(target: Vector3, speed: float, delta: float) -> void:
	nav_agent.target_position = target
	if nav_agent.is_navigation_finished():
		velocity.x = move_toward(velocity.x, 0.0, speed * 4.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, speed * 4.0 * delta)
	else:
		var next_pos := nav_agent.get_next_path_position()
		var dir := (next_pos - global_position)
		dir.y = 0.0
		dir = dir.normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		if dir.length() > 0.01:
			face_toward(global_position + dir, delta, 6.0)
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity", 13.0) * delta
	else:
		velocity.y = 0.0
	move_and_slide()

func face_toward(target: Vector3, delta: float, turn_speed: float = 6.0) -> void:
	var dir := target - global_position
	dir.y = 0.0
	if dir.length() < 0.01:
		return
	var target_yaw := atan2(dir.x, dir.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, 1.0 - exp(-turn_speed * delta))

func find_hostile_target() -> Node3D:
	var candidates: Array = []
	var player := get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player) and not player.is_dead:
		candidates.append(player)
	for bot in get_tree().get_nodes_in_group("br_bot"):
		if bot == self or not is_instance_valid(bot):
			continue
		if bot.health.is_dead:
			continue
		candidates.append(bot)

	var best: Node3D = null
	var best_dist := INF
	for c in candidates:
		if not can_see(c):
			continue
		var d := global_position.distance_to(c.global_position)
		if d < best_dist:
			best_dist = d
			best = c
	return best

func can_see(target: Node3D) -> bool:
	var to_target: Vector3 = target.global_position - eyes.global_position
	var dist := to_target.length()
	if dist > detection_radius:
		return false
	var forward := -eyes.global_transform.basis.z
	var angle := rad_to_deg(forward.angle_to(to_target.normalized()))
	if angle > vision_fov_deg * 0.5:
		return false
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(eyes.global_position, target.global_position + Vector3.UP * 0.8)
	query.collision_mask = 1 # world only - if it hits world geometry first, LOS is blocked
	query.exclude = [self]
	var result := space_state.intersect_ray(query)
	return result.is_empty()

func find_nearest_loot() -> Node3D:
	var best: Node3D = null
	var best_dist := INF
	for pickup in get_tree().get_nodes_in_group("pickup"):
		if not is_instance_valid(pickup):
			continue
		var d := global_position.distance_to(pickup.global_position)
		if d < loot_search_radius and d < best_dist:
			best_dist = d
			best = pickup
	return best

func try_fire_at(target: Node3D) -> bool:
	var weapon := inventory.get_equipped_weapon()
	if weapon == null or weapon.is_melee:
		return false
	if inventory.current_magazine() <= 0:
		inventory.reload_equipped()
		return false
	if not inventory.try_consume_round():
		return false

	var space_state := get_world_3d().direct_space_state
	var aim_point: Vector3 = target.global_position + Vector3.UP * 0.9
	var error_deg: float = difficulty.enemy_aim_error_deg
	var jitter := Vector3(
		randf_range(-error_deg, error_deg),
		randf_range(-error_deg, error_deg),
		0.0
	)
	var from := eyes.global_position
	var dir := (aim_point - from).normalized().rotated(Vector3.UP, deg_to_rad(jitter.x))
	var to := from + dir * weapon.weapon_range
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = (1 << 0) | (1 << 5) # world, hurtbox
	query.collide_with_areas = true
	query.exclude = [self, hurtbox]
	var result := space_state.intersect_ray(query)
	if result.is_empty():
		return true
	var collider = result.get("collider")
	if collider is Hurtbox:
		collider.receive_hit(weapon.damage, self)
	return true

func _on_died(_source: Node) -> void:
	state_machine.transition_to("Dead")
	died_signal.emit()
