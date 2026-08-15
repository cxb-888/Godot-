extends Node2D

var car_scene: PackedScene = preload("res://scenes/car.tscn")
var score:int

func _on_area_2d_body_entered(_body: Node2D) -> void:
	call_deferred("change_scene")
	if score < Global.score:
		Global.score = score
	
func change_scene():
	get_tree().change_scene_to_file("res://scenes/control.tscn")

func _on_car_control_timeout() -> void:
	var car = car_scene.instantiate() as Area2D
	var pos_marker = $CarStsrtPosition.get_children().pick_random() as Marker2D
	car.position = pos_marker.position
	$objects.add_child(car)
	car.connect("body_entered",go_to_title)
	
func go_to_title(_body):
	call_deferred("change_scene")


func _on_score_timer_timeout() -> void:
	score += 1
	$CanvasLayer/Label.text = "耗时：" + str(score) + "s"
