extends CenterContainer

var _puzzle_container: PanelContainer
var _tool_button_drag: Button
var _tool_button_glue: Button
var _tool_button_clean: Button
var _tool_map: Dictionary = {}
var _puzzle: Puzzle = null

func _notification(what: int) -> void:
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		_puzzle_container = %PuzzleContainer as PanelContainer
		_tool_button_drag = %ToolButtonDrag as Button
		_tool_button_glue = %ToolButtonGlue as Button
		_tool_button_clean = %ToolButtonClean as Button
		_tool_map = {
			_tool_button_drag : Puzzle.TOOL_MOVE,
			_tool_button_glue : Puzzle.TOOL_GLUE,
			_tool_button_clean : Puzzle.TOOL_CLEAN
		}
		var tool_button_group: ButtonGroup = _tool_button_drag.button_group
		tool_button_group.pressed.connect(_on_tool_button_group_pressed)

func _ready() -> void:
	# FIXME: for testing reasons we are using a sample puzzle on ready
	# remove this when the workbench is ready for use
	var sample_puzzle: Puzzle = %SamplePuzzle
	_puzzle_container.remove_child(sample_puzzle)
	load_puzzle(sample_puzzle)
#	show()
	Audio.play_game_bgm()

func load_puzzle(new_puzzle: Puzzle) -> void:
	assert(new_puzzle != null and not new_puzzle.is_inside_tree())
	if _puzzle:
		_puzzle.queue_free()
	_puzzle = new_puzzle
	_puzzle_container.add_child(new_puzzle)

func _on_tool_button_group_pressed(p_button: BaseButton):
	if _puzzle != null:
		_puzzle.tool = _tool_map[p_button]
