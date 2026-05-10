extends Node

const MIX_RATE: int = 22050
const MIN_VOLUME: float = 0.01

var enabled: bool = true
var volume: float = 0.7
var players: Dictionary = {}
var streams: Dictionary = {}


func setup(settings_manager: RefCounted) -> void:
	if settings_manager != null:
		if settings_manager.has_method("get_sfx_enabled"):
			enabled = bool(settings_manager.get_sfx_enabled())
		if settings_manager.has_method("get_sfx_volume"):
			volume = _sanitize_volume(float(settings_manager.get_sfx_volume()))
	_build_streams()
	_build_players()


func set_enabled(value: bool) -> void:
	enabled = value
	if not enabled:
		stop_all()


func set_volume(value: float) -> void:
	volume = _sanitize_volume(value)
	for key: Variant in players.keys():
		var player: AudioStreamPlayer = players[key] as AudioStreamPlayer
		if player != null:
			player.volume_db = linear_to_db(maxf(MIN_VOLUME, volume))


func play(sound_id: String) -> void:
	if not enabled:
		return
	if not players.has(sound_id):
		return
	var player: AudioStreamPlayer = players[sound_id] as AudioStreamPlayer
	if player == null or player.stream == null:
		return
	player.volume_db = linear_to_db(maxf(MIN_VOLUME, volume))
	player.stop()
	player.play()


func stop_all() -> void:
	for key: Variant in players.keys():
		var player: AudioStreamPlayer = players[key] as AudioStreamPlayer
		if player != null:
			player.stop()


func _build_players() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	players.clear()
	for key: Variant in streams.keys():
		var sound_id: String = str(key)
		var stream: AudioStream = streams[sound_id] as AudioStream
		if stream == null:
			continue
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "Sfx_" + sound_id
		player.stream = stream
		player.volume_db = linear_to_db(maxf(MIN_VOLUME, volume))
		add_child(player)
		players[sound_id] = player


func _build_streams() -> void:
	streams.clear()
	streams["ui_click"] = _make_tone(650.0, 0.05, 0.18)
	streams["place"] = _make_sequence([[720.0, 0.045, 0.18], [940.0, 0.065, 0.20]])
	streams["move"] = _make_tone(520.0, 0.07, 0.18)
	streams["rotate"] = _make_sequence([[720.0, 0.035, 0.16], [860.0, 0.035, 0.16]])
	streams["delete"] = _make_sequence([[300.0, 0.055, 0.18], [190.0, 0.075, 0.20]])
	streams["error"] = _make_tone(160.0, 0.16, 0.25)
	streams["mission_complete"] = _make_sequence([[720.0, 0.05, 0.16], [920.0, 0.05, 0.18], [1160.0, 0.08, 0.20]])
	streams["credits"] = _make_sequence([[1050.0, 0.045, 0.14], [1320.0, 0.08, 0.18]])
	streams["chat_send"] = _make_tone(760.0, 0.06, 0.15)
	streams["panel_open"] = _make_sequence([[420.0, 0.035, 0.12], [560.0, 0.045, 0.14]])
	streams["panel_close"] = _make_tone(360.0, 0.06, 0.15)


func _make_tone(frequency: float, duration: float, amplitude: float = 0.25) -> AudioStreamWAV:
	return _make_sequence([[frequency, duration, amplitude]])


func _make_sequence(parts: Array) -> AudioStreamWAV:
	var sample_count: int = 0
	for part_variant: Variant in parts:
		var part: Array = part_variant as Array
		if part.size() >= 2:
			sample_count += maxi(1, int(float(part[1]) * float(MIX_RATE)))
	var data: PackedByteArray = PackedByteArray()
	data.resize(sample_count * 2)
	var offset: int = 0
	for part_variant: Variant in parts:
		var part: Array = part_variant as Array
		if part.size() < 2:
			continue
		var frequency: float = float(part[0])
		var duration: float = float(part[1])
		var amplitude: float = float(part[2]) if part.size() >= 3 else 0.25
		var part_samples: int = maxi(1, int(duration * float(MIX_RATE)))
		for i: int in range(part_samples):
			var t: float = float(i) / float(MIX_RATE)
			var fade: float = 1.0 - (float(i) / float(part_samples))
			var sample: float = sin(TAU * frequency * t) * amplitude * fade
			var value: int = int(clampf(sample, -1.0, 1.0) * 32767.0)
			data.encode_s16((offset + i) * 2, value)
		offset += part_samples
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream


func _sanitize_volume(value: float) -> float:
	if is_nan(value) or is_inf(value):
		return 0.7
	return clampf(value, 0.0, 1.0)
