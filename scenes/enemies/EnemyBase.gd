extends CharacterBody3D
class_name EnemyBase
## Shared brain/body for every campaign enemy. Concrete behaviour lives in
## State children of the StateMachine node (see scripts/states/enemy/).
## Stats are scaled by the active DifficultyProfile at spawn time.

@export var display_name_key: String = "ENEMY_STALKER_NAME"
@export var base_max_health: float = 80.0
@export var base_patrol_speed: float = 1.6
@export var base_chase_speed: float = 3.4
@export var base_attack_damage: float = 14.0
@export var attack_range: float = 1.7
@export var attack_cooldown: float = 1.3
@export var base_detection_radius: float = 9.0
@export var vision_fov_deg: float = 110.0
@export var patrol_route_path: NodePath

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = $Hitbox
@onready var state_machine: StateMachine = $StateMachine
@onready var eyes: Node3D = $Eyes

var difficulty: DifficultyProfile
var player: Node3D
var last_known_player_position: Vector3 = Vector3.ZERO
var patrol_points: Array[Vector3] = []

var move_speed: float = 1.6
var chase_speed: float = 3.4
var detection_radius: float = 9.0
var attack_damage: float = 14.0

signal detected_player
signal lost_player
signal died_signal

func _ready() -> void:
	add_to_group("enemy")
	difficulty = SettingsManager.get_difficulty_profile()
	health.max_health = base_max_health * difficulty.enemy_health_mult
	health.start_at_max = true
	move_speed = base_patrol_speed * difficulty.enemy_move_speed_mult
	chase_speed = base_chase_speed * difficulty.enemy_move_speed_mult
	detection_radius = base_detection_radius * difficulty.enemy_detection_radius_mult
	attack_damage = base_attack_damage * difficulty.enemy_damage_mult
	hitbox.damage = attack_damage
	hitbox.owner_actor = self

	player = get_tree().get_first_node_in_group("player")
	health.died.connect(_on_died)
	_collect_patrol_points()

func _collect_patrol_points() -> void:
	if patrol_route_path == NodePath():
		return
	var route := get_node_or_null(patrol_route_path)
	if route == null:
		return
	for child in route.get_children():
		if child is Node3D:
			patrol_points.append(child.global_position)

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

func face_toward(target: Vector3, delta: float, turn_speed: float = 5.0) -> void:
	var dir := target - global_position
	dir.y = 0.0
	if dir.length() < 0.01:
		return
	var target_yaw := atan2(dir.x, dir.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, 1.0 - exp(-turn_speed * delta))

func can_see_player() -> bool:
	if player == null or not is_instance_valid(player):
		return false
	var to_player := player.global_position - eyes.global_position
	var dist := to_player.length()
	if dist > detection_radius:
		return false
	var forward := -eyes.global_transform.basis.z
	var angle := rad_to_deg(forward.angle_to(to_player.normalized()))
	if angle > vision_fov_deg * 0.5:
		return false
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(eyes.global_position, player.global_position + Vector3.UP * 0.8)
	query.collision_mask = (1 << 0) | (1 << 1) # world + player
	query.exclude = [self]
	var result := space_state.intersect_ray(query)
	if result.is_empty():
		return true # nothing blocking, and player is within range/fov
	var collider = result.get("collider")
	return collider is Node and collider.is_in_group("player")

func distance_to_player() -> float:
	if player == null or not is_instance_valid(player):
		return INF
	return global_position.distance_to(player.global_position)

func perform_attack() -> void:
	hitbox.activate()
	get_tree().create_timer(0.25).timeout.connect(hitbox.deactivate)

func _on_died(_source: Node) -> void:
	state_machine.transition_to("Dead")
	died_signal.emit()
