extends CharacterBody2D

var direction:Vector2
var speed := 50
var player : CharacterBody2D
var health:= 3
var is_exploding:bool = false

func _on_detection_area_body_entered(player_body: CharacterBody2D) -> void:
	player = player_body

func _physics_process(_delta: float) -> void:
	if player:
		var dir = (player.position - position).normalized()
		velocity = dir * speed
		move_and_slide()
		
func _on_detection_area_body_exited(_player_body: CharacterBody2D) -> void:
	player = null

func _on_collision_area_body_entered(_body: Node2D) -> void:
	explode()

func hit():
	health -= 1
	if health <= 0:
		is_exploding = true
		explode()
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D.material, 'shader_parameter/progress', 0.0, 0.3)
	tween.tween_property($AnimatedSprite2D.material, 'shader_parameter/progress', 1.0, 0.5)
	

func explode():
	$AudioStreamPlayer2D.play()
	speed = 0
	$AnimatedSprite2D.hide()
	$ExplosionSprite.show()
	$AnimationPlayer.play("explode")
	await $AnimationPlayer.animation_finished
	queue_free()
	

func chain_reaction():
	for Drone in get_tree().get_nodes_in_group("Drones"):
		if position.distance_to(Drone.position) < 20 :
			if not is_exploding:
				Drone.explode()
