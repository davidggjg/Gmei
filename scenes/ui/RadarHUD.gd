extends Control
class_name RadarHUD
## Rotating top-down radar: shows nearby enemies/bots as dots relative to
## the player's facing direction. Drawn procedurally, no map texture needed.

@export var radar_range: float = 26.0
@export var enemy_group: String = "enemy" ## set to "br_bot" for Battle Royale

var player: Player
var _radius: float

func _ready() -> void:
	_radius = size.x / 2.0
	resized.connect(func(): _radius = size.x / 2.0)
	set_process(true)

func bind_player(p: Player, group: String = "enemy") -> void:
	player = p
	enemy_group = group

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var center := Vector2(_radius, _radius)
	draw_circle(center, _radius, Color(0.05, 0.08, 0.06, 0.55))
	draw_arc(center, _radius, 0, TAU, 40, Color(0.4, 0.9, 0.5, 0.7), 2.5, true)
	draw_circle(center, 4.0, Color(0.4, 0.9, 1.0, 0.9)) # player marker

	if player == null or not is_instance_valid(player):
		return

	var yaw := player.rotation.y
	for node: Node3D in get_tree().get_nodes_in_group(enemy_group):
		if not is_instance_valid(node) or node == player:
			continue
		if "health" in node and node.health.is_dead:
			continue
		var to: Vector3 = (node.global_position - player.global_position)
		to.y = 0.0
		var dist: float = to.length()
		if dist > radar_range:
			continue
		var flat := Vector2(to.x, to.z).rotated(yaw) # counter-rotate into player-facing space
		var radar_pos := center + Vector2(flat.x, flat.y) * (_radius / radar_range)
		draw_circle(radar_pos, 4.5, Color(0.95, 0.2, 0.15, 0.95))
