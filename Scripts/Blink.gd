extends Node2D

const BLINK_DIST = 500

# warning-ignore:unused_class_variable
var is_activated = true
var start_pos
var velocity = Vector2(0,0)
var has_blinked = false

func _ready():
	start_pos = global_position
	
func _on_AnimationPlayer_animation_finished(__):
	velocity.x = BLINK_DIST
	self.global_position.x += velocity.x
	has_blinked = true
