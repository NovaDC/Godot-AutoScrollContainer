@tool
@icon("res://addons/autoscroll_container/autoscroll_container.svg")
class_name AutoScrollContainer
extends ScrollContainer

## AutoscrollContainer
##
## A [ScrollContainer] that automatically scrolls a specified amount after a specified amount of
## time passes with no caught input (to this specific controll).

## Amount of time to wait in seconds before scrolling.
@export var scroll_time_sec:float = 4

## The amount of pixels per second to scroll.
## Since the amount of pixels scrolled is a intiger value, a non zero value here will grantee that
## the amount of pixels scrolled will be at least one
## (preserving the approiprate direction/sign, though).
@export var scroll_px_per_sec := Vector2.ONE * 3

## Autoscroll in editor.
@export var in_editor := false

## Allow the timer counting down to start scrolling to count even when the tree is paused.
## This will NOT effect weather or not the actual scrolling will process when paused,
## [member Node.process_mode] must be used to control this behaviour.
@export var scroll_time_process_always := false

## Allow the timer counting down to ignore time scale.
@export var scroll_time_ignore_time_scale := false

var _current_timer:SceneTreeTimer = null

func _ready():
	restart_scroll_timer()

func _gui_input(_event:InputEvent):
	restart_scroll_timer()

func _process(delta: float):
	if not in_editor and Engine.is_editor_hint():
		return
	
	if _current_timer != null and _current_timer.time_left <= 0:
		var scroll_diff := Vector2i(round(delta*scroll_px_per_sec))
		scroll_horizontal += scroll_diff.x if scroll_diff.x != 0 else sign(scroll_px_per_sec.x)
		scroll_vertical += scroll_diff.y if scroll_diff.y != 0 else sign(scroll_px_per_sec.y)

## Restarts the scroll timer. Will stop the scrolling of this container, but not reset it.
func restart_scroll_timer():
	if not in_editor and Engine.is_editor_hint():
		return
	var tree := get_tree()
	if tree != null:
		var timer := tree.create_timer(scroll_time_sec,
									   scroll_time_process_always,
									   false,
									   scroll_time_ignore_time_scale
									  )
		_current_timer = timer
