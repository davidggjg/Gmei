extends State
class_name EnemyIdleState

@export var idle_duration: float = 2.5

var enemy: EnemyBase
var _timer: float = 0.0

func enter(_msg: Dictionary = {}) -> void:
	enemy = actor as EnemyBase
	_timer = 0.0
	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0
	enemy.play_anim("idle")

func physics_update(delta: float) -> void:
	if enemy.can_see_player():
		enemy.last_known_player_position = enemy.player.global_position
		enemy.detected_player.emit()
		state_machine.transition_to("Chase")
		return
	_timer += delta
	if _timer >= idle_duration:
		if enemy.patrol_points.size() > 0:
			state_machine.transition_to("Patrol")
		else:
			_timer = 0.0
