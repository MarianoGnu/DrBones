class_name WorkbenchGame extends CenterContainer

var _exit_button: Button
var _puzzle_container: PanelContainer
var _tool_button_drag: Button
var _tool_button_glue: Button
var _tool_button_clean: Button
var _tool_map: Dictionary = {}
var _puzzle: Puzzle = null

func _notification(what: int) -> void:
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		_exit_button = %ExitButton
		_puzzle_container = %PuzzleContainer as PanelContainer
		_tool_button_drag = %ToolButtonDrag as Button
		_tool_button_glue = %ToolButtonGlue as Button
		_tool_button_clean = %ToolButtonClean as Button
		_tool_map = {
			_tool_button_drag : Puzzle.TOOL_MOVE,
			_tool_button_glue : Puzzle.TOOL_GLUE,
			_tool_button_clean : Puzzle.TOOL_CLEAN
		}
		_exit_button.pressed.connect(_on_exit_button_pressed)
		var tool_button_group: ButtonGroup = _tool_button_drag.button_group
		tool_button_group.pressed.connect(_on_tool_button_group_pressed)

func _ready() -> void:
	hide()

func is_occupied() -> bool:
	return _puzzle != null

func load_puzzle(new_puzzle: Puzzle) -> void:
	assert(new_puzzle != null)
	if new_puzzle.is_inside_tree():
		new_puzzle.get_parent().remove_child(new_puzzle)
	if _puzzle:
		_puzzle.queue_free()
	_puzzle = new_puzzle
	_puzzle_container.add_child(new_puzzle)
	show()

func take_puzzle() -> Puzzle:
	_puzzle_container.remove_child(_puzzle)
	set_deferred(&"_puzzle", null)
	return _puzzle

func _on_exit_button_pressed():
	hide()

func _on_tool_button_group_pressed(p_button: BaseButton):
	if _puzzle != null:
		_puzzle.tool = _tool_map[p_button]
