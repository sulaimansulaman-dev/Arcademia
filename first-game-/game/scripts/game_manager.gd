extends Node


var final_score:int = 0 
@onready var score_label: Label = $ScoreLabel
func set_final_score(score: int) -> void:
	final_score = score
	print("Final Score set to: ", final_score)
