extends Control
class_name LookPad
## Invisible touch-drag surface (right side of the screen) that rotates the
## camera. Emits a relative delta each frame rather than an absolute value.

signal look_delta(delta: Vector2)

var _touch_index: int = -1
var _last_pos: Vector2 = Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			_touch_index = event.index
			_last_pos = event.position
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
	elif event is InputEventScreenDrag and event.index == _touch_index:
		var delta: Vector2 = event.position - _last_pos
		_last_pos = event.position
		look_delta.emit(delta)
