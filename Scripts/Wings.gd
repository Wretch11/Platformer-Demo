extends Area2D

const ASCENT_SPEED = 15 
# warning-ignore:unused_class_variable
var is_activated = true

var start_pos
var velocity = Vector2(0,0)

func _ready():
	start_pos = global_position
	
func wings_ascend(delta):
	if !$RayCasts/RayCast2D.is_colliding():
		velocity.y = ASCENT_SPEED * delta
		self.global_position.y -= velocity.y
	
	
	


