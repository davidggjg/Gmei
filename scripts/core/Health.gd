extends Node
class_name Health
## Drop-in health component usable by the player, campaign enemies and
## Battle Royale bots alike.

signal health_changed(current: float, max_health: float)
signal damaged(amount: float, source: Node)
signal healed(amount: float)
signal died(source: Node)

@export var max_health: float = 100.0
@export var start_at_max: bool = true
@export var invulnerable_time_after_hit: float = 0.0 ## optional i-frames

var current_health: float
var is_dead: bool = false

var _invuln_timer: float = 0.0

func _ready() -> void:
	current_health = max_health if start_at_max else 0.0

func _process(delta: float) -> void:
	if _invuln_timer > 0.0:
		_invuln_timer -= delta

func take_damage(amount: float, source: Node = null) -> void:
	if is_dead or amount <= 0.0:
		return
	if _invuln_timer > 0.0:
		return
	current_health = clampf(current_health - amount, 0.0, max_health)
	damaged.emit(amount, source)
	health_changed.emit(current_health, max_health)
	if invulnerable_time_after_hit > 0.0:
		_invuln_timer = invulnerable_time_after_hit
	if current_health <= 0.0 and not is_dead:
		is_dead = true
		died.emit(source)

func heal(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return
	current_health = clampf(current_health + amount, 0.0, max_health)
	healed.emit(amount)
	health_changed.emit(current_health, max_health)

func revive(percent: float = 1.0) -> void:
	is_dead = false
	current_health = max_health * clampf(percent, 0.0, 1.0)
	health_changed.emit(current_health, max_health)

func health_percent() -> float:
	return current_health / max_health if max_health > 0.0 else 0.0
