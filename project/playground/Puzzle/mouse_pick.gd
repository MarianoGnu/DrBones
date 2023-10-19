class_name PuzzleMousePick extends Area2D

func get_dragged_part() -> PuzzlePart:
	var part: PuzzlePart = get_parent() as PuzzlePart
	assert(part != null and part.glued_root != null,
			"Invalid parent for PuzzleMousePick")
	return part.glued_root as PuzzlePart
