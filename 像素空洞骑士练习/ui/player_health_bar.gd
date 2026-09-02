extends CanvasLayer

var PlayerHealth = 45

func _ready():
	PlayerHealth = 45
	
func refresh_player_health():
	# 确保数值在有效范围内 (0-9)
	PlayerHealth = clamp(PlayerHealth, 0, 45)
	# 使用 match 语句替代多个 if
	match PlayerHealth:
		0:
			$AnimationPlayer.play("0")
		5:
			$AnimationPlayer.play("1")
		10:
			$AnimationPlayer.play("2")
		15:
			$AnimationPlayer.play("3")
		20:
			$AnimationPlayer.play("4")
		25:
			$AnimationPlayer.play("5")
		30:
			$AnimationPlayer.play("6")
		35:
			$AnimationPlayer.play("7")
		40:
			$AnimationPlayer.play("8")
		45:
			$AnimationPlayer.play("9")
