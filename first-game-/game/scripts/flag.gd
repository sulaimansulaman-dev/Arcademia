# Flag.gd
extends Area2D

signal goal_reached

func _ready():
	# make sure Area2D monitoring is enabled in the editor (default is on)
	pass

func _on_flag_area_body_entered(body):
	if body.name == "Player":
		emit_signal("goal_reached")
