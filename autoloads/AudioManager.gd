extends Node
## Owns the Music/SFX audio buses and applies SettingsManager volumes.
## Buses are created procedurally at startup so no external bus-layout
## resource is required.

const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

var _music_player: AudioStreamPlayer
var _stinger_player: AudioStreamPlayer

func _ready() -> void:
	_ensure_buses()
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = BUS_MUSIC
	_music_player.name = "MusicPlayer"
	add_child(_music_player)

	_stinger_player = AudioStreamPlayer.new()
	_stinger_player.bus = BUS_SFX
	_stinger_player.name = "StingerPlayer"
	add_child(_stinger_player)

	SettingsManager.settings_changed.connect(_apply_volumes)
	_apply_volumes()

func _ensure_buses() -> void:
	if AudioServer.get_bus_index(BUS_MUSIC) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS_MUSIC)
		AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")
	if AudioServer.get_bus_index(BUS_SFX) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS_SFX)
		AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")

func _apply_volumes() -> void:
	_set_bus_linear(BUS_MUSIC, SettingsManager.music_volume)
	_set_bus_linear(BUS_SFX, SettingsManager.sfx_volume)

func _set_bus_linear(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	AudioServer.set_bus_volume_db(idx, linear_to_db(clampf(linear, 0.0, 1.0)))

func play_stinger(stream: AudioStream) -> void:
	if stream == null:
		return
	_stinger_player.stream = stream
	_stinger_player.play()

func play_music(stream: AudioStream, fade_in: float = 1.5) -> void:
	if stream == null:
		return
	_music_player.stream = stream
	_music_player.volume_db = -40.0
	_music_player.play()
	var tween := create_tween()
	tween.tween_property(_music_player, "volume_db", 0.0, fade_in)

func stop_music(fade_out: float = 1.0) -> void:
	if not _music_player.playing:
		return
	var tween := create_tween()
	tween.tween_property(_music_player, "volume_db", -40.0, fade_out)
	tween.tween_callback(_music_player.stop)
