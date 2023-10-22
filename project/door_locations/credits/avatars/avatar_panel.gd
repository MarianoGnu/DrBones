@tool
class_name AvatarPanel extends PanelContainer

signal selected(p_self)

@export var avatar_texture: Texture2D:
	set = _set_avatar_texture
@export var discord_name: String:
	set = _set_discord_name
@export var discord_color: Color:
	set = _set_discord_color
@export var networks: Array[HyperlinkData]
@export var roles: Array[Role]

@onready var _texture_rect: TextureRect = %TextureRect
@onready var _label: Label = %Label
@onready var _button: Button = %Button

func _ready() -> void:
	_update_controls()
	_button.toggled.connect(_on_button_toggled)

func _on_button_toggled(button_pressed: bool):
	_texture_rect.material.set_shader_parameter(&"selected", button_pressed)
	if button_pressed:
		selected.emit(self)

func _set_avatar_texture(p_avatar_texture: Texture2D) -> void:
	avatar_texture = p_avatar_texture
	_update_controls()

func _set_discord_name(p_discord_name: String) -> void:
	discord_name = p_discord_name
	_update_controls()

func _set_discord_color(p_discord_color: Color) -> void:
	discord_color = p_discord_color
	_update_controls()

func _update_controls():
	if not _label:
		return
	_texture_rect.texture = avatar_texture
	_label.text = String()
	for role in roles:
		if role != null:
			_label.text += role.emoji
	_label.text += discord_name
	_label.add_theme_color_override("font_color", discord_color)
