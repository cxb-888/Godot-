extends Node

func _ready() -> void:
	$Label3.text = "最快历史记录：" + str(Global.score) +"秒"

# Called when the node enters the scene tree for the first time.
func _process(_delts:float) -> void:
	if Input.is_action_just_pressed("confirm"):
		get_tree().change_scene_to_file("res://scenes/Game.tscn")
