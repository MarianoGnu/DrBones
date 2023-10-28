@tool
extends Node2D

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
		spuder = %Spuder
		speech_text_label = %SpeechTextLabel
		speech_animation_player = %SpeechAnimationPlayer
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
	var spuder_chance = randf()
	if spuder_chance < 0.1:
		await get_tree().create_timer(randf_range(2.0, 4.0)).timeout
		spuder.create_instance(true)

func say(p_text: String):
	speech_text_label.text = p_text
	speech_animation_player.play(&"speak")

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
