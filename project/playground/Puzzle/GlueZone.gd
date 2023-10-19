@tool
class_name GlueZone extends Area2D

@export_range(5, 10, 1, "or_greater") var match_id: int = 5:
	set = _set_match_id

@onready var puzzle: Puzzle = owner as Puzzle
@onready var joint_parts: Array[PuzzlePart] = puzzle.get_parts_with_match_id(match_id)

var _remote_transforms: Array[RemoteTransform2D]

var is_glued: bool = false:
	set = _set_is_glued

func can_glue() -> bool:
	for part in joint_parts:
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
	if is_glued and _remote_transforms.is_empty():
		for part in joint_parts:
			if part == get_parent():
				# Glue zone is a child of a root part, we can skip it
				continue
			part.glued_root = get_parent()
			var glue := RemoteTransform2D.new()
			glue.name = "Glue_" + part.name
			add_child(glue)
			glue.remote_path = part.get_path()
			_remote_transforms.push_back(glue)
	elif not is_glued and not _remote_transforms.is_empty():
		for part in joint_parts:
			if part == get_parent():
				# Glue zone is a child of a root part
				continue
			# drag and drop root becomes itself
			part.glued_root = part 
		for glue in _remote_transforms:
			glue.queue_free()
		_remote_transforms.clear()
