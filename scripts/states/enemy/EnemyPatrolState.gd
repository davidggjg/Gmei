extends State
class_name EnemyPatrolState

@export var wait_at_point: float = 2.0
@export var arrival_distance: float = 0.6

var enemy: EnemyBase
var _index: int = 0
var _wait_timer: float = 0.0
var _waiting: bool = false

func enter(_msg: Dictionary = {}) -> void:
	enemy = actor as EnemyBase
	_waiting = false
	_wait_timer = 0.0

func physics_update(delta: float) -> void:
	if enemy.can_see_player():
		enemy.last_known_player_position = enemy.player.global_position
		enemy.detected_player.emit()
		state_machine.transition_to("Chase")
		return
	if enemy.patrol_points.is_empty():
		state_machine.transition_to("Idle")
		return

	var target := enemy.patrol_points[_index]
	if _waiting:
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0
		_wait_timer -= delta
		if _wait_timer <= 0.0:
			_waiting = false
			_index = (_index + 1) % enemy.patrol_points.size()
		return

	enemy.move_toward_point(target, enemy.move_speed, delta)
	if enemy.global_position.distance_to(target) <= arrival_distance:
		_waiting = true
		_wait_timer = wait_at_point
