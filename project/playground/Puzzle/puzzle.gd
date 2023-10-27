class_name Puzzle extends Control

enum {
	TOOL_MOVE,
	TOOL_GLUE,
	TOOL_CLEAN,
	TOOL_COUNT
}

const _DEBUG_PRINTS_AND_DRAW_ENABLED: bool = false

var parts: Array[PuzzlePart] = []
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
	set(_v): assert(false, "Read only property")
var _drag_acum: Vector2
var _drag_part_start_pos: Vector2
var _drag_part_start_rect: Rect2

func _notification(what: int) -> void:
	if what != NOTIFICATION_SCENE_INSTANTIATED:
		return
	for child in get_children():
		if child is PuzzlePart:
			parts.push_back(child)
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
				_drag_part_start_pos = _dragging_part.position
				_drag_part_start_rect = _dragging_part.get_glued_rect()
				_drag_acum = Vector2.ZERO
	if event is InputEventMouseMotion and _is_dragging:
		_drag_acum += event.relative
		var target_position: Vector2 = _drag_part_start_pos + _drag_acum
		var puzzle_rect := Rect2(Vector2(), size)
		var rect: Rect2 = _drag_part_start_rect
		rect.position += _drag_acum
		if rect.position.x < puzzle_rect.position.x:
			target_position.x += puzzle_rect.position.x - rect.position.x
		elif rect.end.x > puzzle_rect.end.x:
			target_position.x += puzzle_rect.end.x - rect.end.x
		if rect.position.y < puzzle_rect.position.y:
			target_position.y += puzzle_rect.position.y - rect.position.y
		elif rect.end.y > puzzle_rect.end.y:
			target_position.y += puzzle_rect.end.y - rect.end.y
		for part in get_parts_glued_to(_dragging_part.glued_root):
			part.position = target_position
		queue_redraw()

func _handle_glue_tool(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		if _hovered_glue_zone.size():
			for zone in _hovered_glue_zone:
				if zone.can_glue():
					zone.is_glued = true
					break

func _handle_clean_tool(_event: InputEvent) -> void:
	# TODO
	pass

func _draw() -> void:
	if not _DEBUG_PRINTS_AND_DRAW_ENABLED or _dragging_part == null:
		return
	var rect: Rect2 = _dragging_part.get_glued_global_rect()
	rect.position -= global_position
	draw_rect(rect, Color.ORANGE_RED, false, 2)
	draw_rect(Rect2(Vector2(), size), Color.LIGHT_SEA_GREEN, false, 2)

func get_parts_with_match_id(p_match_id: int) -> Array[PuzzlePart]:
	var matching_parts: Array[PuzzlePart] = []
	for part in parts:
		for child in part.get_children():
			if child is PuzzleJoint and child.match_id == p_match_id:
				matching_parts.push_back(part)
				break
	assert(matching_parts.size() >= 2, "Unexpected size of collection, there should be at least " +
			"2 parts with the same ID %d in order to glue them" % p_match_id)
	return matching_parts

func get_parts_glued_to(p_glue_root) -> Array[PuzzlePart]:
	var glued_parts: Array[PuzzlePart] = []
	for part in parts:
		if part.glued_root == p_glue_root:
			glued_parts.append(part)
	return glued_parts

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
	if _DEBUG_PRINTS_AND_DRAW_ENABLED:
		print_rich("[color=%s]%s[/color]" % [color.to_html(false), text])
