extends Node3D
class_name SafeZone
## Shrinking circular safe zone, centered on the origin. Anything registered
## via register_actor() that strays outside current_radius takes periodic
## damage. Purely gameplay logic - the visual ring is a child MeshInstance3D
## kept in sync every frame.

signal shrink_started(target_radius: float, duration: float)
signal shrink_finished

@export var start_radius: float = 62.0
@export var damage_per_second: float = 5.0
## Each stage: {wait: seconds before this shrink starts (from match start), duration: seconds to shrink, to_radius: final radius}
@export var stages: Array = [
	{"wait": 25.0, "duration": 20.0, "to_radius": 40.0},
	{"wait": 55.0, "duration": 18.0, "to_radius": 26.0},
	{"wait": 85.0, "duration": 16.0, "to_radius": 14.0},
	{"wait": 115.0, "duration": 14.0, "to_radius": 6.0},
]

@onready var ring: MeshInstance3D = $Ring

var current_radius: float
var _actors: Array = [] # [{node: Node3D, health: Health}]
var _damage_tick: float = 0.0

func _ready() -> void:
	current_radius = start_radius
	_update_ring()
	_run_stages()

func register_actor(node: Node3D, health: Health) -> void:
	_actors.append({"node": node, "health": health})

func _run_stages() -> void:
	var elapsed := 0.0
	for stage in stages:
		var wait_time: float = stage["wait"] - elapsed
		if wait_time > 0.0:
			await get_tree().create_timer(wait_time).timeout
			elapsed += wait_time
		shrink_started.emit(stage["to_radius"], stage["duration"])
		var start_r := current_radius
		var target_r: float = stage["to_radius"]
		var duration: float = stage["duration"]
		var t := 0.0
		while t < duration:
			t += get_process_delta_time()
			current_radius = lerp(start_r, target_r, clampf(t / duration, 0.0, 1.0))
			_update_ring()
			await get_tree().process_frame
		current_radius = target_r
		elapsed += duration
		shrink_finished.emit()

func _process(delta: float) -> void:
	_damage_tick += delta
	if _damage_tick < 0.5:
		return
	var applied := _damage_tick
	_damage_tick = 0.0
	for entry in _actors:
		var node: Node3D = entry["node"]
		var health: Health = entry["health"]
		if not is_instance_valid(node) or health.is_dead:
			continue
		var flat_pos := Vector2(node.global_position.x, node.global_position.z)
		if flat_pos.length() > current_radius:
			health.take_damage(damage_per_second * applied, null)

func _update_ring() -> void:
	if ring == null:
		return
	ring.scale = Vector3(current_radius, 1.0, current_radius)
