extends PointLight2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("mobile"):
		hide()
		set_process(false)

func _process(_delta: float) -> void:
	if get_viewport().get_parent().is_visible_in_tree():
		global_position = get_viewport().get_mouse_position()
