extends Node2D

signal splash_done


func _on_Timer_timeout():
	$LabelAnim.play("FadeIn")


# warning-ignore:unused_argument
func _on_LabelAnim_animation_started(anim_name):
	$Sigh.play()


func _on_Sigh_finished():
	$SceneAnim.play("FadeOut")


# warning-ignore:unused_argument
func _on_SceneAnim_animation_finished(anim_name):
	emit_signal("splash_done")
