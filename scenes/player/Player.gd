extends CharacterBody3D
class_name Player

@export var walk_speed: float = 3.2
@export var sprint_speed: float = 5.8
@export var crouch_speed: float = 1.7
@export var acceleration: float = 10.0
@export var air_control: float = 2.5
@export var jump_height: float = 1.05
@export var crouch_camera_offset: float = -0.35

@onready var camera_rig: CameraRig = $CameraRig
@onready var camera: Camera3D = $CameraRig/SpringArm3D/Camera3D
@onready var body_visual: Node3D = $PlayerBodyVisual
@onready var health: Health = $Health
@onready var stamina: Stamina = $Stamina
@onready var inventory: Inventory = $Inventory
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var interaction_area: Area3D = $InteractionArea
@onready var flashlight: SpotLight3D = $CameraRig/SpringArm3D/Camera3D/Flashlight
@onready var touch_controls: TouchControls = $TouchControls
@onready var muzzle_hitbox: Hitbox = $CameraRig/SpringArm3D/Camera3D/MeleeHitbox
@onready var muzzle_flash: OmniLight3D = $CameraRig/SpringArm3D/Camera3D/MuzzleFlash

signal interact_prompt_changed(text: String)
signal shot_fired
signal shot_hit_confirmed

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 13.0)
var jump_velocity: float
var is_crouching: bool = false
var is_dead: bool = false
var _fire_cooldown: float = 0.0
var _nearby_interactables: Array[Interactable] = []
var _flashlight_on: bool = false
var _body_anim: AnimationPlayer
var _current_anim: String = ""

func _ready() -> void:
	jump_velocity = sqrt(2.0 * gravity * jump_height)
	add_to_group("player")
	health.died.connect(_on_died)
	_body_anim = body_visual.find_child("AnimationPlayer", true, false)
	_play_body_anim("idle")
	interaction_area.area_entered.connect(_on_interactable_area_entered)
	interaction_area.area_exited.connect(_on_interactable_area_exited)
	if touch_controls.look_pad:
		touch_controls.look_pad.look_delta.connect(_on_touch_look_delta)
	if not OS.has_feature("mobile"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameManager.pause_state_changed.connect(_on_pause_state_changed)

func _on_pause_state_changed(paused: bool) -> void:
	if OS.has_feature("mobile"):
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if is_dead or GameManager.is_paused:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var s := SettingsManager.mouse_sensitivity * 0.01
		var dy: float = event.relative.y * s * (-1.0 if SettingsManager.invert_y else 1.0)
		camera_rig.apply_look_delta(event.relative.x * s, dy)
	if event.is_action_pressed("toggle_camera_view"):
		camera_rig.toggle_mode()
	if event.is_action_pressed("interact"):
		_try_interact()
	if event.is_action_pressed("reload"):
		inventory.reload_equipped()
	if event.is_action_pressed("switch_weapon"):
		inventory.cycle_weapon()
	if event.is_action_pressed("flashlight") and SettingsManager.flashlight_hold_mode:
		_set_flashlight(true)
	if event.is_action_released("flashlight"):
		if SettingsManager.flashlight_hold_mode:
			_set_flashlight(false)
		else:
			_set_flashlight(not _flashlight_on)

func _on_touch_look_delta(delta: Vector2) -> void:
	if is_dead or GameManager.is_paused:
		return
	var s := SettingsManager.touch_sensitivity * 0.01
	var dy: float = delta.y * s * (-1.0 if SettingsManager.invert_y else 1.0)
	camera_rig.apply_look_delta(delta.x * s, dy)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if GameManager.is_paused:
		return

	_fire_cooldown = maxf(0.0, _fire_cooldown - delta)
	if Input.is_action_pressed("fire"):
		_try_fire() # cooldown below throttles actual rate of fire

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump") and not is_crouching:
		velocity.y = jump_velocity

	is_crouching = Input.is_action_pressed("crouch")
	var sprinting := Input.is_action_pressed("sprint") and not is_crouching and stamina.has_stamina()
	if sprinting and velocity.length() > 0.1:
		stamina.drain(delta)
	else:
		stamina.regen(delta)

	var target_speed := crouch_speed if is_crouching else (sprint_speed if sprinting else walk_speed)
	var input_vec := _get_move_input()
	var move_dir := (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
	var accel := acceleration if is_on_floor() else air_control

	var target_velocity := move_dir * target_speed
	velocity.x = move_toward(velocity.x, target_velocity.x, accel * delta * target_speed)
	velocity.z = move_toward(velocity.z, target_velocity.z, accel * delta * target_speed)

	camera_rig.position.y = lerp(camera_rig.position.y, camera_rig.first_person_eye_height + (crouch_camera_offset if is_crouching else 0.0), 1.0 - exp(-10.0 * delta))

	move_and_slide()

	var ground_speed := Vector2(velocity.x, velocity.z).length()
	if ground_speed < 0.2:
		_play_body_anim("idle")
	elif sprinting:
		_play_body_anim("sprint")
	else:
		_play_body_anim("walk")

func _play_body_anim(anim_name: String) -> void:
	if _body_anim == null or _current_anim == anim_name:
		return
	if not _body_anim.has_animation(anim_name):
		return
	_current_anim = anim_name
	_body_anim.play(anim_name)

func _get_move_input() -> Vector2:
	var vec := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if vec == Vector2.ZERO:
		vec = touch_controls.get_move_vector()
	return vec

func _try_interact() -> void:
	var best: Interactable = null
	var best_dist := INF
	for it in _nearby_interactables:
		if not is_instance_valid(it) or not it.can_interact(self):
			continue
		var d := it.global_position.distance_squared_to(global_position)
		if d < best_dist:
			best_dist = d
			best = it
	if best:
		best.interact(self)

func _on_interactable_area_entered(area: Area3D) -> void:
	if area is Interactable:
		_nearby_interactables.append(area)
		_update_interact_prompt()

func _on_interactable_area_exited(area: Area3D) -> void:
	_nearby_interactables.erase(area)
	_update_interact_prompt()

func _update_interact_prompt() -> void:
	var best: Interactable = null
	var best_dist := INF
	for it in _nearby_interactables:
		if not is_instance_valid(it) or not it.can_interact(self):
			continue
		var d := it.global_position.distance_squared_to(global_position)
		if d < best_dist:
			best_dist = d
			best = it
	interact_prompt_changed.emit(best.get_prompt() if best else "")

func _try_fire() -> void:
	if _fire_cooldown > 0.0:
		return
	var weapon := inventory.get_equipped_weapon()
	if weapon == null:
		return
	_fire_cooldown = 1.0 / maxf(weapon.fire_rate, 0.1)
	if weapon.is_melee:
		muzzle_hitbox.damage = weapon.damage
		muzzle_hitbox.owner_actor = self
		muzzle_hitbox.activate()
		get_tree().create_timer(0.15).timeout.connect(muzzle_hitbox.deactivate)
		return
	if not inventory.try_consume_round():
		return
	_hitscan(weapon)
	_flash_muzzle()
	camera_rig.add_recoil(weapon.recoil_kick_deg)
	shot_fired.emit()

func _flash_muzzle() -> void:
	muzzle_flash.visible = true
	muzzle_flash.light_energy = 6.0
	var tween := create_tween()
	tween.tween_property(muzzle_flash, "light_energy", 0.0, 0.06)
	tween.tween_callback(func(): muzzle_flash.visible = false)

## Fires one or more pellets (shotgun-style when pellet_count > 1) down the
## camera's forward vector, each with a random deviation inside a spread
## cone that tightens while aiming - this is what makes hip-fire "spray" and
## aimed shots feel precise, instead of every weapon behaving identically.
func _hitscan(weapon: Item) -> void:
	var is_aiming := Input.is_action_pressed("aim")
	var spread_deg: float = weapon.aim_spread_deg if is_aiming else weapon.hip_spread_deg
	var space_state := get_world_3d().direct_space_state
	var from := camera.global_position
	var forward := -camera.global_transform.basis.z
	var any_hit := false

	for i in range(maxi(weapon.pellet_count, 1)):
		var dir := forward
		if spread_deg > 0.0:
			dir = dir.rotated(camera.global_transform.basis.x, deg_to_rad(randf_range(-spread_deg, spread_deg)))
			dir = dir.rotated(camera.global_transform.basis.y, deg_to_rad(randf_range(-spread_deg, spread_deg)))
		var to := from + dir * weapon.weapon_range
		var query := PhysicsRayQueryParameters3D.create(from, to)
		query.collision_mask = (1 << 0) | (1 << 5) # world, hurtbox (never the enemy's own solid body - it overlaps the hurtbox and would shadow it)
		query.collide_with_areas = true
		query.collide_with_bodies = true
		query.exclude = [self, hurtbox]
		var result := space_state.intersect_ray(query)
		if result.is_empty():
			continue
		var collider = result.get("collider")
		if collider and collider is Hurtbox:
			collider.receive_hit(weapon.damage, self)
			any_hit = true

	if any_hit:
		shot_hit_confirmed.emit()

func _set_flashlight(on: bool) -> void:
	_flashlight_on = on
	flashlight.visible = on

func _on_died(_source: Node) -> void:
	is_dead = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_play_body_anim("die")
	GameManager.on_player_died()

func build_save_data() -> Dictionary:
	var item_stacks := {}
	for id in inventory.stacks:
		item_stacks[id] = inventory.stacks[id]
	return {
		"position": {"x": global_position.x, "y": global_position.y, "z": global_position.z},
		"rotation_y": rotation.y,
		"health": health.current_health,
		"stacks": item_stacks,
		"equipped_weapon_id": inventory.equipped_weapon_id,
	}

func apply_save_data(data: Dictionary) -> void:
	if data.has("position"):
		var p = data["position"]
		global_position = Vector3(p.get("x", 0.0), p.get("y", 0.0), p.get("z", 0.0))
	if data.has("rotation_y"):
		rotation.y = data["rotation_y"]
	if data.has("health"):
		health.current_health = data["health"]
	if data.has("stacks"):
		for id in data["stacks"]:
			inventory.stacks[id] = data["stacks"][id]
	if data.has("equipped_weapon_id") and data["equipped_weapon_id"] != "":
		inventory.equip_weapon(data["equipped_weapon_id"])
