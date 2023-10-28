extends TextureRect

@onready var options: Array[TextureRect] = [
	$ThinkingBubble, $ThinkingBubble2, $ThinkingBubble3, $ThinkingBubble4
]
@onready var tomb_toggle_button: Button = $TombToggleButton
@onready var production_bubble: TextureRect = $ProductionBubble
@onready var icon: TextureRect = $ProductionBubble/Icon
@onready var texture_progress_bar: TextureProgressBar = $ProductionBubble/TextureProgressBar
@onready var inventory_slot: InventorySlot = $InventorySlot as InventorySlot

var tweens: Array[Tween]

func _ready() -> void:
	inventory_slot.hide()
	inventory_slot.item_taken.connect(_on_inventory_slot_item_taken)
	production_bubble.hide()
	for opt in options:
		opt.scale = Vector2.ZERO
		var tomb_button = opt.get_node("TombButton")
		tomb_button.production_requested.connect(_on_production_requested)
	tomb_toggle_button.button_pressed = false
	tomb_toggle_button.toggled.connect(_on_tomb_toggle_button_toggled)

func _on_inventory_slot_item_taken():
	inventory_slot.hide()
	tomb_toggle_button.button_pressed = true

func _on_tomb_toggle_button_toggled(button_pressed: bool):
	for tween in tweens:
		tween.kill()
	var target_scale := Vector2.ONE * 0.5 if button_pressed else Vector2.ZERO
	var delay: float = 0.0
	for opt in options:
		var tween = create_tween()
		tween.tween_property(opt, "scale",  target_scale, .3) \
		.set_delay(delay).set_trans(Tween.TRANS_ELASTIC)
		delay += 0.1
		tweens.append(tween)

func _on_production_requested(produce: PackedScene, time: float, icon_texture: Texture2D) -> void:
	tomb_toggle_button.button_pressed = false
	tomb_toggle_button.disabled = true
	await get_tree().create_timer(1.0)
	production_bubble.show()
	texture_progress_bar.value = 0
	texture_progress_bar.max_value = time
	icon.texture = icon_texture
	var tw: Tween = create_tween()
	tw.tween_property(texture_progress_bar, "value", time, time)
	await tw.finished
	production_bubble.hide()
	var item: Puzzle = produce.instantiate()
	inventory_slot.drop_item(item)
	inventory_slot.show()
