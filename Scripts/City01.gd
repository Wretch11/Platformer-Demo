extends Node2D

signal player_below_map_floor

func _on_Area2D_body_exited(__):
	emit_signal("player_below_map_floor")
