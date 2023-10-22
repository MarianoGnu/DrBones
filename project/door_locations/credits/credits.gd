extends CanvasLayer

@export var participants: Array[AvatarPanel] = []

@onready var _networks: RichTextLabel = %networks
@onready var _roles: RichTextLabel = %roles

func _ready() -> void:
	for member in participants:
		member.selected.connect(_on_member_selected)

func _on_member_selected(which: AvatarPanel):
	_networks.networks = which.networks
	_networks.update()
	_roles.clear()
	for i in which.roles.size():
		var role: Role = which.roles[i]
		if i > 0:
			_roles.add_text("\n")
		_roles.add_text(role.emoji)
		_roles.push_color(role.role_color)
		_roles.add_text(role.description)
		_roles.pop()
