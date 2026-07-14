extends Node3D
## Procedurally blocks out the mansion's corridors/rooms as simple CSG boxes.
## This is placeholder greybox geometry - swap for authored architecture
## later without touching any gameplay script, since doors/pickups/enemies
## are placed independently in MansionLevel.tscn.

const WALL_HEIGHT := 3.2
const WALL_THICKNESS := 0.3
const FLOOR_THICKNESS := 0.2

@export var wall_material_color: Color = Color(0.11, 0.1, 0.1)
@export var floor_material_color: Color = Color(0.08, 0.07, 0.07)

# Each wall: two endpoints of the wall's centerline (must share either x or z).
var _walls: Array = [
	# Hall (x:-5..5, z:-5..5), corridor gaps are 2.6 wide centered on 0
	[Vector2(-5, -5), Vector2(-1.3, -5)], [Vector2(1.3, -5), Vector2(5, -5)], # north wall (gap to Study)
	[Vector2(-5, 5), Vector2(-1.3, 5)], [Vector2(1.3, 5), Vector2(5, 5)],     # south wall (gap to Vault)
	[Vector2(5, -5), Vector2(5, -1.3)], [Vector2(5, 1.3), Vector2(5, 5)],     # east wall (gap to Armory)
	[Vector2(-5, -5), Vector2(-5, 5)],                                       # west wall (solid)

	# North corridor side walls (Hall <-> Study)
	[Vector2(-1.3, -5), Vector2(-1.3, -11)], [Vector2(1.3, -5), Vector2(1.3, -11)],
	# South corridor side walls (Hall <-> Vault)
	[Vector2(-1.3, 5), Vector2(-1.3, 11)], [Vector2(1.3, 5), Vector2(1.3, 11)],
	# East corridor side walls (Hall <-> Armory)
	[Vector2(5, -1.3), Vector2(11, -1.3)], [Vector2(5, 1.3), Vector2(11, 1.3)],

	# Study room (x:-4..4, z:-11..-19), gap on south side (to corridor)
	[Vector2(-4, -11), Vector2(-1.3, -11)], [Vector2(1.3, -11), Vector2(4, -11)],
	[Vector2(-4, -19), Vector2(4, -19)],   # north wall
	[Vector2(4, -19), Vector2(4, -11)],    # east wall
	[Vector2(-4, -19), Vector2(-4, -11)],  # west wall

	# Vault room (x:-4..4, z:11..19), gap on north side (to corridor)
	[Vector2(-4, 11), Vector2(-1.3, 11)], [Vector2(1.3, 11), Vector2(4, 11)],
	[Vector2(-4, 19), Vector2(4, 19)],     # south wall
	[Vector2(4, 11), Vector2(4, 19)],      # east wall
	[Vector2(-4, 11), Vector2(-4, 19)],    # west wall

	# Armory room (x:11..19, z:-4..4), gap on west side is left for the Door (no wall built there)
	[Vector2(19, -4), Vector2(19, 4)],     # east wall
	[Vector2(11, -4), Vector2(19, -4)],    # north wall
	[Vector2(11, 4), Vector2(19, 4)],      # south wall
]

var _floors: Array = [
	{"center": Vector2(0, 0), "size": Vector2(10, 10)},        # Hall
	{"center": Vector2(0, -8), "size": Vector2(2.6, 6)},        # North corridor
	{"center": Vector2(0, 8), "size": Vector2(2.6, 6)},         # South corridor
	{"center": Vector2(8, 0), "size": Vector2(6, 2.6)},         # East corridor
	{"center": Vector2(0, -15), "size": Vector2(8, 8)},         # Study
	{"center": Vector2(0, 15), "size": Vector2(8, 8)},          # Vault
	{"center": Vector2(15, 0), "size": Vector2(8, 8)},          # Armory
]

func _ready() -> void:
	var wall_mat := StandardMaterial3D.new()
	wall_mat.albedo_color = wall_material_color
	wall_mat.roughness = 0.95

	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = floor_material_color
	floor_mat.roughness = 0.9

	for wall in _walls:
		_build_wall(wall[0], wall[1], wall_mat)
	for f in _floors:
		_build_slab(f.center, f.size, -FLOOR_THICKNESS * 0.5, FLOOR_THICKNESS, floor_mat)
		_build_slab(f.center, f.size, WALL_HEIGHT + FLOOR_THICKNESS * 0.5, FLOOR_THICKNESS, floor_mat)

func _build_wall(p1: Vector2, p2: Vector2, mat: StandardMaterial3D) -> void:
	var box := CSGBox3D.new()
	box.use_collision = true
	box.collision_layer = 1
	box.material = mat
	if is_equal_approx(p1.x, p2.x):
		var length: float = absf(p2.y - p1.y) + WALL_THICKNESS
		box.size = Vector3(WALL_THICKNESS, WALL_HEIGHT, length)
	else:
		var length: float = absf(p2.x - p1.x) + WALL_THICKNESS
		box.size = Vector3(length, WALL_HEIGHT, WALL_THICKNESS)
	var center := (p1 + p2) * 0.5
	box.position = Vector3(center.x, WALL_HEIGHT * 0.5, center.y)
	add_child(box)

func _build_slab(center: Vector2, size: Vector2, y: float, thickness: float, mat: StandardMaterial3D) -> void:
	var box := CSGBox3D.new()
	box.use_collision = true
	box.collision_layer = 1
	box.material = mat
	box.size = Vector3(size.x, thickness, size.y)
	box.position = Vector3(center.x, y, center.y)
	add_child(box)
