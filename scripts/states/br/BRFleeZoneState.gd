extends State
class_name BRFleeZoneState

var bot: BRBot

func enter(_msg: Dictionary = {}) -> void:
	bot = actor as BRBot

func physics_update(delta: float) -> void:
	if bot.safe_zone == null:
		state_machine.transition_to("Roam")
		return
	var flat := Vector2(bot.global_position.x, bot.global_position.z)
	if flat.length() <= bot.safe_zone.current_radius - 4.0:
		state_machine.transition_to("Roam")
		return
	var inward: Vector2 = -flat.normalized() if flat.length() > 0.01 else Vector2.ZERO
	var goal_flat := inward * maxf(bot.safe_zone.current_radius - 8.0, 0.0)
	var goal := Vector3(goal_flat.x, bot.global_position.y, goal_flat.y)
	bot.move_toward_point(goal, bot.move_speed, delta)
