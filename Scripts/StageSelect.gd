extends Node2D

const MOVE_SPEED = 400
const CENTER_OFFSET = 34

signal stage_entered

var points = {}
var moving = false
var dir = 0
var current_level = 1
var current_world = "City"
# warning-ignore:unused_class_variable
var levels = {1:"Roof Gap"}
var game 
var level_progress

func _ready():
	game =  get_tree().root.get_child(0)
	level_progress = game.levels[current_world]["Progress"]
	set_process_input(true)
	set_process(true)
	map_points()
		
func _input(event):
	if !moving:
		if current_level < level_progress:
			if event.is_action_pressed("Move_Right"):
				if current_level != points.size():
					dir =1 
					moving = true
					execute_tween(dir)
					
		if event.is_action_pressed("Move_Left"):
			if current_level != 1:
				moving = true
				dir =-1 
				execute_tween(dir)
					
		if event.is_action_pressed("select"):
			emit_signal("stage_entered", current_world)
		
func map_points():
	var idx = 1
	for stage in get_node(current_world+"/Stages").get_children():
		points[idx] = stage.get_rect().position + Vector2(CENTER_OFFSET,CENTER_OFFSET)
		idx +=1
		
func update_location():
	if current_level != points.size():
		if dir ==1:
			current_level +=1
	if current_level != 1:
		if dir == -1:
			current_level-=1
			
func execute_tween(p_dir):
	$Tween.interpolate_property($Player, 'global_position', points[current_level], points[current_level+ p_dir], 0.7,$Tween.TRANS_LINEAR,$Tween.EASE_IN_OUT)
	$Tween.start()
	
func _on_Tween_tween_completed(__, __):
	moving = false
	update_location()
