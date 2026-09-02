extends CharacterBody2D

func resdy():
	$AnimationPlayer.play("default")
	
func open():
	$AnimationPlayer.play("open")
	
func close():
	$AnimationPlayer.play("close")
	
