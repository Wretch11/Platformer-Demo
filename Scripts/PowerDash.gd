extends Node2D

const DASH_SPEED = 20

# warning-ignore:unused_class_variable
var is_activated = true
var start_pos
var velocity = Vector2(0,0)
var is_dash_time_depleted = false

func _ready():
	start_pos = global_position
	
# warning-ignore:unused_argument
func _physics_process(delta):
	if $Raycasts/RayCast2D.is_colliding():
		$DashTimer.stop()
		$DashTimer.wait_time = 0.5
		is_dash_time_depleted = true
	
func execute_dash(delta):
	if !is_dash_time_depleted:
		velocity.x += DASH_SPEED*delta
		self.global_position.x += velocity.x 

func _on_DashTimer_timeout():
	is_dash_time_depleted = true
