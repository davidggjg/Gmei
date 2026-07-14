extends Interactable
class_name Pickup
## World item pickup. A small colored placeholder mesh (matching the item's
## icon_color) is generated automatically - no imported model required.

signal picked_up(item_id: String, count: int)

@export var item_id: String = ""
@export var count: int = 1

var _visual: MeshInstance3D

func _ready() -> void:
	super._ready()
	one_shot = true
	prompt_key = "HUD_PICKED_UP"
	add_to_group("pickup")
	_build_visual()
	set_physics_process(true)

func _build_visual() -> void:
	var item := ItemDB.get_item(item_id)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.28, 0.28, 0.28)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = item.icon_color if item else Color(1, 1, 1)
	mat.emission_enabled = true
	mat.emission = mat.albedo_color
	mat.emission_energy_multiplier = 0.4
	_visual = MeshInstance3D.new()
	_visual.mesh = mesh
	_visual.material_override = mat
	_visual.position.y = 0.5
	add_child(_visual)

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.6, 0.6, 0.6)
	shape.shape = box
	shape.position.y = 0.5
	add_child(shape)

func _physics_process(delta: float) -> void:
	if _visual:
		_visual.rotate_y(delta * 1.4)
		_visual.position.y = 0.5 + sin(Time.get_ticks_msec() * 0.002) * 0.08

func interact(actor: Node) -> void:
	if not can_interact(actor):
		return
	var inventory: Inventory = actor.get_node_or_null("Inventory")
	if inventory == null:
		return
	if inventory.add_item(item_id, count):
		super(actor)
		picked_up.emit(item_id, count)
		queue_free()
