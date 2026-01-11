@tool
@icon("res://addons/autoscroll_container/autoscroll_container.svg")
class_name AutoScrollContainer
extends ScrollContainer

## AutoscrollContainer
##
## A [ScrollContainer] that automatically scrolls a specified amount after a specified amount of
## time passes with no caught input (to this specific controll).

## Amount of time to wait in seconds before scrolling.
@export var scroll_time_delay_sec:float = 4

@export var scrolls_per_sec := Vector2.ONE / 4

## Autoscroll in editor.
@export var in_editor := false

enum AnimationMode{
	STOP = 0,
	WRAP,
	PINGPONG
}

@export var animation_mode:AnimationMode = AnimationMode.PINGPONG

@export var pause_on_input := true

@export var pause_on_gui_input := false

@export var pause_on_unhandled_input := false

var _delta_time_countup:float = 0.0
var _scroll_base_progress := Vector2.ZERO
var _animation_progress_accumulated := Vector2.ONE

func _ready():
	pause_scroll_timer(true)

func _input(event: InputEvent):
	if pause_on_input:
		pause_scroll_timer()

func _gui_input(event: InputEvent):
	if pause_on_gui_input:
		pause_scroll_timer()

func _unhandled_input(event: InputEvent):
	if pause_on_unhandled_input:
		pause_scroll_timer()

func _process(delta:float):
	if not in_editor and Engine.is_editor_hint():
		return

	_delta_time_countup += delta

	if _delta_time_countup < scroll_time_delay_sec:
		return

	_animation_progress_accumulated += delta * scrolls_per_sec

	var animation_bound := _animation_progress_accumulated

	match (animation_mode):
		AnimationMode.WRAP:
			animation_bound = animation_bound.posmod(1)
		AnimationMode.PINGPONG:
			animation_bound = ((animation_bound + Vector2.ONE).posmod(2) - Vector2.ONE).abs()
		_:
			animation_bound = animation_bound.clampf(0, 1)

	var h_prog := get_h_scroll_bar()
	var v_prog := get_v_scroll_bar()

	if h_prog != null:
		h_prog.value = lerp(h_prog.min_value,
							h_prog.max_value - h_prog.page,
							animation_bound.x
							)
		if not is_finite(h_prog.value):
			# catches both situations where lerping will return NAN,
			# as well as manually inputed states involving non finite values,
			# so the progress bar's paramiters dont need to be checked anywhere else but here
			h_prog.value = 0.0

	if v_prog != null:
		v_prog.value = lerp(v_prog.min_value,
							v_prog.max_value - v_prog.page,
							animation_bound.y
							)
		if not is_finite(v_prog.value):
			# catches both situations where lerping will return NAN,
			# as well as manually inputed states involving non finite values,
			# so the progress bar's paramiters dont need to be checked anywhere else but here
			v_prog.value = 0.0


func pause_scroll_timer(restart_direction := false):
	if not in_editor and Engine.is_editor_hint():
		return

	_delta_time_countup = 0.0

	var h_prog := get_h_scroll_bar()
	var v_prog := get_v_scroll_bar()

	var prog_offset := Vector2.ZERO

	if h_prog != null:
		prog_offset.x = inverse_lerp(h_prog.min_value,
										h_prog.max_value - h_prog.page,
										h_prog.value
										)
		if is_finite(prog_offset.x):
			prog_offset.x = 0

	if v_prog != null:
		prog_offset.y = inverse_lerp(v_prog.min_value,
										v_prog.max_value - v_prog.page,
										v_prog.value
										)
		if not is_finite(prog_offset.y):
			prog_offset.y = 0

	if restart_direction:
		_animation_progress_accumulated = prog_offset
	else:
		match (animation_mode):
			AnimationMode.PINGPONG:
				_animation_progress_accumulated = _animation_progress_accumulated.floor().posmod(2) + prog_offset
			_:
				_animation_progress_accumulated = prog_offset
