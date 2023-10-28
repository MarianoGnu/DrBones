extends Button

signal production_requested(out_produce: PackedScene, p_time: float, icon_texture: Texture2D)

@export var produces: PackedScene
@export var time: float = 15.0

func _ready() -> void:
	var minutes = floor(time / 60)
	var seconds = time - (minutes * 60)
	$Label.text = "⌛%2d:%2d" % [minutes, seconds]
	pressed.connect(_on_pressed)

func _on_pressed():
	production_requested.emit(produces, time, icon)
