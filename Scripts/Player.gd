
extends KinematicBody2D

signal selected_power_changed
signal update_power_up_lbl

const UP = Vector2(0,-1)
const SLOPE_STOP = 64
const WALL_JUMP_VELOCITY = Vector2(800,-1000)
const FLOAT_GRAVITY = 100
var velocity = Vector2()
var move_speed = 500
var gravity  
var max_jump_velocity 
var max_double_jump_velocity
var min_jump_velocity
var max_jump_height = 200
var max_double_jump_height = 150
var min_jump_height = 10
var jump_duration = 0.3
var is_grounded 
var is_jumping = false
# warning-ignore:unused_class_variable
var is_floating = false
var wall_direction = 0
var move_direction = 1
var has_jumped_twice = false
# warning-ignore:unused_class_variable
var collected_power_ups = {}
# warning-ignore:unused_class_variable
var current_power_up
var current_power_up_key = -1
var start_position = Vector2()

var dash = preload("res://Scenes/PowerDash.tscn")
var wings = preload("res://Scenes/Wings.tscn")
# warning-ignore:unused_class_variable
var chute = preload("res://Scenes/Parachute.tscn")
# warning-ignore:unused_class_variable
var blink = preload("res://Scenes/Blink.tscn")
var powers_list = {"PowerDash" : dash , "Wings" : wings, "Parachute" : chute, "Blink" : blink}

onready var raycasts = $RayCasts
onready var left_wall_rc = $WallRayCasts/Left_Wall_RayCasts
onready var right_wall_rc = $WallRayCasts/Right_Wall_RayCasts
# warning-ignore:unused_class_variable
onready var body = $Body
# warning-ignore:unused_class_variable
onready var wall_slide_cooldown = $WallSlideCooldown
onready var wall_slide_sticky_timer = $WallSlideStickyTimer
# warning-ignore:unused_class_variable
onready var wall_slide_particles = $Body/Slide_Particle
# warning-ignore:unused_class_variable
onready var anim_player = $AnimationPlayer

func _ready():
	start_position = global_position
	gravity = max_jump_height /pow(jump_duration,2)
	max_jump_velocity = sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = sqrt(2 * gravity * min_jump_height)
	max_double_jump_velocity = sqrt(2 * gravity * max_double_jump_height)
	
func _apply_gravity(delta):
	velocity.y += gravity * delta

func _cap_float_gravity(__):
	var max_velocity = 150 if !Input.is_action_pressed("Down") else 200
	velocity.y = min(velocity.y,max_velocity)
	
func _cap_gravity_wallslide():
	var max_velocity = 80 if !Input.is_action_pressed("Down") else 500
	velocity.y = min(velocity.y,max_velocity)
	
func _handle_wall_slide_sticky():
	if move_direction != 0 and move_direction != wall_direction:
		if wall_slide_sticky_timer.is_stopped():
			wall_slide_sticky_timer.start()
		else:
			wall_slide_sticky_timer.stop()
			
func jump():
	var grounded = _check_is_grounded()
	if grounded:
		velocity.y = -max_jump_velocity
		is_jumping = true

func double_jump():
	velocity.y = -max_double_jump_velocity
	is_jumping = true
	has_jumped_twice = true

func wall_jump():
	var wall_jump_velocity = WALL_JUMP_VELOCITY
	wall_jump_velocity.x *= -wall_direction
	velocity = wall_jump_velocity
	
func _apply_movement():
	if is_jumping and velocity.y >= 0:
		is_jumping = false
	
	velocity = move_and_slide(velocity, UP)
	is_grounded = !is_jumping and _check_is_grounded()
	
func _update_move_direction():
	move_direction = -int(Input.is_action_pressed("Move_Left")) + int(Input.is_action_pressed("Move_Right"))

func _handle_move_input():
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
	
	if move_direction != 0:
		$Body.scale.x = move_direction
		
func _get_h_weight():
	if _check_is_grounded():
		return 0.2
	else:
		if move_direction == 0:
			return 0.02
		elif move_direction == sign(velocity.x) and abs(velocity.x) > move_speed:
			return 0.0
		else:
			return 0.1
		
func _check_is_grounded():
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
	return false
	
func _update_wall_direction():
	var is_near_wall_left = _check_is_valid_wall(left_wall_rc)
	var is_near_wall_right = _check_is_valid_wall(right_wall_rc)
	
	if is_near_wall_left && is_near_wall_right:
		wall_direction = move_direction
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)
	
func _check_is_valid_wall(wall_ray_casts):
	for raycast in wall_ray_casts.get_children():
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if !("Barrier" in collider.name):
				return true
	return false
	
func player_apply_power_up_movement():
	self.global_position = current_power_up.global_position
	
func add_power_up(power_up):
	if collected_power_ups.size() == 0:
		current_power_up_key = 0
		emit_signal("selected_power_changed", current_power_up_key, collected_power_ups)
		
	collected_power_ups[collected_power_ups.size()] = power_up
	emit_signal("update_power_up_lbl")
	
	
func change_selected_power(flag):
	var idx = -1
	
	if flag == "next":
		idx = -1
	elif flag == "prev":
		idx = 1
	else:
		idx = -1
	
	if current_power_up_key == 0 and flag == "prev":
		current_power_up_key = collected_power_ups.size()-1
	elif current_power_up_key == collected_power_ups.size()-1 and flag == "next":
		current_power_up_key = 0
	else:
		current_power_up_key-= idx
	
	emit_signal("selected_power_changed", current_power_up_key, collected_power_ups)
	
func instance_power_up():
	var power_up_scene_name = get_selected_power_up_scene()
	var new_scene = powers_list[power_up_scene_name].instance()
	$Body.add_child(new_scene)
	new_scene.global_position = self.global_position
	new_scene.show_behind_parent = true
	current_power_up = new_scene
	return new_scene
	
func get_selected_power_up_scene():
	for scene in collected_power_ups.keys():
		if scene == current_power_up_key:
			return collected_power_ups.values()[current_power_up_key]
			
func _on_power_up_done():
	collected_power_ups.erase(current_power_up_key)
	
	for power_up_key in collected_power_ups.keys():
		if power_up_key > 0:
			var temp = collected_power_ups[power_up_key]
			collected_power_ups.erase(power_up_key)
			power_up_key -= 1
			collected_power_ups[power_up_key] = temp
	
	current_power_up_key = collected_power_ups.size() -1
	current_power_up.queue_free()
	emit_signal("update_power_up_lbl")
	emit_signal("selected_power_changed", current_power_up_key, collected_power_ups)
	
if Input.is_action_pressed("Fire"):
	is_firing = true
if Input.is_action_just_released("Fire"):
	is_firing = false