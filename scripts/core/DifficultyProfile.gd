extends Resource
class_name DifficultyProfile
## Tunable knobs that scale enemy/bot behaviour per difficulty tier.

@export var id: String = "normal"
@export var display_key: String = "DIFFICULTY_NORMAL"

## Enemy stat multipliers
@export var enemy_health_mult: float = 1.0
@export var enemy_damage_mult: float = 1.0
@export var enemy_move_speed_mult: float = 1.0
@export var enemy_detection_radius_mult: float = 1.0
@export var enemy_hearing_radius_mult: float = 1.0
@export var enemy_reaction_time: float = 0.5 ## seconds between noticing and reacting
@export var enemy_search_duration: float = 6.0 ## seconds spent searching last known position
@export var enemy_aim_error_deg: float = 6.0 ## ranged bot aim cone error, degrees

## Player-facing scarcity
@export var loot_spawn_mult: float = 1.0
@export var player_damage_taken_mult: float = 1.0
@export var save_anywhere: bool = false
