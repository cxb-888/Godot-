extends CharacterBody2D

var direction = 1

func _ready():
	$AnimationPlayer.play("idle")

func _process(_delta):
	if direction == 1:
		velocity.x = 600
	else:
		velocity.x = -600
	move_and_slide()
