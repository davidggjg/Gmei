extends CanvasLayer
class_name TouchControls

## Typed as the plain Control base, not the custom class, on purpose: in
## headless/CI-only exported builds (this project has never been opened in
## the Godot editor, which is normally what populates the global script
## class cache) class_name-based static type checks on @onready
## assignments were unreliable and silently left these null - see the
## push_error below, which is what caught it. Dynamic (duck-typed) member
## access on the Control-typed reference still works fine at runtime.
@onready var move_joystick: Control = $Root/MoveJoystick
@onready var look_pad: Control = $Root/LookPad

func _ready() -> void:
	visible = SettingsManager.show_touch_controls
	SettingsManager.settings_changed.connect(_on_settings_changed)
	if move_joystick == null:
		var names := []
		for c in $Root.get_children():
			names.append(c.name)
		push_error("TouchControls: move_joystick did not resolve. Root's children: %s" % [names])

func _on_settings_changed() -> void:
	visible = SettingsManager.show_touch_controls

func get_move_vector() -> Vector2:
	if move_joystick == null:
		return Vector2.ZERO
	return move_joystick.output
