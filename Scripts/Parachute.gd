extends Node2D

var chute_position = Vector2()
# warning-ignore:unused_class_variable
var velocity = Vector2(0,0)

func _ready():
	chute_position = global_position
	