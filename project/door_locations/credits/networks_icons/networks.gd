@tool
extends RichTextLabel

@export var networks: Array[HyperlinkData] = []
@export_group("Editor", "editor_")
@export var editor_update: bool = false:
	set(_v):
		update()

func _ready() -> void:
	meta_clicked.connect(_on_meta_clicked)


func update() -> void:
	clear()
	for i in range(networks.size()):
		var n: HyperlinkData = networks[i]
		if i != 0:
			add_text("\n")
		add_image(n.icon, 32, 32)
		add_text(" ")
		push_meta(n.hyperlink)
		add_text(n.description)
		pop()

func _on_meta_clicked(url):
	OS.shell_open(url)
