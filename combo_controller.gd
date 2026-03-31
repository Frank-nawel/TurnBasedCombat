extends Node

signal combo_step_ready(level: String, step: int)

const MAX_STEPS: int      = 3
const INPUT_WINDOW: float = 0.6

var _current_step: int   = 0
var _timer:        float = 0.0
var _anim_running: bool  = false
var _window_open:  bool  = false
var _buffered_level: String = ""


func _process(delta: float) -> void:
	if not _window_open:
		return
	_timer -= delta
	if _timer <= 0.0:
		_reset()


func register_input(level: String) -> void:
	if _anim_running:
		_buffered_level = level
		return
	_fire(level)


func notify_step_finished() -> void:
	_anim_running = false

	if not _buffered_level.is_empty():
		var level: String = _buffered_level
		_buffered_level = ""
		# Diferir para que la señal animation_finished termine de procesarse
		# antes de cambiar el estado
		call_deferred("_fire", level)
	else:
		_window_open = true
		_timer       = INPUT_WINDOW


func cancel() -> void:
	_reset()


func _fire(level: String) -> void:
	_current_step = wrapi(_current_step, 0, MAX_STEPS) + 1
	_anim_running = true
	_window_open  = false
	_timer        = 0.0
	combo_step_ready.emit(level, _current_step)


func _reset() -> void:
	_current_step   = 0
	_anim_running   = false
	_window_open    = false
	_timer          = 0.0
	_buffered_level = ""
