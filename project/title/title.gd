extends Control

@onready var button: Button = $Button
@onready var start_animation: AnimationPlayer = $StartAnimation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	button.disabled = true
	start_animation.play("start_game")
	await start_animation.animation_finished
	Audio.play_game_bgm()
	get_tree().change_scene_to_file("res://playground/game.tscn")
