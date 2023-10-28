@tool
class_name SkellyBoy extends CanvasGroup

signal satisfied(gold: int)
signal enraged()

@export var dialog_key: StringName:
	set(v):
		if v.is_empty():
			# Don't know what is going on...
			return
		dialog_key = v
@export var highlight_text_color: Color = Color.DARK_ORANGE
@export var wants: PackedScene


@export_group("Accesories", "visible_")
@export var visible_tie: bool = false:
	set = _set_visible_tie
@export var visible_ribon: bool = false:
	set = _set_visible_ribon
@export var visible_mask: bool = false:
	set = _set_visible_mask
@export var visible_wig: bool = false:
	set = _set_visible_wig
@export var visible_hat: bool = false:
	set = _set_visible_hat
@export var visible_trumpet: bool = false:
	set = _set_visible_trumpet
@export var visible_wolf_head: bool = false:
	set = _set_visible_wolf_head

var corbata: Sprite2D
var mo_ito: Sprite2D
var antifaz: Sprite2D
var peluca: Sprite2D
var piluso: Sprite2D
var trompeta: Sprite2D
var cabeza_merged: Sprite2D
var mandibula: Sprite2D
var mandibula_lobo: Sprite2D
var cabeza_lobo: Sprite2D
var spuder: InstancePlaceholder

var speech_text_label: RichTextLabel
var speech_animation_player: AnimationPlayer

var drop_zone: Control
var success_animation_player: AnimationPlayer

var fail_count = 0

func _notification(what: int) -> void:
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		corbata = %Corbata
		mo_ito = %"Moñito"
		antifaz = %Antifaz
		peluca = %Peluca
		piluso = %Piluso
		trompeta = %Trompeta
		cabeza_merged = %CabezaMerged
		mandibula = %Mandibula
		cabeza_lobo = %CabezaLobo
		mandibula_lobo = %MandibulaLobo
		if not Engine.is_editor_hint():
			spuder = %Spuder
		speech_text_label = %SpeechTextLabel
		speech_animation_player = %SpeechAnimationPlayer
		drop_zone = $DropZone
		success_animation_player = $SuccessAnimationPlayer
		corbata.visible = visible_tie
		mo_ito.visible = visible_ribon
		antifaz.visible = visible_mask
		peluca.visible = visible_wig
		piluso.visible = visible_hat
		trompeta.visible = visible_trumpet
		_set_visible_wolf_head(visible_wolf_head)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	drop_zone.set_drag_forwarding(
		_get_drag_data,
		_can_drop_data,
		_drop_data
	)
	modulate.a = 0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	await tween.finished
	say(tr(dialog_key))
	var spuder_chance = randf()
	if spuder_chance < 0.1:
		await get_tree().create_timer(randf_range(2.0, 4.0)).timeout
		spuder.create_instance(true)

func say(p_text: String):
	var bbcode = p_text.replace("#", "[/color]")
	bbcode = bbcode.replace("%", "[color=%s]" % highlight_text_color.to_html(false))
	speech_text_label.text = bbcode
	speech_animation_player.play(&"speak")

func _get_drag_data(_at_position: Vector2) -> Variant:
	return null

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return &"puzzle" in data and data.puzzle is Puzzle

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var puzzle: Puzzle = data.puzzle as Puzzle
	if not puzzle.scene_file_path == wants.resource_path or not puzzle.is_complete():
		fail_count += 1
		$Fail.play()
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:r",  1 + fail_count * 0.5, 1).set_trans(Tween.TRANS_ELASTIC)
		await tween.finished
		if fail_count == 3:
			$Die.play()
			enraged.emit()
			drop_zone.queue_free()
			tween.kill()
			tween = create_tween()
			tween.tween_property(self, "modulate:a", 0.0, 1.0)
			await tween.finished
			queue_free()
		return
	else:
		if &"success_callback" in data:
			data.success_callback.call()
		$Nyehehe.play()
		if puzzle.get_parent() != null:
			puzzle.get_parent().remove_child(puzzle)
		if success_animation_player.has_animation(&"success"):
			success_animation_player.play(&"success")
			await success_animation_player.animation_finished
		satisfied.emit()
		


func _set_visible_tie(p_visible: bool):
	visible_tie = p_visible
	corbata.visible = p_visible

func _set_visible_ribon(p_visible: bool):
	visible_ribon = p_visible
	mo_ito.visible = p_visible

func _set_visible_mask(p_visible: bool):
	visible_mask = p_visible
	antifaz.visible = p_visible

func _set_visible_wig(p_visible: bool):
	visible_wig = p_visible
	peluca.visible = p_visible

func _set_visible_hat(p_visible: bool):
	visible_hat = p_visible
	piluso.visible = p_visible

func _set_visible_trumpet(p_visible: bool):
	visible_trumpet = p_visible
	trompeta.visible = p_visible

func _set_visible_wolf_head(p_visible: bool):
	visible_wolf_head = p_visible
	mandibula_lobo.visible = p_visible
	cabeza_lobo.visible = p_visible
	mandibula.visible = not p_visible
	cabeza_merged.visible = not p_visible
