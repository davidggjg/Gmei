extends Node
class_name Stamina
## Sprint/dodge resource for the player. Regenerates after a short delay.

signal stamina_changed(current: float, max_stamina: float)
signal exhausted
signal recovered

@export var max_stamina: float = 100.0
@export var drain_per_second: float = 22.0
@export var regen_per_second: float = 14.0
@export var regen_delay: float = 0.8

var current_stamina: float
var is_exhausted: bool = false

var _regen_delay_timer: float = 0.0

func _ready() -> void:
	current_stamina = max_stamina

func drain(delta: float) -> bool:
	if current_stamina <= 0.0:
		return false
	current_stamina = clampf(current_stamina - drain_per_second * delta, 0.0, max_stamina)
	_regen_delay_timer = regen_delay
	stamina_changed.emit(current_stamina, max_stamina)
	if current_stamina <= 0.0 and not is_exhausted:
		is_exhausted = true
		exhausted.emit()
	return current_stamina > 0.0

func regen(delta: float) -> void:
	if _regen_delay_timer > 0.0:
		_regen_delay_timer -= delta
		return
	if current_stamina >= max_stamina:
		return
	current_stamina = clampf(current_stamina + regen_per_second * delta, 0.0, max_stamina)
	stamina_changed.emit(current_stamina, max_stamina)
	if is_exhausted and current_stamina > max_stamina * 0.3:
		is_exhausted = false
		recovered.emit()

func has_stamina() -> bool:
	return current_stamina > 0.0 and not is_exhausted
