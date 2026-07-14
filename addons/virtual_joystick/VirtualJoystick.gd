extends Control
class_name VirtualJoystick
## Self-contained on-screen joystick, drawn procedurally (no texture assets
## needed). Tracks its own touch index so multiple touch controls can be
## active on screen simultaneously.

@export var radius: float = 80.0
@export var knob_radius: float = 34.0
@export var deadzone: float = 0.15
@export var base_color: Color = Color(1, 1, 1, 0.12)
@export var knob_color: Color = Color(1, 1, 1, 0.35)

var output: Vector2 = Vector2.ZERO

var _touch_index: int = -1
var _center: Vector2 = Vector2.ZERO
var _knob_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	custom_minimum_size = Vector2(radius, radius) * 2.0
	_center = size / 2.0
	_knob_pos = _center

func _draw() -> void:
	draw_circle(_center, radius, base_color)
	draw_circle(_knob_pos, knob_radius, knob_color)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			_touch_index = event.index
			_update_knob(event.position)
		elif not event.pressed and event.index == _touch_index:
			_reset()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_knob(event.position)

func _update_knob(local_pos: Vector2) -> void:
	var offset := local_pos - _center
	if offset.length() > radius:
		offset = offset.normalized() * radius
	_knob_pos = _center + offset
	var normalized := offset / radius
	output = normalized if normalized.length() > deadzone else Vector2.ZERO
	queue_redraw()

func _reset() -> void:
	_touch_index = -1
	_knob_pos = _center
	output = Vector2.ZERO
	queue_redraw()
