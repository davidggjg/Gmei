extends CanvasLayer
class_name TouchControls

@onready var move_joystick: VirtualJoystick = $MoveJoystick
@onready var look_pad: LookPad = $LookPad

func _ready() -> void:
	visible = SettingsManager.show_touch_controls
	SettingsManager.settings_changed.connect(_on_settings_changed)

func _on_settings_changed() -> void:
	visible = SettingsManager.show_touch_controls

func get_move_vector() -> Vector2:
	return move_joystick.output
