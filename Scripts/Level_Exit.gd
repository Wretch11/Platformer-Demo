extends Node2D

signal level_done

func _on_Area2D_body_entered(__):
	emit_signal("level_done", get_parent().name)
	#get_tree().root.get_child(0)._on_load_map(get_parent().name)
