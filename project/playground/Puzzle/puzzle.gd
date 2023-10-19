class_name Puzzle extends Control

enum {
	TOOL_MOVE,
	TOOL_GLUE,
	TOOL_CLEAN,
	TOOL_COUNT
}

@export var parts: Array[PuzzlePart] = []
var tool: int = TOOL_MOVE:
	set(t):
		assert(t >= 0 and t < TOOL_COUNT, "Invalid tool id %d" % t)
		assert(not _is_dragging, "Cannot switch tools while dragging, this should never happen")
		tool = t

var _hovered_mouse_pick: PuzzleMousePick
var _is_dragging: bool = false
var _drag_acum: Vector2
var _drag_part_start_pos: Vector2

func _ready() -> void:
	for part in parts:
		for child in part.get_children():
			if child is PuzzleMousePick:
				child.mouse_entered.connect(_on_mouse_pick_mouse_entered.bind(child))
				child.mouse_exited.connect(_on_mouse_pick_mouse_exited.bind(child))

func _gui_input(event: InputEvent) -> void:
	match tool:
		TOOL_MOVE:
			_handle_move_tool(event)
		TOOL_GLUE:
			_handle_glue_tool(event)
		TOOL_CLEAN:
			_handle_clean_tool(event)
		_:
			assert(false, "Current tool %d is invalid, this should never happen" % tool)

func _handle_move_tool(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if _is_dragging and not event.pressed:
				_is_dragging = false
			elif not _is_dragging and event.pressed and _hovered_mouse_pick != null:
				_is_dragging = true
				var part: PuzzlePart = _hovered_mouse_pick.get_dragged_part()
				_drag_part_start_pos = part.global_position
				_drag_acum = Vector2.ZERO
	if event is InputEventMouseMotion and _is_dragging:
		assert(_hovered_mouse_pick != null, "Invalid state, cannot drag without a valid target")
		var part: PuzzlePart = _hovered_mouse_pick.get_dragged_part()
		_drag_acum += event.relative
		part.global_position = _drag_part_start_pos + _drag_acum
		var puzzle_rect: Rect2 = get_global_rect()
		var rect: Rect2 = part.get_global_rect()
		if rect.position.x < puzzle_rect.position.x:
			part.position.x += puzzle_rect.position.x - rect.position.x
		elif rect.end.x > puzzle_rect.end.x:
			part.position.x += puzzle_rect.end.x - rect.end.x
		if rect.position.y < puzzle_rect.position.y:
			part.position.y += puzzle_rect.position.y - rect.position.y
		elif rect.end.y > puzzle_rect.end.y:
			part.position.y += puzzle_rect.end.y - rect.end.y

func _handle_glue_tool(_event: InputEvent) -> void:
	# TODO
	pass

func _handle_clean_tool(_event: InputEvent) -> void:
	# TODO
	pass

func get_parts_with_match_id(p_match_id: int) -> Array[PuzzlePart]:
	var matching_parts: Array[PuzzlePart] = []
	for part in parts:
		for child in part.get_children():
			if child is PuzzleJoint and child.match_id == p_match_id:
				matching_parts.push_back(part)
				break
	assert(matching_parts.size() >= 2, "Unexpected size of collection, there should be at least " +
			"2 parts with the same ID in order to glue them")
	return matching_parts

func _on_mouse_pick_mouse_entered(picker: PuzzleMousePick):
	if !_is_dragging:
		_hovered_mouse_pick = picker
		print("Hover: ", picker.get_parent().name)

func _on_mouse_pick_mouse_exited(picker: PuzzleMousePick):
	if !_is_dragging and _hovered_mouse_pick == picker:
		_hovered_mouse_pick = null
		print("Hover: nothing")
