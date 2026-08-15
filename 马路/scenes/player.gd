extends CharacterBody2D

var direction: Vector2 = Vector2.ZERO
var speed: int = 100

func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("left", "right", "up", "down")
	
	velocity = direction * speed
	move_and_slide()
	
	# ← 加上这行：每帧调用动画更新
	animation()

func animation() -> void:
	if direction:
		$AnimatedSprite2D.flip_h = direction.x > 0
		if direction.x != 0:
			$AnimatedSprite2D.play("left")
		else:
			$AnimatedSprite2D.play("up" if direction.y < 0 else "down")
	else:
		$AnimatedSprite2D.pause()
		$AnimatedSprite2D.frame = 0
