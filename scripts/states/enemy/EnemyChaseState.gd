extends State
class_name EnemyChaseState

const LOSE_SIGHT_GRACE: float = 2.0

var enemy: EnemyBase
var _lost_sight_timer: float = 0.0

func enter(_msg: Dictionary = {}) -> void:
	enemy = actor as EnemyBase
	_lost_sight_timer = 0.0

func physics_update(delta: float) -> void:
	if enemy.player == null or not is_instance_valid(enemy.player):
		state_machine.transition_to("Patrol")
		return

	if enemy.distance_to_player() <= enemy.attack_range:
		state_machine.transition_to("Attack")
		return

	if enemy.can_see_player():
		enemy.last_known_player_position = enemy.player.global_position
		_lost_sight_timer = 0.0
	else:
		_lost_sight_timer += delta
		if _lost_sight_timer >= LOSE_SIGHT_GRACE:
			enemy.lost_player.emit()
			state_machine.transition_to("Search")
			return

	enemy.move_toward_point(enemy.last_known_player_position, enemy.chase_speed, delta)
