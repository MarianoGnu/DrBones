@tool
class_name GlueZone extends Area2D

@export_range(5, 10, 1, "or_greater") var match_id: int = 5:
	set = _set_match_id

@onready var puzzle: Puzzle = owner as Puzzle

var _joint_parts: Array[PuzzlePart] = []
var _visuals := Polygon2D.new()

var is_glued: bool = false:
	set = _set_is_glued
var is_clean: bool = false:
	set = _set_is_clean

func _ready() -> void:
	_visuals.color = Color.LIME_GREEN
	_visuals.z_index = 5
	add_child(_visuals)
	if Engine.is_editor_hint():
		return
	_joint_parts = puzzle.get_parts_with_match_id(match_id)
	for child in get_children():
		if child is CollisionPolygon2D:
			_visuals.polygon = child.polygon
			break
	_update_visuals()

func can_glue() -> bool:
	if Engine.is_editor_hint():
		return false
	if is_glued:
		return false
	for part in _joint_parts:
		var joint: PuzzleJoint = part.get_joint_with_match_id(match_id)
		if not joint.is_joint_connected():
			return false
	return true

func _set_match_id(id) -> void:
	match_id = id
	collision_layer = 1 << (id - 1)
	collision_mask = 1 << (id - 1)

func _set_is_glued(glued: bool) -> void:
	is_glued = glued
	if Engine.is_editor_hint():
		return
	if is_glued:
		for part in _joint_parts:
			if part == get_parent():
				# Glue zone is a child of a root part, we can skip it
				continue
			part.glued_root = get_parent()
			var glue := RemoteTransform2D.new()
			glue.name = "Glue_" + part.name
			add_child(glue)
			glue.remote_path = part.get_path()
		is_clean = false
	elif not is_glued:
		for part in _joint_parts:
			if part == get_parent():
				# Glue zone is a child of a root part
				continue
			# drag and drop root becomes itself
			part.glued_root = part 
		is_clean = true

func _set_is_clean(clean: bool) -> void:
	is_clean = clean
	_update_visuals()

func _update_visuals() -> void:
	_visuals.visible = is_glued and not is_clean
