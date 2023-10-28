extends Control


@export var tier_1_skelettons: Array[PackedScene]
@export var gold_sfx: Array[AudioStream]

@onready var skelle_slot_1: InstancePlaceholder = %SkelleSlot1 as InstancePlaceholder
@onready var skelle_slot_2: InstancePlaceholder = %SkelleSlot2 as InstancePlaceholder

var _time_for_next_customer = 15.0

var skelly_1: SkellyBoy = null
var skelly_2: SkellyBoy = null

var gold: int = 0:
	set = _set_gold
var enraged_customers_count: int = 0

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
		var skelly: SkellyBoy
		var slot: int = 0
		if skelly_1 == null:
			skelly_1 = skelle_slot_1.create_instance(false, customer_scene)
			skelly = skelly_1
			slot = 1
		elif skelly_2 == null:
			skelly_2 = skelle_slot_2.create_instance(false, customer_scene)
			skelly = skelly_2
			slot = 2
		else:
			return
		skelly.enraged.connect(_on_skelly_enraged.bind(slot))
		skelly.satisfied.connect(_on_skelly_satisfied.bind(slot))

func _on_skelly_satisfied(slot: int, p_gold: int):
	_clear_slot(slot)
	gold += p_gold

func _on_skelly_enraged(slot: int):
	_clear_slot(slot)
	enraged_customers_count += 1
	if enraged_customers_count == 3:
		_game_over()
	else:
		await get_tree().create_timer(1.0).timeout
		_spawn_customer()

func _clear_slot(slot: int):
	if slot == 1:
		skelly_1 = null
	else:
		skelly_2 = null

func _set_gold(new_gold):
	gold = new_gold
	var gold_label := get_node_or_null("GoldLabel") as Label
	var gold_audio := get_node_or_null("GoldLabel/GoldAudio") as AudioStreamPlayer
	if gold_label:
		gold_label.text = "🪙$%d" % gold
		if gold_audio and gold > 0:
			gold_audio.stream = gold_sfx[randi() % gold_sfx.size()]
			gold_audio.play()

func _game_over():
	get_tree().quit()
