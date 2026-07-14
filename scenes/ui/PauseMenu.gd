extends CanvasLayer
class_name PauseMenu

@onready var root_control: Control = $Root
@onready var title_label: Label = $Root/Panel/VBox/Title
@onready var resume_button: Button = $Root/Panel/VBox/ResumeButton
@onready var settings_button: Button = $Root/Panel/VBox/SettingsButton
@onready var main_menu_button: Button = $Root/Panel/VBox/MainMenuButton
@onready var settings_menu: SettingsMenu = $SettingsMenuInstance

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Loc.apply_rtl(root_control)
	title_label.text = Loc.t("PAUSE_TITLE")
	resume_button.text = Loc.t("PAUSE_RESUME")
	settings_button.text = Loc.t("PAUSE_SETTINGS")
	main_menu_button.text = Loc.t("PAUSE_MAIN_MENU")

	resume_button.pressed.connect(func(): GameManager.set_paused(false))
	settings_button.pressed.connect(func(): settings_menu.visible = true)
	main_menu_button.pressed.connect(func(): GameManager.goto_main_menu())
	settings_menu.closed.connect(func(): settings_menu.visible = false)
	settings_menu.visible = false

	GameManager.pause_state_changed.connect(_on_pause_state_changed)
	root_control.visible = GameManager.is_paused

func _on_pause_state_changed(paused: bool) -> void:
	root_control.visible = paused
	if not paused:
		settings_menu.visible = false
