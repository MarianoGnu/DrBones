extends PathFollow2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var is_in_use: bool = false

func sfx_move():
	audio_stream_player.play()
