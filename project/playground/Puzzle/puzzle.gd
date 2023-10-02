extends Control

@export var parts: Array[MeshInstance2D] = []

var _hovered_mouse_pick: PuzzleMousePick
var _dragging: bool = false

func _ready() -> void:
	for part in parts:
		for child in part.get_children():
			if child is PuzzleJoint:
				child.area_entered.connect(_on_joint_area_entered.bind(child))
			if child is PuzzleMousePick:
				child.mouse_entered.connect(_on_mouse_pick_mouse_entered.bind(child))
				child.mouse_exited.connect(_on_mouse_pick_mouse_exited.bind(child))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_joint_area_entered(joint_a: PuzzleJoint, joint_b: PuzzleJoint):
	pass

func _on_mouse_pick_mouse_entered(picker: PuzzleMousePick):
	if !_dragging:
		_hovered_mouse_pick = picker
		print("Hover: ", picker.get_parent().name)

func _on_mouse_pick_mouse_exited(picker: PuzzleMousePick):
	if !_dragging and _hovered_mouse_pick == picker:
		_hovered_mouse_pick = null
		print("Hover: nothing")
