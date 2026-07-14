extends Area3D
class_name Hurtbox
## Placed on an actor (player/enemy) to receive damage from Hitboxes.
## Forwards damage to the sibling/parent Health component.

@export var health_path: NodePath = NodePath("../Health")

var _health: Health

func _ready() -> void:
	collision_layer = 1 << 5 # "hurtbox" layer (layer 6, 0-indexed bit 5)
	collision_mask = 0
	_health = get_node_or_null(health_path)

func receive_hit(amount: float, source: Node) -> void:
	if _health:
		_health.take_damage(amount, source)
