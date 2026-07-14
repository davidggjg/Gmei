extends Control
class_name SettingsMenu

signal closed

@onready var title_label: Label = $Panel/VBox/Title
@onready var camera_fp_button: Button = $Panel/VBox/CameraRow/FirstPersonButton
@onready var camera_tp_button: Button = $Panel/VBox/CameraRow/ThirdPersonButton
@onready var difficulty_option: OptionButton = $Panel/VBox/DifficultyRow/DifficultyOption
@onready var music_slider: HSlider = $Panel/VBox/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $Panel/VBox/SfxRow/SfxSlider
@onready var sensitivity_slider: HSlider = $Panel/VBox/SensitivityRow/SensitivitySlider
@onready var invert_y_check: CheckBox = $Panel/VBox/InvertYRow/InvertYCheck
@onready var touch_controls_check: CheckBox = $Panel/VBox/TouchRow/TouchCheck
@onready var back_button: Button = $Panel/VBox/BackButton

var _difficulty_ids: Array = []

func _ready() -> void:
	Loc.apply_rtl(self)
	title_label.text = Loc.t("SETTINGS_TITLE")
	Loc.apply_rtl_text(title_label)

	camera_fp_button.text = Loc.t("SETTINGS_CAMERA_FIRST_PERSON")
	camera_tp_button.text = Loc.t("SETTINGS_CAMERA_THIRD_PERSON")
	camera_fp_button.toggle_mode = true
	camera_tp_button.toggle_mode = true
	camera_fp_button.pressed.connect(func(): _set_camera_mode(SettingsManager.CAMERA_FIRST_PERSON))
	camera_tp_button.pressed.connect(func(): _set_camera_mode(SettingsManager.CAMERA_THIRD_PERSON))

	_difficulty_ids = DifficultyDB.all_ids()
	difficulty_option.clear()
	for id in _difficulty_ids:
		var profile := DifficultyDB.get_profile(id)
		difficulty_option.add_item(Loc.t(profile.display_key))
	difficulty_option.item_selected.connect(_on_difficulty_selected)

	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.step = 0.05
	music_slider.value_changed.connect(_on_music_changed)

	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.05
	sfx_slider.value_changed.connect(_on_sfx_changed)

	sensitivity_slider.min_value = 0.05
	sensitivity_slider.max_value = 1.0
	sensitivity_slider.step = 0.05
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)

	invert_y_check.text = Loc.t("SETTINGS_INVERT_Y")
	invert_y_check.toggled.connect(_on_invert_y_toggled)

	touch_controls_check.text = Loc.t("SETTINGS_SHOW_TOUCH_CONTROLS")
	touch_controls_check.toggled.connect(_on_touch_controls_toggled)

	back_button.text = Loc.t("MENU_BACK")
	back_button.pressed.connect(func(): closed.emit())

	_refresh_from_settings()

func _refresh_from_settings() -> void:
	camera_fp_button.button_pressed = SettingsManager.camera_mode == SettingsManager.CAMERA_FIRST_PERSON
	camera_tp_button.button_pressed = SettingsManager.camera_mode == SettingsManager.CAMERA_THIRD_PERSON
	var idx: int = _difficulty_ids.find(SettingsManager.difficulty_id)
	difficulty_option.select(maxi(idx, 0))
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume
	sensitivity_slider.value = SettingsManager.mouse_sensitivity
	invert_y_check.button_pressed = SettingsManager.invert_y
	touch_controls_check.button_pressed = SettingsManager.show_touch_controls

func _set_camera_mode(mode: String) -> void:
	SettingsManager.set_camera_mode(mode)
	camera_fp_button.button_pressed = mode == SettingsManager.CAMERA_FIRST_PERSON
	camera_tp_button.button_pressed = mode == SettingsManager.CAMERA_THIRD_PERSON

func _on_difficulty_selected(index: int) -> void:
	SettingsManager.set_difficulty(_difficulty_ids[index])

func _on_music_changed(value: float) -> void:
	SettingsManager.music_volume = value
	SettingsManager.save_settings()
	SettingsManager.settings_changed.emit()

func _on_sfx_changed(value: float) -> void:
	SettingsManager.sfx_volume = value
	SettingsManager.save_settings()
	SettingsManager.settings_changed.emit()

func _on_sensitivity_changed(value: float) -> void:
	SettingsManager.mouse_sensitivity = value
	SettingsManager.touch_sensitivity = value
	SettingsManager.save_settings()

func _on_invert_y_toggled(pressed: bool) -> void:
	SettingsManager.invert_y = pressed
	SettingsManager.save_settings()

func _on_touch_controls_toggled(pressed: bool) -> void:
	SettingsManager.show_touch_controls = pressed
	SettingsManager.save_settings()
	SettingsManager.settings_changed.emit()
