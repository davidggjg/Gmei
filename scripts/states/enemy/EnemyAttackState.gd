extends State
class_name EnemyAttackState

var enemy: EnemyBase
var _phase: String = "windup"
var _timer: float = 0.0

func enter(_msg: Dictionary = {}) -> void:
	enemy = actor as EnemyBase
	_phase = "windup"
	_timer = enemy.difficulty.enemy_reaction_time
	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

func physics_update(delta: float) -> void:
	if enemy.player == null or not is_instance_valid(enemy.player):
		state_machine.transition_to("Patrol")
		return

	enemy.face_toward(enemy.player.global_position, delta, 8.0)

	if enemy.distance_to_player() > enemy.attack_range * 1.6:
		state_machine.transition_to("Chase")
		return

	_timer -= delta
	if _timer > 0.0:
		return

	if _phase == "windup":
		enemy.perform_attack()
		_phase = "cooldown"
		_timer = enemy.attack_cooldown
	else:
		if enemy.distance_to_player() <= enemy.attack_range:
			_phase = "windup"
			_timer = enemy.difficulty.enemy_reaction_time
		else:
			state_machine.transition_to("Chase")
