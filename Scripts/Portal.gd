extends Node2D

export var portal_name = ""
var active = false
signal entered

func _ready():
	set_process_input(true)
	
func _input(__):
	if active:
		if Input.is_action_just_pressed("select"):
			emit_signal("entered", portal_name)
			
func _on_Area2D_body_entered(__):
	active = true
	
func _on_Area2D_body_exited(__):
	active = false
