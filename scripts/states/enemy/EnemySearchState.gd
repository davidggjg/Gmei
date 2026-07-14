extends State
class_name EnemySearchState

@export var arrival_distance: float = 0.7
@export var look_around_speed: float = 0.6

var enemy: EnemyBase
var _search_timer: float = 0.0
var _arrived: bool = false

func enter(_msg: Dictionary = {}) -> void:
	enemy = actor as EnemyBase
	_search_timer = enemy.difficulty.enemy_search_duration
	_arrived = false

func physics_update(delta: float) -> void:
	if enemy.can_see_player():
		enemy.last_known_player_position = enemy.player.global_position
		state_machine.transition_to("Chase")
		return

	if not _arrived:
		enemy.move_toward_point(enemy.last_known_player_position, enemy.move_speed, delta)
		if enemy.global_position.distance_to(enemy.last_known_player_position) <= arrival_distance:
			_arrived = true
		return

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0
	enemy.rotate_y(look_around_speed * delta)
	_search_timer -= delta
	if _search_timer <= 0.0:
		if enemy.patrol_points.size() > 0:
			state_machine.transition_to("Patrol")
		else:
			state_machine.transition_to("Idle")
