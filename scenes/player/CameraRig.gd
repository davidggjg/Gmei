extends Node3D
class_name CameraRig
## Handles first-person / third-person camera switching. This is the core
## piece of the "does the player see their own body?" setting:
##  - First person: camera sits at eye height, the head mesh is hidden so it
##    doesn't block the view, but torso/arms/legs stay visible - look down
##    and you see your own body.
##  - Third person: camera pulls back on a SpringArm3D over the shoulder,
##    full body (head included) is visible.

@export var body_visual_path: NodePath
@export var first_person_eye_height: float = 1.62
@export var third_person_spring_length: float = 3.5
@export var third_person_shoulder_offset: Vector3 = Vector3(0.45, 0.15, 0)
@export var pitch_min_deg: float = -80.0
@export var pitch_max_deg: float = 75.0
@export var transition_speed: float = 8.0

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

var body_visual: Node3D
var current_mode: String = SettingsManager.CAMERA_FIRST_PERSON

var _target_spring_length: float = 0.0
var _target_camera_offset: Vector3 = Vector3.ZERO
var _recoil_pitch: float = 0.0
const RECOIL_RECOVERY_SPEED := 7.0

func _ready() -> void:
	if body_visual_path != NodePath():
		body_visual = get_node_or_null(body_visual_path)
	spring_arm.collision_mask = 1 # "world" layer only, so it doesn't clip on the player itself
	set_mode(SettingsManager.camera_mode, true)
	SettingsManager.settings_changed.connect(_on_settings_changed)

func _process(delta: float) -> void:
	spring_arm.spring_length = lerp(spring_arm.spring_length, _target_spring_length, 1.0 - exp(-transition_speed * delta))
	camera.position = camera.position.lerp(_target_camera_offset, 1.0 - exp(-transition_speed * delta))
	if _recoil_pitch > 0.0:
		var recover: float = _recoil_pitch * (1.0 - exp(-RECOIL_RECOVERY_SPEED * delta))
		rotation.x += recover
		_recoil_pitch -= recover

## Kicks the view upward briefly and lets it settle back down - called once per shot.
func add_recoil(amount_deg: float) -> void:
	var amount_rad: float = deg_to_rad(amount_deg)
	rotation.x = clampf(rotation.x - amount_rad, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))
	_recoil_pitch += amount_rad

func _on_settings_changed() -> void:
	set_mode(SettingsManager.camera_mode)

func set_mode(mode: String, instant: bool = false) -> void:
	current_mode = mode
	position.y = first_person_eye_height
	if mode == SettingsManager.CAMERA_THIRD_PERSON:
		_target_spring_length = third_person_spring_length
		_target_camera_offset = third_person_shoulder_offset
		_set_head_visible(true)
	else:
		_target_spring_length = 0.0
		_target_camera_offset = Vector3.ZERO
		_set_head_visible(false)
	if instant:
		spring_arm.spring_length = _target_spring_length
		camera.position = _target_camera_offset

func toggle_mode() -> void:
	var new_mode := SettingsManager.CAMERA_THIRD_PERSON if current_mode == SettingsManager.CAMERA_FIRST_PERSON else SettingsManager.CAMERA_FIRST_PERSON
	SettingsManager.set_camera_mode(new_mode)

func _set_head_visible(visible_head: bool) -> void:
	if body_visual == null:
		return
	# Recursive + case-insensitive: works whether body_visual is the simple
	# placeholder mesh (a direct "Head" child) or an imported character
	# model where "head" is nested a few levels down inside the glTF scene.
	var head := body_visual.find_child("*head*", true, false)
	if head and head is Node3D:
		head.visible = visible_head

## Called by the player controller for both mouse motion and touch-drag look.
func apply_look_delta(delta_x: float, delta_y: float) -> void:
	get_parent().rotate_y(-delta_x)
	rotation.x = clampf(rotation.x - delta_y, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))
