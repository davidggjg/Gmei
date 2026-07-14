extends State
class_name BRRoamState

@export var repick_interval: float = 3.0
@export var arrival_distance: float = 1.0
@export var wander_radius: float = 14.0

var bot: BRBot
var _goal: Vector3
var _repick_timer: float = 0.0

func enter(_msg: Dictionary = {}) -> void:
	bot = actor as BRBot
	_repick_timer = 0.0
	_pick_goal()

func physics_update(delta: float) -> void:
	if _is_far_outside_zone():
		state_machine.transition_to("FleeZone")
		return

	var target := bot.find_hostile_target()
	if target:
		bot.current_target = target
		state_machine.transition_to("Engage")
		return

	var loot := bot.find_nearest_loot()
	if loot and bot.global_position.distance_to(loot.global_position) <= 1.4:
		loot.interact(bot)

	_repick_timer -= delta
	if _repick_timer <= 0.0:
		_pick_goal()

	bot.move_toward_point(_goal, bot.move_speed * 0.75, delta)
	if bot.global_position.distance_to(_goal) <= arrival_distance:
		_repick_timer = 0.0

func _pick_goal() -> void:
	_repick_timer = repick_interval
	var loot := bot.find_nearest_loot()
	if loot:
		_goal = loot.global_position
		return
	var angle := randf_range(0, TAU)
	var dist := randf_range(3.0, wander_radius)
	_goal = bot.global_position + Vector3(cos(angle) * dist, 0, sin(angle) * dist)

func _is_far_outside_zone() -> bool:
	if bot.safe_zone == null:
		return false
	var flat := Vector2(bot.global_position.x, bot.global_position.z)
	return flat.length() > bot.safe_zone.current_radius + 2.0
