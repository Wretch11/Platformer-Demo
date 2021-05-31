extends Node2D

signal game_over



func _ready():
	var scene_root = get_tree().root.get_node("Game")
# warning-ignore:return_value_discarded
	connect("game_over",scene_root,"_on_game_over")

func _on_Area2D_body_entered(__):
	emit_signal("game_over")
