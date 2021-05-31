extends "res://Scripts/StateMachine.gd"

onready var parent = get_parent()

func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("wall_slide")
	add_state("flying")
	add_state("dashing")
	add_state("floating")
	add_state("phase_blinking")
	
	call_deferred("set_state", states.idle)
	
func _input(event):
	if event.is_action_pressed("Next_Power"):
		parent.change_selected_power("next")
	
	if event.is_action_pressed("Prev_Power"):
		parent.change_selected_power("prev")
	
	if event.is_action_pressed("Jump"):
		if [states.idle, states.run].has(state):
			parent.jump()
			
		elif state == states.wall_slide:
			if event.is_action_pressed("Jump"):
				parent.wall_jump()
				set_state(states.jump)
			
		elif state == states.fall:
			if event.is_action_pressed("Jump"):
				if !parent.has_jumped_twice:
					parent.double_jump()
					set_state(states.jump)
					
		elif state == states.floating:
			parent._on_power_up_done()
			set_state(states.jump)
			parent.double_jump()
					
	if event.is_action_pressed("Down"):
		if state == states.flying:
			parent._on_power_up_done()
			set_state(states.fall)
			
	if [states.idle, states.run, states.jump, states.fall].has(state):
		if !parent.collected_power_ups.empty():
			if event.is_action_pressed("Use_Power_Up"):
				var new_power = parent.instance_power_up()
				use_selected_power_up(new_power)
			
				
	if state == states.jump:
		if event.is_action_released("Jump") and parent.velocity.y < parent.min_jump_height:
			parent.velocity.y = parent.min_jump_velocity
			
			
func _state_logic(delta):
	parent._update_wall_direction()
	
	if state != states.wall_slide:
		parent._handle_move_input()
		
	if ![states.flying, states.dashing, states.phase_blinking].has(state): 
		parent._update_move_direction()
		parent._apply_gravity(delta)
	else:
		if state == states.flying:
			parent.current_power_up.wings_ascend(delta)
		elif state == states.dashing:
			parent.current_power_up.execute_dash(delta)
		elif state == states.phase_blinking:
			pass

		parent.player_apply_power_up_movement()
		
	if state == states.wall_slide:
		parent._cap_gravity_wallslide()
		parent._handle_wall_slide_sticky()
		
	if state == states.floating:
		parent._cap_float_gravity(delta)
		
	parent._apply_movement()
	
func _get_transition(__):
	match state:
		states.idle:
			if !parent._check_is_grounded():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif int(abs(parent.velocity.x)) != 0:
				return states.run
		states.run:
			if !parent._check_is_grounded():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif int(abs(parent.velocity.x)) == 0:
				return states.idle
		states.jump:
			if parent.wall_direction != 0 and parent.wall_slide_cooldown.is_stopped():
				return states.wall_slide
			elif parent._check_is_grounded():
				return states.idle
			elif parent.velocity.y >=0:
				return states.fall
		states.fall:
			if parent.wall_direction != 0 and parent.wall_slide_cooldown.is_stopped():
				return states.wall_slide
			elif parent._check_is_grounded():
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
		states.wall_slide:
			if parent._check_is_grounded():
				return states.idle
			elif parent.wall_direction == 0:
				return states.fall
			
		states.dashing:
			if !parent._check_is_grounded():
				if parent.wall_direction != 0 and parent.wall_slide_cooldown.is_stopped():
					return states.wall_slide
				elif parent.current_power_up.is_dash_time_depleted:
					return states.fall
			else:
				if parent.current_power_up.is_dash_time_depleted:
					return states.idle
		states.phase_blinking:
			if !parent._check_is_grounded():
				if parent.wall_direction != 0 and parent.wall_slide_cooldown.is_stopped():
					return states.wall_slide
				elif parent.current_power_up.has_blinked:
					return states.fall
			else:
				if parent.current_power_up.has_blinked:
					return states.idle
		states.floating :
			if parent._check_is_grounded():
				return states.idle
			else:
				if parent.wall_direction != 0 and parent.wall_slide_cooldown.is_stopped():
					return states.wall_slide
				
	parent.get_node("Label").text =  states.keys()[state]
	
# warning-ignore:unused_argument
func _enter_state(old_state, new_state):
	match new_state:
		states.idle:
			parent.anim_player.play("Idle")
			if parent.has_jumped_twice:
				parent.has_jumped_twice = false
		states.run:
			parent.anim_player.play("Run")
			if parent.has_jumped_twice:
				parent.has_jumped_twice = false
		states.jump:
			parent.anim_player.play("Jump")
		states.wall_slide:
			parent.anim_player.play("Slide")
			parent.wall_slide_particles.visible = true
			parent.wall_slide_particles.emitting = true
			parent.body.scale.x = -parent.wall_direction
			if parent.has_jumped_twice:
				parent.has_jumped_twice = false
		states.fall:
			pass
		states.flying:
			pass
		states.dashing:
			parent.anim_player.play("Dash")
		states.floating:
			parent.is_floating = true
			parent.anim_player.play("Float")
		states.phase_blinking:
			pass
	
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _exit_state(old_state,new_state):
	match old_state:
		states.run:
			parent.anim_player.play("Jump")
		states.wall_slide:
			parent.wall_slide_cooldown.start()
			parent.wall_slide_particles.emitting = false
			parent.wall_slide_particles.visible = false
			if state == states.fall:
				parent.anim_player.play("Jump")
		states.flying:
			parent.has_jumped_twice = false
			parent.current_power_up = null
		states.dashing:
			parent.anim_player.play("Jump")
			parent._on_power_up_done()
			parent.velocity.x += parent.current_power_up.velocity.x
		states.floating:
			parent.is_floating = false
			parent._on_power_up_done()
		states.phase_blinking:
			parent._on_power_up_done()
			
			
func _on_WallSlideStickyTimer_timeout():
	if state == states.wall_slide:
		set_state(states.fall)
		
func _on_player_power_up_pick_up(power_up):
	var ui_selected_pwerup_label = get_tree().root.get_node("Game/UI_Layer/Selected_Label")

	parent.add_power_up(power_up)
	
	if "None" in ui_selected_pwerup_label.text:
		ui_selected_pwerup_label.text = "Selected power is: " + power_up
	
func use_selected_power_up(selected_power):
	
	var current_power_name = selected_power.name
	
	parent.move_direction = 0
	parent.current_power_up = selected_power
	parent.global_position = parent.current_power_up.global_position
	parent.velocity = parent.current_power_up.velocity

	if "Wings" in current_power_name:
		set_state(states.flying)
	elif "PowerDash" in current_power_name:
		set_state(states.dashing)
		parent.body.scale.x = parent.current_power_up.scale.x
		parent.current_power_up.get_node("DashTimer").start()
	elif "Parachute" in current_power_name:
		set_state(states.floating)
	elif "Blink" in current_power_name:
		set_state(states.phase_blinking)
	
	

		