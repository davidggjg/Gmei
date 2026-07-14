extends State
class_name BREngageState

const LOSE_SIGHT_GRACE: float = 3.0

var bot: BRBot
var _fire_cooldown: float = 0.0
var _lost_sight_timer: float = 0.0
var _strafe_dir: float = 1.0

func enter(_msg: Dictionary = {}) -> void:
	bot = actor as BRBot
	_fire_cooldown = 0.0
	_lost_sight_timer = 0.0
	_strafe_dir = 1.0 if randf() < 0.5 else -1.0

func physics_update(delta: float) -> void:
	var target := bot.current_target
	if target == null or not is_instance_valid(target) or _target_is_dead(target):
		state_machine.transition_to("Roam")
		return

	if _is_far_outside_zone():
		state_machine.transition_to("FleeZone")
		return

	if bot.can_see(target):
		_lost_sight_timer = 0.0
	else:
		_lost_sight_timer += delta
		if _lost_sight_timer >= LOSE_SIGHT_GRACE:
			state_machine.transition_to("Roam")
			return

	bot.face_toward(target.global_position, delta, 10.0)

	var dist := bot.global_position.distance_to(target.global_position)
	var weapon := bot.inventory.get_equipped_weapon()
	var preferred: float = bot.preferred_engage_range if weapon and not weapon.is_melee else 1.4

	var move_target: Vector3
	if dist > preferred + 2.0:
		move_target = target.global_position
	elif dist < preferred - 2.0:
		move_target = bot.global_position + (bot.global_position - target.global_position).normalized() * 3.0
	else:
		var side := (target.global_position - bot.global_position).normalized().cross(Vector3.UP) * _strafe_dir
		move_target = bot.global_position + side * 3.0
	bot.move_toward_point(move_target, bot.move_speed, delta)

	_fire_cooldown -= delta
	if _fire_cooldown <= 0.0 and bot.can_see(target):
		if bot.try_fire_at(target):
			var rate: float = weapon.fire_rate if weapon else 1.0
			_fire_cooldown = 1.0 / maxf(rate, 0.1)

func _target_is_dead(target: Node3D) -> bool:
	if target.has_node("Health"):
		return (target.get_node("Health") as Health).is_dead
	return false

func _is_far_outside_zone() -> bool:
	if bot.safe_zone == null:
		return false
	var flat := Vector2(bot.global_position.x, bot.global_position.z)
	return flat.length() > bot.safe_zone.current_radius + 6.0
