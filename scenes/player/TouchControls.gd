extends CanvasLayer
class_name TouchControls

@onready var move_joystick: VirtualJoystick = $Root/MoveJoystick
@onready var look_pad: LookPad = $Root/LookPad

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
