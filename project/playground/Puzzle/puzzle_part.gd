class_name PuzzlePart extends MeshInstance2D

var glued_root: PuzzlePart = self
var _rect: Rect2


func _ready() -> void:
	var array_mesh = mesh as ArrayMesh
	if (array_mesh == null):
		push_error("Can't construct Rect2 of invalid ArrayMesh " + name)
		return
	for surface_idx in range(array_mesh.get_surface_count()):
		for point in array_mesh.surface_get_arrays(surface_idx)[ArrayMesh.ARRAY_VERTEX]:
			if _rect.position == Vector2.ZERO:
				_rect.position = Vector2(point.x, point.y)
			else:
				_rect = _rect.expand(Vector2(point.x, point.y))

func get_rect():
	var local_rect: Rect2 = _rect
	local_rect.position += position
	return local_rect

func get_global_rect():
	var local_rect: Rect2 = _rect
	local_rect.position += global_position
	return local_rect

func get_joint_with_match_id(p_match_id) -> PuzzleJoint:
	for child in get_children():
		if child is PuzzleJoint and child.match_id == p_match_id:
			return child
	print_debug("Requested joint with unmatched id %d" % p_match_id)
	return null
