extends Area3D
class_name Interactable
## Base for anything the player can walk up to and press "interact" on:
## pickups, doors, save points. Player detects these via an Area3D overlap
## check on physics layer 4 ("interactable").

@export var prompt_key: String = "HUD_INTERACT_PROMPT"
@export var one_shot: bool = false

var _consumed: bool = false

func _ready() -> void:
	collision_layer = 1 << 3 # "interactable" layer (layer 4, 0-indexed bit 3)
	collision_mask = 0

func get_prompt() -> String:
	return Loc.t(prompt_key)

func can_interact(_actor: Node) -> bool:
	return not (_consumed and one_shot)

## Override in subclasses.
func interact(actor: Node) -> void:
	if one_shot:
		_consumed = true
