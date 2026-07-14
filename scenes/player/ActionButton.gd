extends Button
class_name ActionButton
## On-screen input button that forwards to Godot's Input singleton, so
## Player.gd only ever has to check Input.is_action_pressed() and never
## needs to know whether the source was touch, keyboard or a gamepad.
## Set the Button's own `toggle_mode` (in the inspector) for hold-toggle
## buttons like aim/crouch/flashlight; leave it off for momentary buttons
## like fire/jump/interact.

@export var action_name: String = ""

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	if toggle_mode:
		toggled.connect(_on_toggled)
	else:
		button_down.connect(_on_down)
		button_up.connect(_on_up)

func _on_toggled(is_pressed: bool) -> void:
	if action_name == "":
		return
	if is_pressed:
		Input.action_press(action_name)
	else:
		Input.action_release(action_name)

func _on_down() -> void:
	if action_name != "":
		Input.action_press(action_name)

func _on_up() -> void:
	if action_name != "":
		Input.action_release(action_name)
