extends RefCounted

var interval_seconds: float = 60.0
var elapsed_seconds: float = 0.0
var dirty: bool = false
var enabled: bool = true


func _init(p_interval_seconds: float = 60.0) -> void:
	interval_seconds = maxf(5.0, p_interval_seconds)


func set_dirty() -> void:
	dirty = true


func clear_dirty() -> void:
	dirty = false
	elapsed_seconds = 0.0


func has_dirty_changes() -> bool:
	return dirty


func reset_timer() -> void:
	elapsed_seconds = 0.0


func set_enabled(value: bool) -> void:
	enabled = value
	if not enabled:
		elapsed_seconds = 0.0


func process(delta: float) -> bool:
	if not enabled:
		return false
	if not dirty:
		elapsed_seconds = 0.0
		return false
	elapsed_seconds += delta
	if elapsed_seconds >= interval_seconds:
		elapsed_seconds = 0.0
		return true
	return false
