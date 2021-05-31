extends Node2D

# warning-ignore:unused_class_variable
var city = preload("res://Scenes/StageSelect.tscn")

signal load_map

func _ready():
# warning-ignore:return_value_discarded
	$Portal.connect("entered", self, "_on_portal_entered")

func _on_portal_entered(p_name):
	emit_signal("load_map", p_name)
