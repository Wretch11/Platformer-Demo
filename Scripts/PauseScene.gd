extends Node2D

signal restart

func _ready():
	$RestartButton.grab_focus()

func _on_RestartButton_pressed():
	emit_signal("restart")

func _on_QuitButton_pressed():
	get_tree().quit()
