extends Control

const WorkbenchGameScn: PackedScene = preload("res://playground/Puzzle/workbench.tscn")

@onready var temp_workbench: TextureRect = $TempWorkbench
@onready var inventory_slot: InventorySlot = $InventorySlot

var workbench_instance: WorkbenchGame = WorkbenchGameScn.instantiate()


func _ready() -> void:
	# Disable inventory slot inputs
	inventory_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var canvas_layer := CanvasLayer.new()
	canvas_layer.layer = 5
	add_child(canvas_layer)
	canvas_layer.add_child(workbench_instance)
	workbench_instance.visibility_changed.connect(_on_workbench_instance_visibility_changed)

func _gui_input(event: InputEvent) -> void:
	if workbench_instance.is_visible_in_tree():
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT \
				and !event.pressed \
				and temp_workbench.get_rect().has_point(event.position) \
				and is_occupied():
			var puzzle := inventory_slot.take_item() as Puzzle
			workbench_instance.load_puzzle(puzzle)

func is_occupied() -> bool:
	return workbench_instance.is_occupied() or inventory_slot.is_occupied()

func _get_drag_data(at_position: Vector2) -> Variant:
	if workbench_instance.is_visible_in_tree() or not is_occupied():
		return null
	
	if temp_workbench.get_rect().has_point(at_position):
		return inventory_slot._get_drag_data(at_position)
	return null

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if is_occupied():
		return false
	return temp_workbench.get_rect().has_point(at_position) \
			and &"puzzle" in data and data.puzzle is Puzzle

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if &"success_callback" in data:
		data.success_callback.call()
	workbench_instance.load_puzzle(data.puzzle as Puzzle)


func _on_workbench_instance_visibility_changed():
	if not workbench_instance.is_visible_in_tree() and workbench_instance.is_occupied():
		var puzzle: Puzzle = workbench_instance.take_puzzle()
		inventory_slot.drop_item(puzzle)
