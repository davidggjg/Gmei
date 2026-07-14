extends Area3D
class_name Hitbox
## Melee attack hitbox. Call activate() at the start of an attack animation
## window and deactivate() at the end; each Hurtbox is only damaged once
## per activation.

@export var damage: float = 20.0
@export var owner_actor: Node = null

var _active: bool = false
var _already_hit: Array[Node] = []

func _ready() -> void:
	collision_layer = 1 << 4 # "hitbox" layer (layer 5, 0-indexed bit 4)
	collision_mask = 1 << 5 # scan "hurtbox" layer
	monitoring = false
	area_entered.connect(_on_area_entered)

func activate() -> void:
	_active = true
	_already_hit.clear()
	monitoring = true

func deactivate() -> void:
	_active = false
	monitoring = false

func _on_area_entered(area: Area3D) -> void:
	if not _active or not (area is Hurtbox):
		return
	if area in _already_hit:
		return
	# Never hit the wielder's own Hurtbox. This matters most in third-person,
	# where the camera (and the melee hitbox attached to it) can end up
	# close to or inside the player's own body - e.g. when the SpringArm3D
	# shortens against a nearby wall - which was landing the starting
	# Knife's swing on the player themselves.
	if owner_actor != null and area.get_parent() == owner_actor:
		return
	_already_hit.append(area)
	area.receive_hit(damage, owner_actor)
