extends Node2D


onready var ui_layer_lbl_selected = $UI_Layer/Selected_Label
onready var ui_layer_lbl_available = $UI_Layer/Available_Label

# warning-ignore:unused_class_variable
var world_select_scn = load("res://Scenes/WorldSelect.tscn")
var start_menu_scn = load("res://Scenes/StartMenu.tscn")
var stage_select_scn = load("res://Scenes/StageSelect.tscn")
var levels = {"City": {1 : load("res://Scenes/City01.tscn"), "Progress" :1 }}

# warning-ignore:unused_class_variable
var screen_w = ProjectSettings.get_setting("display/window/size/width")
# warning-ignore:unused_class_variable
var screen_h = ProjectSettings.get_setting("display/window/size/height")
var is_paused = false
var is_game_over = false
var current_world
var current_level 
var current_level_key

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
# warning-ignore:return_value_discarded
	$Level/WretchedGamesSplash.connect("splash_done", self, "_on_splash_done")
	# warning-ignore:return_value_discarded
	$PauseLayer/PauseScene.connect("restart", self, "_on_game_restart")
	#init_ui_labels()
	#connect_signals()
	
# warning-ignore:unused_argument
func _input(event):
	if Input.is_action_just_pressed("Pause"):
		if !is_game_over:
			pause_game()
			
func _on_game_over():
	is_game_over = true
	pause_game()
	$PauseLayer/PauseScene/Label.text = "Game Over"
	
func _on_selected_power_changed(key, collected_power_ups):
	if !collected_power_ups.empty():
		ui_layer_lbl_selected.text = "Selected power is: " + collected_power_ups.values()[key]
	else:
		ui_layer_lbl_selected.text = "Selected power is: None"
	
func _on_update_power_up_lbl():
	var temp_player_scn = $Level.get_node(current_level+"/Player")
	if !temp_player_scn.collected_power_ups.empty():
		$UI_Layer/Available_Label.text = "Available power ups:"
		for power in temp_player_scn.collected_power_ups.values():
			$UI_Layer/Available_Label.text += " " + power + " "
	else:
		$UI_Layer/Available_Label.text = "Available power ups: None"

func init_ui_labels():
	ui_layer_lbl_selected.text = "Selected power is: None" 
	ui_layer_lbl_available.text = "Available power ups: None"
	
func connect_signals(p_stage_name):
	var temp_player_scn = $Level.get_node(p_stage_name+"/Player")
# warning-ignore:return_value_discarded
	temp_player_scn.connect("selected_power_changed", self, "_on_selected_power_changed")
# warning-ignore:return_value_discarded
	$Level.get_node(p_stage_name+"/Player").connect("update_power_up_lbl", self, "_on_update_power_up_lbl")
# warning-ignore:return_value_discarded
	$Level.get_node(p_stage_name).connect("player_picked_up_wings", temp_player_scn.get_node("FSM"), "_on_player_power_up_pick_up")
# warning-ignore:return_value_discarded
	$Level.get_node(p_stage_name).connect("player_picked_up_dash", temp_player_scn.get_node("FSM"), "_on_player_power_up_pick_up")
# warning-ignore:return_value_discarded
	$Level.get_node(p_stage_name).connect("player_picked_up_parachute", temp_player_scn.get_node("FSM"), "_on_player_power_up_pick_up")
# warning-ignore:return_value_discarded
	$Level.get_node(p_stage_name).connect("player_picked_up_blink", temp_player_scn.get_node("FSM"), "_on_player_power_up_pick_up")
# warning-ignore:return_value_discarded
	$Level.get_node(p_stage_name).connect("player_below_map_floor", self, "_on_game_over")
	
func _on_game_restart():
# warning-ignore:return_value_discarded
	_on_stage_entered(current_world)
	is_game_over = false
	pause_game()
	var temp_player_fsm = $Level.get_node(current_level+"/Player/FSM")
	temp_player_fsm.set_state(temp_player_fsm.states.idle)
	
func pause_game():
	if !is_paused:
		is_paused = true
		$PauseLayer/PauseScene/Label.text = "Paused"
		$PauseLayer/PauseScene.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		return
	is_paused = false
	$PauseLayer/PauseScene.visible = false
	get_tree().paused = false
	
func _on_splash_done():
	var current_scn = $Level/WretchedGamesSplash
	var new_scn = start_menu_scn
	
	$Level.remove_child(current_scn)
	current_scn.queue_free()
	
	new_scn = new_scn.instance()
	$Level.add_child(new_scn)
	new_scn.connect("start_game", self, "_on_start_game")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_start_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var current_scn = $Level.get_child(0)
	var new_scn = world_select_scn
	
	$Level.remove_child(current_scn)
	current_scn.queue_free()
	
	new_scn = new_scn.instance()
	$Level.add_child(new_scn)
	new_scn.connect("load_map", self, "_on_load_map")
	
# warning-ignore:unused_argument
func _on_load_map(p_name):
	var current_scn = $Level.get_child(0)
	var new_scn = stage_select_scn
	
	call_deferred("$Level.remove_child", current_scn)
	current_scn.queue_free()
	
	new_scn = new_scn.instance()
	$Level.add_child(new_scn)
	new_scn.connect("stage_entered", self, "_on_stage_entered")
	current_world = new_scn.current_world
	
func _on_stage_entered(p_world):
	if current_level_key == null:
		current_level_key = get_stage_key()
	var current_scn = $Level.get_child(0)
	var new_scn = levels[p_world][current_level_key]
	
	$Level.remove_child(current_scn)
	current_scn.queue_free()
	
	new_scn = new_scn.instance()
	$Level.add_child(new_scn)
	new_scn.get_node("LevelExit").connect("level_done", self, "_on_level_done")
	current_level = new_scn.name
	connect_signals(current_level)
	
func _on_level_done(p_name):
	levels["City"]["Progress"] +=1
	current_level_key = null
	_on_load_map(p_name)
	
func get_stage_key():
	for key in $Level/StageSelect.points.keys():
		var stage_coords = $Level/StageSelect.points[key]
		if $Level/StageSelect/Player.global_position == stage_coords:
			return key
