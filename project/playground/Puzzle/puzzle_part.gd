class_name PuzzlePart extends Node2D

var mesh_instance: MeshInstance2D
var glued_root: PuzzlePart = self:
	get = get_glued_root,
	set = set_glued_root
var _rect: Rect2


func _ready() -> void:
	var mesh_is_self: bool = true
	if (self as Node2D) is MeshInstance2D:
		mesh_instance = self as Node2D
	else:
		assert(get_child(0) is MeshInstance2D, "Invalid child 0 of part %s at %s" % [name, owner.scene_file_path])
		mesh_instance = get_child(0)
		mesh_is_self = false
	var array_mesh = mesh_instance.mesh as ArrayMesh
	if (array_mesh == null):
		push_error("Can't construct Rect2 of invalid ArrayMesh " + name)
		return
	for surface_idx in range(array_mesh.get_surface_count()):
		for point in array_mesh.surface_get_arrays(surface_idx)[ArrayMesh.ARRAY_VERTEX]:
			point = point * mesh_instance.global_scale
			if _rect.position == Vector2.ZERO:
				_rect.position = Vector2(point.x, point.y)
			else:
				_rect = _rect.expand(Vector2(point.x, point.y))
	if not mesh_is_self:
		_rect.position += mesh_instance.position

func get_rect():
	var local_rect: Rect2 = _rect
	local_rect.position += position
	if glued_root != self:
		local_rect = local_rect.merge(glued_root.get_rect())
	return local_rect

func get_global_rect():
	var local_rect: Rect2 = _rect
	local_rect.position += global_position
	if glued_root != self:
		local_rect = local_rect.merge(glued_root.get_global_rect())
	return local_rect

func get_glued_rect() -> Rect2:
	var puzzle: Puzzle = owner as Puzzle
	assert(puzzle, "Unexpected scene hierarchy for this PuzzlePart")
	var glued_rect: Rect2 = get_rect()
	var glued_parts: Array[PuzzlePart] = puzzle.get_parts_glued_to(glued_root)
	for part in glued_parts:
		glued_rect = glued_rect.merge(part.get_rect())
	return glued_rect

func get_glued_global_rect() -> Rect2:
	var puzzle: Puzzle = owner as Puzzle
	assert(puzzle, "Unexpected scene hierarchy for this PuzzlePart")
	var glued_rect: Rect2 = get_global_rect()
	var glued_parts: Array[PuzzlePart] = puzzle.get_parts_glued_to(glued_root)
	for part in glued_parts:
		glued_rect = glued_rect.merge(part.get_global_rect())
	return glued_rect

func get_joint_with_match_id(p_match_id) -> PuzzleJoint:
	for child in get_children():
		if child is PuzzleJoint and child.match_id == p_match_id:
			return child
	print_debug("Requested joint with unmatched id %d" % p_match_id)
	return null

func get_glued_root() -> PuzzlePart:
	if glued_root == self:
		return self
	return glued_root.get_glued_root()

func set_glued_root(p_root: PuzzlePart):
	var prev_root: PuzzlePart = glued_root
	if p_root == prev_root:
		return
	glued_root = p_root
	if prev_root != self and prev_root != p_root:
		prev_root.glued_root = p_root
	
