extends Node


# Called when the node enters the scene tree for the first time.
func _process(_delts:float) -> void:
	if Input.is_action_just_pressed("confirm"):
		get_tree().change_scene_to_file("res://scenes/Game.tscn")
