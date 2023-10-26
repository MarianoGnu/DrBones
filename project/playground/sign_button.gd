extends Button

@export var door_sub_scene: Control

@onready var path_follow: PathFollow2D = $"../.."
@onready var selector: PathFollow2D = %Selector
@onready var door_animation_player: AnimationPlayer = %DoorAnimationPlayer
@onready var scene_selector: TabContainer = %SceneSelector

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed():
	if (not selector or selector.is_in_use or not path_follow
		or selector.progress_ratio == path_follow.progress_ratio):
		return
	selector.is_in_use = true
	if not is_equal_approx(selector.progress_ratio, 0.5):
		door_animation_player.play("close")
		await door_animation_player.animation_finished
	var tab_index: int = scene_selector.get_tab_idx_from_control(door_sub_scene)
	scene_selector.current_tab = tab_index
	var tween: Tween = create_tween()
	tween.tween_property(selector, "progress_ratio", path_follow.progress_ratio, 0.6).set_trans(Tween.TRANS_EXPO)
	selector.sfx_move()
	await tween.finished
	door_animation_player.play("open")
	await door_animation_player.animation_finished
	selector.is_in_use = false
