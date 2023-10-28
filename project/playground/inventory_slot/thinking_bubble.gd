@tool
extends TextureRect

@onready var thinking_bubble_tail_2: TextureRect = $ThinkingBubbleTail2
@onready var thinking_bubble_tail_1: TextureRect = $ThinkingBubbleTail1

var distance_1: float
var distance_2: float

func _ready() -> void:
	var center: Vector2 = get_global_rect().get_center()
	distance_1 = (thinking_bubble_tail_1.get_global_rect().get_center() - center).length()
	distance_2 = (thinking_bubble_tail_2.get_global_rect().get_center() - center).length()

func _process(delta: float) -> void:
	var center: Vector2 = get_global_rect().get_center()
	var parent_control = get_parent_control()
	if parent_control == null:
		return
	var parent_center: Vector2 = get_parent_control().get_global_rect().get_center()
	var dir = (parent_center - center).normalized()
	thinking_bubble_tail_1.global_position = center + dir * distance_1
	thinking_bubble_tail_2.global_position = center + dir * distance_2
	
