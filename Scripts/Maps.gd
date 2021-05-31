extends Node2D

signal player_picked_up_wings
signal player_picked_up_dash
signal player_picked_up_parachute
signal player_picked_up_blink
signal player_below_map_floor

func _on_Power_Item_Wings_Collectible_body_entered(__):
	emit_signal("player_picked_up_wings", "Wings")
	free_item_from_queue()

func _on_Power_Item_Collectible_body_entered(__):
	emit_signal("player_picked_up_dash","PowerDash")
	free_item_from_queue()
	
func _on_Power_Item_Parachute_body_entered(__):
	emit_signal("player_picked_up_parachute", "Parachute")
	free_item_from_queue()

func _on_Power_Item_Blink_body_entered(__):
	emit_signal("player_picked_up_blink", "Blink")
	free_item_from_queue()
	
func free_item_from_queue():
	for power_up in $PowerUps.get_children():
		if power_up.get_overlapping_bodies().size() != 0:
			power_up.queue_free()
			break

func _on_Floor_body_exited(__):
	emit_signal("player_below_map_floor")


