class_name Puzzle extends Control

enum {
	TOOL_MOVE,
	TOOL_GLUE,
	TOOL_CLEAN,
	TOOL_COUNT
}

const _DEBUG_PRINTS_ENABLED: bool = false

@export var parts: Array[PuzzlePart] = []
var tool: int = TOOL_MOVE:
	set(t):
		assert(t >= 0 and t < TOOL_COUNT, "Invalid tool id %d" % t)
		assert(not _is_dragging, "Cannot switch tools while dragging, this should never happen")
		tool = t

var _hovered_mouse_pick: Array[PuzzleMousePick] = []
var _hovered_glue_zone: Array[GlueZone] = []
var _dragging_part: PuzzlePart = null
var _is_dragging: bool = false:
	get: return _dragging_part != null
	set(v): assert(false, "Read only property")
var _drag_acum: Vector2
var _drag_part_start_pos: Vector2

func _ready() -> void:
	for part in parts:
		for child in part.get_children():
			if child is PuzzleMousePick:
				child.mouse_entered.connect(_on_mouse_pick_mouse_entered.bind(child))
				child.mouse_exited.connect(_on_mouse_pick_mouse_exited.bind(child))
			if child is GlueZone:
				child.mouse_entered.connect(_on_glue_zone_mouse_entered.bind(child))
				child.mouse_exited.connect(_on_glue_zone_mouse_exited.bind(child))

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
				_dragging_part = null
			elif not _is_dragging and event.pressed and _hovered_mouse_pick.size():
				_dragging_part = _hovered_mouse_pick[0].get_dragged_part()
				_drag_part_start_pos = _dragging_part.global_position
				_drag_acum = Vector2.ZERO
	if event is InputEventMouseMotion and _is_dragging:
		_drag_acum += event.relative
		_dragging_part.global_position = _drag_part_start_pos + _drag_acum
		var puzzle_rect: Rect2 = get_global_rect()
		var rect: Rect2 = _dragging_part.get_global_rect()
		if rect.position.x < puzzle_rect.position.x:
			_dragging_part.position.x += puzzle_rect.position.x - rect.position.x
		elif rect.end.x > puzzle_rect.end.x:
			_dragging_part.position.x += puzzle_rect.end.x - rect.end.x
		if rect.position.y < puzzle_rect.position.y:
			_dragging_part.position.y += puzzle_rect.position.y - rect.position.y
		elif rect.end.y > puzzle_rect.end.y:
			_dragging_part.position.y += puzzle_rect.end.y - rect.end.y

func _handle_glue_tool(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		if _hovered_glue_zone.size():
			for zone in _hovered_glue_zone:
				if zone.can_glue():
					zone.is_glued = true
					break
		
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
	if not _hovered_mouse_pick.has(picker):
		_hovered_mouse_pick.append(picker)
		_print_color(Color.SEA_GREEN, "Hover add " + picker.get_parent().name)

func _on_mouse_pick_mouse_exited(picker: PuzzleMousePick):
	if _hovered_mouse_pick.has(picker):
		_hovered_mouse_pick.erase(picker)
		_print_color(Color.DARK_GREEN, "Hover remove " + picker.get_parent().name)

func _on_glue_zone_mouse_entered(zone: GlueZone):
	if not _hovered_glue_zone.has(zone):
		_hovered_glue_zone.append(zone)
		_print_color(Color.DARK_ORANGE, "Hover zone add " + zone.get_parent().name)

func _on_glue_zone_mouse_exited(zone: GlueZone):
	if _hovered_glue_zone.has(zone):
		_hovered_glue_zone.erase(zone)
		_print_color(Color.ORANGE_RED, "Hover zone remove " + zone.get_parent().name)

func _print_color(color: Color, text: String):
	if _DEBUG_PRINTS_ENABLED:
		print_rich("[color=%s]%s[/color]" % [color.to_html(false), text])
