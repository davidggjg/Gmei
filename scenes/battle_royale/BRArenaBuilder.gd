extends Node3D
## Procedurally scatters greybox cover buildings and a ground plane across
## the Battle Royale island. Deterministic seed so layout is stable and the
## nav mesh bakes the same geometry every match.

const GROUND_RADIUS := 62.0
const BUILDING_COUNT := 14
const LAYOUT_SEED := 91173

func _ready() -> void:
	var ground_mat := StandardMaterial3D.new()
	ground_mat.albedo_color = Color(0.12, 0.14, 0.1)
	ground_mat.roughness = 1.0

	var ground := CSGCylinder3D.new()
	ground.use_collision = true
	ground.collision_layer = 1
	ground.radius = GROUND_RADIUS
	ground.height = 1.0
	ground.sides = 48
	ground.position = Vector3(0, -0.5, 0)
	ground.material = ground_mat
	add_child(ground)

	var wall_mat := StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.05, 0.05, 0.06)
	var boundary := CSGTorus3D.new()
	boundary.use_collision = true
	boundary.collision_layer = 1
	boundary.inner_radius = GROUND_RADIUS - 1.5
	boundary.outer_radius = GROUND_RADIUS + 1.5
	boundary.sides = 8
	boundary.ring_sides = 48
	boundary.position = Vector3(0, 2.0, 0)
	boundary.material = wall_mat
	add_child(boundary)

	var rng := RandomNumberGenerator.new()
	rng.seed = LAYOUT_SEED
	var building_mat := StandardMaterial3D.new()
	building_mat.albedo_color = Color(0.16, 0.14, 0.13)
	building_mat.roughness = 0.9

	for i in range(BUILDING_COUNT):
		var angle := rng.randf_range(0, TAU)
		var dist := rng.randf_range(10.0, GROUND_RADIUS - 8.0)
		var pos := Vector3(cos(angle) * dist, 0, sin(angle) * dist)
		var size := Vector3(
			rng.randf_range(4.0, 9.0),
			rng.randf_range(2.5, 6.0),
			rng.randf_range(4.0, 9.0)
		)
		var box := CSGBox3D.new()
		box.use_collision = true
		box.collision_layer = 1
		box.size = size
		box.position = pos + Vector3(0, size.y * 0.5, 0)
		box.rotation.y = rng.randf_range(0, TAU)
		box.material = building_mat
		add_child(box)
