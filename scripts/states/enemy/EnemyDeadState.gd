extends State
class_name EnemyDeadState

@export var despawn_delay: float = 4.0

var enemy: EnemyBase

func enter(_msg: Dictionary = {}) -> void:
	enemy = actor as EnemyBase
	enemy.velocity = Vector3.ZERO
	enemy.collision_layer = 0
	enemy.collision_mask = 1 # keep colliding with world so it settles on the floor
	enemy.hurtbox.monitoring = false
	enemy.hurtbox.monitorable = false
	enemy.hitbox.monitoring = false

	var tween := enemy.create_tween()
	tween.tween_property(enemy, "scale:y", 0.05, 0.6).set_delay(despawn_delay - 0.6)
	tween.tween_callback(enemy.queue_free)

func physics_update(delta: float) -> void:
	if not enemy.is_on_floor():
		enemy.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity", 13.0) * delta
		enemy.move_and_slide()
