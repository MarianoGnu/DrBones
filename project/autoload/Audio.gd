extends Node

@export var menu_music: AudioStream
@export var game_music: AudioStream

@onready var bgm: AudioStreamPlayer = $Bgm


func _ready() -> void:
	if menu_music != null:
		bgm.stream = menu_music
		bgm.play()


func play_menu_bgm():
	bgm.stream = menu_music
	if menu_music != null:
		bgm.play()


func play_game_bgm():
	bgm.stream = game_music
	if game_music != null:
		bgm.play()

