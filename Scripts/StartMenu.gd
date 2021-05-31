extends Node2D

signal start_game

func _on_StartButton_pressed():
	emit_signal("start_game")

func _on_QuitButton_pressed():
	get_tree().quit()
