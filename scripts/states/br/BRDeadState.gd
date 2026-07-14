extends State
class_name BRDeadState

@export var despawn_delay: float = 5.0

var bot: BRBot

func enter(_msg: Dictionary = {}) -> void:
	bot = actor as BRBot
	bot.velocity = Vector3.ZERO
	bot.collision_layer = 0
	bot.collision_mask = 1
	bot.hurtbox.monitoring = false
	bot.hurtbox.monitorable = false

	var tween := bot.create_tween()
	tween.tween_property(bot, "scale:y", 0.05, 0.6).set_delay(despawn_delay - 0.6)
	tween.tween_callback(bot.queue_free)

func physics_update(delta: float) -> void:
	if not bot.is_on_floor():
		bot.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity", 13.0) * delta
		bot.move_and_slide()
