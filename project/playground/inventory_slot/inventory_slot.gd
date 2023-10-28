class_name InventorySlot extends Panel

signal item_taken()

@onready var sub_viewport: SubViewport = $SlotPreview/SubViewport
var puzzle: Control = null:
	set(v):
		if puzzle != null and v == null:
			item_taken.emit()
		puzzle = v

func _ready() -> void:
	if sub_viewport.get_child_count():
		puzzle = sub_viewport.get_child(0)

func is_occupied() -> bool:
	return puzzle != null

func drop_item(item: Control) -> void:
	assert(!is_occupied())
	puzzle = item
	sub_viewport.add_child(puzzle)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func take_item() -> Control:
	if puzzle == null:
		return null
	sub_viewport.remove_child(puzzle)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	set_deferred(&"puzzle", null)
	return puzzle


func _get_drag_data(_at_position: Vector2) -> Variant:
	if puzzle == null:
		return null
	var preview := TextureRect.new()
	preview.texture = sub_viewport.get_texture()
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	set_drag_preview(preview)
	return {
		success_callback = _on_drag_success,
		puzzle = puzzle
	}

func _on_drag_success():
	sub_viewport.remove_child(puzzle)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	puzzle = null

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return puzzle == null and &"puzzle" in data and data.puzzle is Puzzle


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if &"success_callback" in data:
		data.success_callback.call()
	puzzle = data.puzzle
	if puzzle.get_parent() != null:
		puzzle.get_parent().remove_child(puzzle)
	sub_viewport.add_child(puzzle)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
