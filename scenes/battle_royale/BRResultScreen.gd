extends CanvasLayer
class_name BRResultScreen

@onready var root_control: Control = $Root
@onready var title_label: Label = $Root/Panel/VBox/Title
@onready var subtitle_label: Label = $Root/Panel/VBox/Subtitle
@onready var play_again_button: Button = $Root/Panel/VBox/PlayAgainButton
@onready var menu_button: Button = $Root/Panel/VBox/MenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Loc.apply_rtl(root_control)
	root_control.visible = false
	play_again_button.text = Loc.t("MENU_BATTLE_ROYALE")
	menu_button.text = Loc.t("PAUSE_MAIN_MENU")
	play_again_button.pressed.connect(func():
		get_tree().paused = false
		GameManager.start_battle_royale()
	)
	menu_button.pressed.connect(func():
		get_tree().paused = false
		GameManager.goto_main_menu()
	)

func show_result(victory: bool, placement: int, total: int) -> void:
	title_label.text = Loc.t("BR_VICTORY") if victory else Loc.t("BR_DEFEAT")
	title_label.modulate = Color(0.3, 0.85, 0.4) if victory else Color(0.85, 0.2, 0.2)
	subtitle_label.text = "%s: #%d / %d" % [Loc.t("BR_PLACEMENT"), placement, total]
	root_control.visible = true
