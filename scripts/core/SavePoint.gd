extends Interactable
class_name SavePoint
## Campaign save point. The actor (player) must implement build_save_data().

signal game_saved

@export var level_id: String = "mansion"

func _ready() -> void:
	super._ready()
	prompt_key = "SAVE_POINT_PROMPT"

func interact(actor: Node) -> void:
	if not actor.has_method("build_save_data"):
		return
	var data: Dictionary = actor.build_save_data()
	data["level_id"] = level_id
	data["difficulty_id"] = SettingsManager.difficulty_id
	if SaveManager.save_game(data):
		game_saved.emit()
