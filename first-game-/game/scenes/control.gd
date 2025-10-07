extends Control

@onready var avatar = $Avatar

func _ready():
	load_avatar("res://game/space assets/Alex.png")  # path where you expect the file

func load_avatar(path: String):
	var img = load(path)
	if img:
		avatar.texture = img
	else:
		push_warning("Avatar not found at: %s" % path)
