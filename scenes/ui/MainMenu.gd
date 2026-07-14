extends Control

@onready var title_label: Label = $VBox/Title
@onready var new_game_button: Button = $VBox/Buttons/NewGameButton
@onready var continue_button: Button = $VBox/Buttons/ContinueButton
@onready var battle_royale_button: Button = $VBox/Buttons/BattleRoyaleButton
@onready var settings_button: Button = $VBox/Buttons/SettingsButton
@onready var credits_button: Button = $VBox/Buttons/CreditsButton
@onready var quit_button: Button = $VBox/Buttons/QuitButton
@onready var settings_menu: SettingsMenu = $SettingsMenuInstance
@onready var credits_panel: Control = $CreditsPanel
@onready var credits_label: Label = $CreditsPanel/Panel/VBox/CreditsLabel
@onready var credits_close_button: Button = $CreditsPanel/Panel/VBox/CloseButton

func _ready() -> void:
	Loc.apply_rtl(self)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	title_label.text = Loc.t("APP_TITLE")
	new_game_button.text = Loc.t("MENU_NEW_GAME")
	continue_button.text = Loc.t("MENU_CONTINUE")
	battle_royale_button.text = Loc.t("MENU_BATTLE_ROYALE")
	settings_button.text = Loc.t("MENU_SETTINGS")
	credits_button.text = Loc.t("MENU_CREDITS")
	quit_button.text = Loc.t("MENU_QUIT")
	credits_label.text = Loc.t("CREDITS_TEXT")
	credits_close_button.text = Loc.t("MENU_BACK")

	continue_button.disabled = not SaveManager.has_save()

	new_game_button.pressed.connect(func(): GameManager.start_new_campaign())
	continue_button.pressed.connect(func(): GameManager.continue_campaign())
	battle_royale_button.pressed.connect(func(): GameManager.start_battle_royale())
	settings_button.pressed.connect(func(): settings_menu.visible = true)
	credits_button.pressed.connect(func(): credits_panel.visible = true)
	quit_button.pressed.connect(func(): GameManager.quit_game())

	settings_menu.closed.connect(func(): settings_menu.visible = false)
	settings_menu.visible = false
	credits_close_button.pressed.connect(func(): credits_panel.visible = false)
	credits_panel.visible = false
