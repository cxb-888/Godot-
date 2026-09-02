extends Node2D

@export var hasBlackDash = true

func _ready():
	hasBlackDash = true

func spawn_blackdash():
	$AnimationPlayer.play("聚集")
