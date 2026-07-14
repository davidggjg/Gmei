extends Node
## Simple single-slot campaign save/load using JSON under user://.
## Battle Royale matches are never saved - they always start fresh.

const SAVE_PATH := "user://campaign_save.json"

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game(data: Dictionary) -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: failed to open save file for writing")
		return false
	data["saved_at_unix"] = Time.get_unix_time_from_system()
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true

func load_game() -> Dictionary:
	if not has_save():
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
