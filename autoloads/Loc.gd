extends Node
## Lightweight Hebrew string table + RTL helpers.
## Loaded manually from CSV instead of Godot's TranslationServer pipeline so
## the game works correctly when built headlessly (no editor import step).

const STRINGS_PATH := "res://localization/strings_he.csv"

var _strings: Dictionary = {}

func _ready() -> void:
	_load_strings()

func _load_strings() -> void:
	var file := FileAccess.open(STRINGS_PATH, FileAccess.READ)
	if file == null:
		push_error("Loc: could not open %s" % STRINGS_PATH)
		return
	var header := file.get_csv_line()
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() < 2 or row[0].is_empty():
			continue
		_strings[row[0]] = row[1]
	file.close()

## Returns the Hebrew text for `key`, or the key itself if missing (visible bug marker).
func t(key: String) -> String:
	return _strings.get(key, "?%s?" % key)

## Applies standard RTL layout to a Control root (menus/HUD panels).
func apply_rtl(control: Control) -> void:
	control.layout_direction = Control.LAYOUT_DIRECTION_RTL

## Applies RTL text shaping to a Label/RichTextLabel/Button-like text node.
func apply_rtl_text(node: Object) -> void:
	if node.has_method("set_text_direction"):
		node.text_direction = Control.TEXT_DIRECTION_RTL
	if node.has_method("set_horizontal_alignment"):
		node.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
