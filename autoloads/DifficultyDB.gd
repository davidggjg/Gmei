extends Node
## Registry of the four difficulty tiers, built in code so no .tres assets
## are required. Used by both the campaign AI and the Battle Royale bots.

const EASY := "easy"
const NORMAL := "normal"
const HARD := "hard"
const NIGHTMARE := "nightmare"

var profiles: Dictionary = {}

func _ready() -> void:
	_build_profiles()

func _build_profiles() -> void:
	var easy := DifficultyProfile.new()
	easy.id = EASY
	easy.display_key = "DIFFICULTY_EASY"
	easy.enemy_health_mult = 0.75
	easy.enemy_damage_mult = 0.6
	easy.enemy_move_speed_mult = 0.85
	easy.enemy_detection_radius_mult = 0.75
	easy.enemy_hearing_radius_mult = 0.75
	easy.enemy_reaction_time = 0.9
	easy.enemy_search_duration = 4.0
	easy.enemy_aim_error_deg = 12.0
	easy.loot_spawn_mult = 1.4
	easy.player_damage_taken_mult = 0.7
	easy.save_anywhere = true
	profiles[EASY] = easy

	var normal := DifficultyProfile.new()
	normal.id = NORMAL
	normal.display_key = "DIFFICULTY_NORMAL"
	normal.enemy_health_mult = 1.0
	normal.enemy_damage_mult = 1.0
	normal.enemy_move_speed_mult = 1.0
	normal.enemy_detection_radius_mult = 1.0
	normal.enemy_hearing_radius_mult = 1.0
	normal.enemy_reaction_time = 0.5
	normal.enemy_search_duration = 6.0
	normal.enemy_aim_error_deg = 6.0
	normal.loot_spawn_mult = 1.0
	normal.player_damage_taken_mult = 1.0
	normal.save_anywhere = false
	profiles[NORMAL] = normal

	var hard := DifficultyProfile.new()
	hard.id = HARD
	hard.display_key = "DIFFICULTY_HARD"
	hard.enemy_health_mult = 1.35
	hard.enemy_damage_mult = 1.4
	hard.enemy_move_speed_mult = 1.15
	hard.enemy_detection_radius_mult = 1.25
	hard.enemy_hearing_radius_mult = 1.25
	hard.enemy_reaction_time = 0.3
	hard.enemy_search_duration = 9.0
	hard.enemy_aim_error_deg = 3.0
	hard.loot_spawn_mult = 0.8
	hard.player_damage_taken_mult = 1.3
	hard.save_anywhere = false
	profiles[HARD] = hard

	var nightmare := DifficultyProfile.new()
	nightmare.id = NIGHTMARE
	nightmare.display_key = "DIFFICULTY_NIGHTMARE"
	nightmare.enemy_health_mult = 1.75
	nightmare.enemy_damage_mult = 2.0
	nightmare.enemy_move_speed_mult = 1.3
	nightmare.enemy_detection_radius_mult = 1.6
	nightmare.enemy_hearing_radius_mult = 1.6
	nightmare.enemy_reaction_time = 0.15
	nightmare.enemy_search_duration = 14.0
	nightmare.enemy_aim_error_deg = 1.0
	nightmare.loot_spawn_mult = 0.55
	nightmare.player_damage_taken_mult = 1.75
	nightmare.save_anywhere = false
	profiles[NIGHTMARE] = nightmare

func get_profile(id: String) -> DifficultyProfile:
	return profiles.get(id, profiles[NORMAL])

func all_ids() -> Array:
	return [EASY, NORMAL, HARD, NIGHTMARE]
