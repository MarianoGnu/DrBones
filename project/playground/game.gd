extends Control


@export var tier_1_skelettons: Array[PackedScene]

@onready var skelle_slot_1: InstancePlaceholder = %SkelleSlot1 as InstancePlaceholder
@onready var skelle_slot_2: InstancePlaceholder = %SkelleSlot2 as InstancePlaceholder

var _time_for_next_customer = 15.0

var skelly_1: SkellyBoy = null
var skelly_2: SkellyBoy = null

func _ready() -> void:
	var intro_animation_player: AnimationPlayer = %IntroAnimationPlayer as AnimationPlayer
	intro_animation_player.play(&"intro")
	intro_animation_player.seek(0, true)
	await intro_animation_player.animation_finished
	tier_1_skelettons.shuffle()
	_spawn_customer()

func _spawn_customer():
	if not tier_1_skelettons.is_empty():
		var customer_scene: PackedScene = tier_1_skelettons.pop_back()
		if skelly_1 == null:
			skelly_1 = skelle_slot_1.create_instance(false, customer_scene)
		elif skelly_2 == null:
			skelly_2 = skelle_slot_2.create_instance(false, customer_scene)
		else:
			_game_over()

func _game_over():
	get_tree().quit()
