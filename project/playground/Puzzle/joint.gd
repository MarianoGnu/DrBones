@tool
class_name PuzzleJoint extends Area2D

@export_range(5, 10, 1, "or_greater") var match_id: int = 5:
	set = _set_match_id

func _set_match_id(id) -> void:
	match_id = id
	collision_layer = 1 << (id - 1)
	collision_mask = 1 << (id - 1)

func is_joint_connected() -> bool:
	var candidates: Array[Area2D] = get_overlapping_areas()
	for other in candidates:
		if other is PuzzleJoint:
			return true
	return false
