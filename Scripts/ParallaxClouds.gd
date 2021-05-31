extends ParallaxBackground

const MOVE_SPEED = 40

func _ready():
	set_process(true)
	
func _process(delta):
	$ParallaxLayer_Sky.motion_offset.x -= MOVE_SPEED*delta
	

