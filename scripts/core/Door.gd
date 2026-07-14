extends Interactable
class_name Door
## Simple hinged door. Expects a child Node3D named "Pivot" containing the
## door's visual mesh + collision, so it can be rotated open/closed.
## Keys are checked against the inventory but never consumed (RE-style).

signal opened
signal locked_feedback

@export var locked: bool = false
@export var required_key_id: String = ""
@export var open_angle_deg: float = 100.0
@export var open_duration: float = 0.6

var _is_open: bool = false
var _pivot: Node3D

func _ready() -> void:
	super._ready()
	prompt_key = "HUD_INTERACT_PROMPT"
	_pivot = get_node_or_null("Pivot")

func interact(actor: Node) -> void:
	if locked:
		var inventory: Inventory = actor.get_node_or_null("Inventory")
		if inventory != null and required_key_id != "" and inventory.has_item(required_key_id):
			locked = false
		else:
			locked_feedback.emit()
			return
	_toggle()

func _toggle() -> void:
	if _pivot == null:
		return
	_is_open = not _is_open
	var target_deg: float = open_angle_deg if _is_open else 0.0
	var tween := create_tween()
	tween.tween_property(_pivot, "rotation:y", deg_to_rad(target_deg), open_duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if _is_open:
		opened.emit()
